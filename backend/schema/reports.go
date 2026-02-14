package schema

import (
	"github.com/pocketbase/pocketbase/core"
)

// EnsureReportsCollection ensures the reports collection exists
func EnsureReportsCollection(app core.App) {
	collection, err := app.FindCollectionByNameOrId("reports")
	if err != nil {
		collection = core.NewBaseCollection("reports")
	}

	changes := false
	// Users: create only (user auto-set by hook). List/view own only. Update/delete admin only.
	if SetRules(collection, "user = @request.auth.id", "user = @request.auth.id", "@request.auth.id != ''", "", "") {
		changes = true
	}

	// user: optional for web form submissions (no auth)
	if AddRelationField(app, collection, "user", "users", false, 1, false) {
		changes = true
	}
	// Ensure existing user field is optional (for web reports)
	if f := collection.Fields.GetByName("user"); f != nil {
		if rf, ok := f.(*core.RelationField); ok && rf.Required {
			rf.Required = false
			changes = true
		}
	}
	if AddSelectField(collection, "type", true, []string{"story", "chapter", "app", "question", "other"}, 1) {
		changes = true
	}
	if AddTextField(collection, "target_id", false) {
		changes = true
	}
	if f := collection.Fields.GetByName("reason"); f == nil {
		collection.Fields.Add(&core.EditorField{
			Name:     "reason",
			Required: true,
		})
		changes = true
	}
	if AddSelectField(collection, "status", true, []string{"pending", "reviewing", "resolved", "rejected"}, 1) {
		changes = true
	}
	if f := collection.Fields.GetByName("admin_note"); f == nil {
		collection.Fields.Add(&core.EditorField{
			Name:     "admin_note",
			Required: false,
		})
		changes = true
	}
	if AddTextField(collection, "contact_email", false) {
		changes = true
	}
	if AddTextField(collection, "source", false) {
		changes = true
	}

	if EnsureIndex(collection, "idx_reports_user", false, "user", "") {
		changes = true
	}
	if EnsureIndex(collection, "idx_reports_status", false, "status", "") {
		changes = true
	}
	if EnsureIndex(collection, "idx_reports_type", false, "type", "") {
		changes = true
	}

	// Add system fields
	if AddSystemFields(collection) {
		changes = true
	}

	if changes {
		SaveCollection(app, collection)
	}
}
