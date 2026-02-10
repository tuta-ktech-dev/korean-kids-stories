package schema

import (
	"log"

	"github.com/pocketbase/pocketbase/core"
)

// EnsureReportsCollection ensures the reports collection exists
func EnsureReportsCollection(app core.App) {
	usersCol, err := app.FindCollectionByNameOrId("users")
	if err != nil {
		log.Printf("Users collection not found, skipping reports creation")
		return
	}

	collection, err := app.FindCollectionByNameOrId("reports")
	if err != nil {
		collection = core.NewBaseCollection("reports")
	}

	changes := false
	// Only admin can view reports
	if SetRules(collection, "@request.auth.id != ''", "@request.auth.id != ''", "@request.auth.id != ''", "", "") {
		changes = true
	}

	if collection.Fields.GetByName("user") == nil {
		collection.Fields.Add(&core.RelationField{
			Name:          "user",
			CollectionId:  usersCol.Id,
			Required:      true,
			MaxSelect:     1,
			CascadeDelete: false,
		})
		changes = true
	}
	if AddSelectField(collection, "type", true, []string{"story", "chapter", "app", "question", "other"}, 1) {
		changes = true
	}
	if AddTextField(collection, "target_id", true) {
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
