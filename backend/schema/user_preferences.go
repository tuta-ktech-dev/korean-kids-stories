package schema

import (
	"github.com/pocketbase/pocketbase/core"
)

// EnsureUserPreferencesCollection ensures the user_preferences collection exists
// Used to sync theme, notification settings, etc. across devices
func EnsureUserPreferencesCollection(app core.App) {
	collection, err := app.FindCollectionByNameOrId("user_preferences")
	if err != nil {
		collection = core.NewBaseCollection("user_preferences")
	}

	changes := false
	// User can only access their own preferences
	if SetRules(collection, "user = @request.auth.id", "user = @request.auth.id", "@request.auth.id != ''", "user = @request.auth.id", "user = @request.auth.id") {
		changes = true
	}

	if AddRelationField(app, collection, "user", "users", true, 1, true) {
		changes = true
	}
	// theme: light, dark, system
	if AddSelectField(collection, "theme", true, []string{"light", "dark", "system"}, 1) {
		changes = true
	}
	// Push notification enabled
	if AddBoolField(collection, "notifications_enabled") {
		changes = true
	}
	// Optional: other preference keys as JSON for future extensibility
	if AddJSONField(collection, "extra", false) {
		changes = true
	}

	if EnsureIndex(collection, "idx_user_preferences_user", true, "user", "") {
		changes = true
	}

	if AddSystemFields(collection) {
		changes = true
	}

	if changes {
		SaveCollection(app, collection)
	}
}
