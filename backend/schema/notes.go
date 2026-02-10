package schema

import (
	"github.com/pocketbase/pocketbase/core"
)

// EnsureNotesCollection ensures the notes collection exists (user notes on stories)
func EnsureNotesCollection(app core.App) {
	collection, err := app.FindCollectionByNameOrId("notes")
	if err != nil {
		collection = core.NewBaseCollection("notes")
	}

	changes := false
	if SetRules(collection, "user = @request.auth.id", "user = @request.auth.id", "user = @request.auth.id", "user = @request.auth.id", "") {
		changes = true
	}

	if AddRelationField(app, collection, "user", "users", true, 1, true) {
		changes = true
	}
	if AddRelationField(app, collection, "story", "stories", true, 1, false) {
		changes = true
	}
	if AddRelationField(app, collection, "chapter", "chapters", false, 1, true) {
		changes = true
	}
	if f := collection.Fields.GetByName("note"); f == nil {
		collection.Fields.Add(&core.EditorField{
			Name:     "note",
			Required: true,
		})
		changes = true
	}
	if AddNumberField(collection, "position", false, nil, nil) {
		changes = true
	}

	if AddSystemFields(collection) {
		changes = true
	}

	if EnsureIndex(collection, "idx_notes_user", false, "user", "") {
		changes = true
	}
	if EnsureIndex(collection, "idx_notes_story", false, "story", "") {
		changes = true
	}

	if changes {
		SaveCollection(app, collection)
	}
}
