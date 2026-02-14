package api

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"

	"github.com/pocketbase/pocketbase/core"
	"google.golang.org/api/androidpublisher/v3"
	"google.golang.org/api/option"
)

const (
	appleVerifyProd  = "https://buy.itunes.apple.com/verifyReceipt"
	appleVerifySand  = "https://sandbox.itunes.apple.com/verifyReceipt"
	productIDPremium = "premium"
)

// VerifyRequest is the incoming JSON from the app
type VerifyRequest struct {
	Platform      string `json:"platform"`       // "ios" or "android"
	ReceiptData   string `json:"receipt_data"`  // base64 (iOS)
	PurchaseToken string `json:"purchase_token"` // Android
	ProductID     string `json:"product_id"`    // e.g. "premium"
	TransactionID string `json:"transaction_id"` // optional, for idempotency
	DeviceID      string `json:"device_id"`     // required - used to store verified purchase for chapter is_premium
}

// VerifyResponse is returned to the app
type VerifyResponse struct {
	Verified      bool   `json:"verified"`
	TransactionID string `json:"transaction_id,omitempty"`
	Error         string `json:"error,omitempty"`
}

// appleVerifyReq is sent to Apple
type appleVerifyReq struct {
	ReceiptData          string `json:"receipt-data"`
	Password             string `json:"password"` // shared secret
	ExcludeOldTxs        bool   `json:"exclude-old-transactions"`
}

// appleVerifyResp is Apple's response
type appleVerifyResp struct {
	Status      int `json:"status"`
	Receipt     struct {
		InApp []struct {
			ProductID             string `json:"product_id"`
			TransactionID         string `json:"transaction_id"`
			OriginalTransactionID string `json:"original_transaction_id"`
		} `json:"in_app"`
	} `json:"receipt"`
	LatestReceiptInfo []struct {
		ProductID             string `json:"product_id"`
		TransactionID         string `json:"transaction_id"`
		OriginalTransactionID string `json:"original_transaction_id"`
	} `json:"latest_receipt_info"`
}

// RegisterIAPRoutes adds POST /api/iap/verify
func RegisterIAPRoutes(se *core.ServeEvent) {
	se.Router.POST("/api/iap/verify", iapVerifyHandler(se.App))
}

func iapVerifyHandler(app core.App) func(*core.RequestEvent) error {
	return func(e *core.RequestEvent) error {
		var req VerifyRequest
		if err := json.NewDecoder(e.Request.Body).Decode(&req); err != nil {
			return e.JSON(400, VerifyResponse{Error: "invalid json"})
		}
		if req.ProductID == "" {
			req.ProductID = productIDPremium
		}

		switch req.Platform {
		case "ios":
			return handleAppleVerify(app, e, &req)
		case "android":
			return handleGoogleVerify(app, e, &req)
		default:
			return e.JSON(400, VerifyResponse{Error: "platform must be ios or android"})
		}
	}
}

func handleAppleVerify(app core.App, e *core.RequestEvent, req *VerifyRequest) error {
	if req.ReceiptData == "" {
		return e.JSON(400, VerifyResponse{Error: "receipt_data required for ios"})
	}
	secret := getAppleSharedSecret()
	if secret == "" {
		return e.JSON(500, VerifyResponse{Error: "server misconfigured: IAP_SHARED_SECRET not set"})
	}

	body := appleVerifyReq{
		ReceiptData:   req.ReceiptData,
		Password:      secret,
		ExcludeOldTxs: true,
	}
	bodyBytes, _ := json.Marshal(body)

	// Try production first
	resp, err := doAppleVerify(appleVerifyProd, bodyBytes)
	if err != nil {
		return e.JSON(502, VerifyResponse{Error: "apple request failed: " + err.Error()})
	}

	// 21007 = sandbox receipt sent to prod → retry sandbox
	if resp.Status == 21007 {
		resp, err = doAppleVerify(appleVerifySand, bodyBytes)
		if err != nil {
			return e.JSON(502, VerifyResponse{Error: "apple sandbox request failed: " + err.Error()})
		}
	}

	if resp.Status != 0 {
		return e.JSON(400, VerifyResponse{
			Error: fmt.Sprintf("apple status %d", resp.Status),
		})
	}

	// Find our product in in_app or latest_receipt_info
	txID := ""
	for _, item := range resp.Receipt.InApp {
		if item.ProductID == req.ProductID {
			txID = item.OriginalTransactionID
			if txID == "" {
				txID = item.TransactionID
			}
			break
		}
	}
	if txID == "" {
		for _, item := range resp.LatestReceiptInfo {
			if item.ProductID == req.ProductID {
				txID = item.OriginalTransactionID
				if txID == "" {
					txID = item.TransactionID
				}
				break
			}
		}
	}

	// Store verified purchase for chapter is_premium (if device_id provided)
	if req.DeviceID != "" && txID != "" {
		_ = saveVerifiedPurchase(app, req.DeviceID, txID, req.ProductID, "ios")
	}
	return e.JSON(200, VerifyResponse{Verified: true, TransactionID: txID})
}

func doAppleVerify(url string, body []byte) (*appleVerifyResp, error) {
	httpReq, err := http.NewRequest("POST", url, bytes.NewReader(body))
	if err != nil {
		return nil, err
	}
	httpReq.Header.Set("Content-Type", "application/json")
	client := &http.Client{}
	res, err := client.Do(httpReq)
	if err != nil {
		return nil, err
	}
	defer res.Body.Close()
	data, err := io.ReadAll(res.Body)
	if err != nil {
		return nil, err
	}
	var v appleVerifyResp
	if err := json.Unmarshal(data, &v); err != nil {
		return nil, err
	}
	return &v, nil
}

func handleGoogleVerify(app core.App, e *core.RequestEvent, req *VerifyRequest) error {
	if req.PurchaseToken == "" {
		return e.JSON(400, VerifyResponse{Error: "purchase_token required for android"})
	}
	pkg := getGooglePackageName()
	if pkg == "" {
		return e.JSON(500, VerifyResponse{Error: "server misconfigured: GOOGLE_PACKAGE_NAME not set"})
	}

	// Create androidpublisher client (uses GOOGLE_APPLICATION_CREDENTIALS or GOOGLE_IAP_CREDENTIALS_JSON)
	ctx := context.Background()
	opts := getGoogleAuthOptions()
	if len(opts) == 0 {
		return e.JSON(500, VerifyResponse{Error: "server misconfigured: GOOGLE_APPLICATION_CREDENTIALS or GOOGLE_IAP_CREDENTIALS_JSON required"})
	}

	svc, err := androidpublisher.NewService(ctx, opts...)
	if err != nil {
		return e.JSON(502, VerifyResponse{Error: "google api init failed: " + err.Error()})
	}

	// Verify purchase via Google Play API
	productID := req.ProductID
	if productID == "" {
		productID = productIDPremium
	}
	purchase, err := svc.Purchases.Products.Get(pkg, productID, req.PurchaseToken).Do()
	if err != nil {
		return e.JSON(400, VerifyResponse{Error: "google verify failed: " + err.Error()})
	}

	// purchaseState: 0=Purchased, 1=Canceled, 2=Pending
	if purchase.PurchaseState != 0 {
		return e.JSON(400, VerifyResponse{Error: "purchase not completed"})
	}

	txID := purchase.OrderId
	if txID == "" {
		txID = req.PurchaseToken[:min(64, len(req.PurchaseToken))]
	}

	if req.DeviceID != "" && txID != "" {
		_ = saveVerifiedPurchase(app, req.DeviceID, txID, productID, "android")
	}
	return e.JSON(200, VerifyResponse{Verified: true, TransactionID: txID})
}

func getAppleSharedSecret() string {
	if s := os.Getenv("IAP_SHARED_SECRET"); s != "" {
		return s
	}
	return os.Getenv("APPLE_IAP_SHARED_SECRET")
}

func getGooglePackageName() string {
	if s := os.Getenv("GOOGLE_PACKAGE_NAME"); s != "" {
		return s
	}
	return "com.hbstore.koreankids"
}

func getGoogleAuthOptions() []option.ClientOption {
	if path := os.Getenv("GOOGLE_APPLICATION_CREDENTIALS"); path != "" {
		return []option.ClientOption{option.WithCredentialsFile(path)}
	}
	if json := os.Getenv("GOOGLE_IAP_CREDENTIALS_JSON"); json != "" {
		return []option.ClientOption{option.WithCredentialsJSON([]byte(json))}
	}
	return nil
}

func saveVerifiedPurchase(app core.App, deviceID, transactionID, productID, platform string) error {
	col, err := app.FindCollectionByNameOrId("iap_verifications")
	if err != nil {
		return err
	}
	// Upsert: device_id + product_id unique - replace if exists
	existing, _ := app.FindFirstRecordByFilter(col.Id, `device_id="`+escapeFilter(deviceID)+`" && product_id="`+escapeFilter(productID)+`"`)
	if existing != nil {
		existing.Set("transaction_id", transactionID)
		existing.Set("platform", platform)
		return app.Save(existing)
	}
	record := core.NewRecord(col)
	record.Set("device_id", deviceID)
	record.Set("transaction_id", transactionID)
	record.Set("product_id", productID)
	record.Set("platform", platform)
	return app.Save(record)
}

func escapeFilter(s string) string {
	return strings.ReplaceAll(strings.ReplaceAll(strings.ReplaceAll(s, `\`, `\\`), `"`, `\"`), `'`, `\'`)
}
