package api

import (
	"encoding/json"
	"strings"

	"github.com/pocketbase/pocketbase/core"
)

// ReportSubmitRequest from web support form
type ReportSubmitRequest struct {
	Type         string `json:"type"`          // app, question, other
	Reason       string `json:"reason"`        // required
	ContactEmail string `json:"contact_email"` // optional
}

// RegisterReportRoutes adds POST /api/reports/submit (public, for web support form)
func RegisterReportRoutes(se *core.ServeEvent) {
	se.Router.POST("/api/reports/submit", reportSubmitHandler(se.App))
}

func reportSubmitHandler(app core.App) func(*core.RequestEvent) error {
	return func(e *core.RequestEvent) error {
		var req ReportSubmitRequest
		if err := json.NewDecoder(e.Request.Body).Decode(&req); err != nil {
			return e.JSON(400, map[string]string{"error": "invalid json"})
		}
		req.Type = strings.TrimSpace(req.Type)
		req.Reason = strings.TrimSpace(req.Reason)
		req.ContactEmail = strings.TrimSpace(req.ContactEmail)

		validTypes := map[string]bool{"story": true, "chapter": true, "app": true, "question": true, "other": true}
		if req.Type == "" {
			req.Type = "app"
		}
		if !validTypes[req.Type] {
			return e.JSON(400, map[string]string{"error": "invalid type"})
		}
		if req.Reason == "" {
			return e.JSON(400, map[string]string{"error": "reason required"})
		}

		col, err := app.FindCollectionByNameOrId("reports")
		if err != nil {
			return e.JSON(500, map[string]string{"error": "reports not found"})
		}

		record := core.NewRecord(col)
		record.Set("type", req.Type)
		record.Set("reason", req.Reason)
		record.Set("status", "pending")
		record.Set("source", "web")
		if req.ContactEmail != "" {
			record.Set("contact_email", req.ContactEmail)
		}

		if err := app.Save(record); err != nil {
			return e.JSON(500, map[string]string{"error": "failed to save report"})
		}
		return e.JSON(200, map[string]any{"ok": true, "message": "Report submitted"})
	}
}
