package schema

import (
	"github.com/pocketbase/pocketbase/core"
)

// EnsureBookmarksCollection ensures the bookmarks collection exists
func EnsureBookmarksCollection(app core.App) {
	collection, err := app.FindCollectionByNameOrId("bookmarks")
	if err != nil {
		collection = core.NewBaseCollection("bookmarks")
	}

	changes := false
	// User can only see their own bookmarks
	if SetRules(collection, "user = @request.auth.id", "user = @request.auth.id", "user = @request.auth.id", "user = @request.auth.id", "") {
		changes = true
	}

	if AddRelationField(collection, "user", "users", true, 1, true) {
		changes = true
	}
	if AddRelationField(collection, "story", "stories", true, 1, false) {
		changes = true
	}
	if AddRelationField(collection, "chapter", "chapters", false, 1, true) {
		changes = true
	}
	if AddSelectField(collection, "type", true, []string{"favorite", "bookmark", "read_later"}, 1) {
		changes = true
	}
	if f := collection.Fields.GetByName("note"); f == nil {
		collection.Fields.Add(&core.EditorField{
			Name:     "note",
			Required: false,
		})
		changes = true
	}
	if AddNumberField(collection, "position", false, nil, nil) {
		changes = true
	}

	if EnsureIndex(collection, "idx_bookmarks_user", false, "user", "") {
		changes = true
	}
	if EnsureIndex(collection, "idx_bookmarks_user_story", true, "user,story", "") {
		changes = true
	}

	if changes {
		SaveCollection(app, collection)
	}
}
