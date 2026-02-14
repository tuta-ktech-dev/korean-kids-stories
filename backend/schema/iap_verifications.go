package schema

import (
	"github.com/pocketbase/pocketbase/core"
)

// EnsureIAPVerificationsCollection stores verified IAP purchases (device_id, transaction_id)
// Used to add is_premium to chapter API responses
func EnsureIAPVerificationsCollection(app core.App) {
	collection, err := app.FindCollectionByNameOrId("iap_verifications")
	if err != nil {
		collection = core.NewBaseCollection("iap_verifications")
	}
	changes := false
	// No auth - we write from /api/iap/verify, read from hooks
	if SetRules(collection, "", "", "", "", "") {
		changes = true
	}
	if AddTextField(collection, "device_id", true) {
		changes = true
	}
	if AddTextField(collection, "transaction_id", true) {
		changes = true
	}
	if AddTextField(collection, "product_id", true) {
		changes = true
	}
	if AddTextField(collection, "platform", false) {
		changes = true
	}
	if AddTextField(collection, "expires_at", false) {
		changes = true
	}
	if AddSystemFields(collection) {
		changes = true
	}
	if EnsureIndex(collection, "idx_iap_device_product", true, "device_id,product_id", "") {
		changes = true
	}
	if changes {
		SaveCollection(app, collection)
	}
}
