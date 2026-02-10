package schema

import (
	"log"

	"github.com/pocketbase/pocketbase/core"
)

// EnsureBookmarksCollection ensures the bookmarks collection exists
func EnsureBookmarksCollection(app core.App) {
	usersCol, err := app.FindCollectionByNameOrId("users")
	if err != nil {
		log.Printf("Users collection not found, skipping bookmarks creation")
		return
	}
	storiesCol, err := app.FindCollectionByNameOrId("stories")
	if err != nil {
		log.Printf("Stories collection not found, skipping bookmarks creation")
		return
	}
	chaptersCol, err := app.FindCollectionByNameOrId("chapters")
	if err != nil {
		log.Printf("Chapters collection not found, skipping bookmarks creation")
		return
	}

	collection, err := app.FindCollectionByNameOrId("bookmarks")
	if err != nil {
		collection = core.NewBaseCollection("bookmarks")
	}

	changes := false
	// User can only see their own bookmarks
	if SetRules(collection, "user = @request.auth.id", "user = @request.auth.id", "user = @request.auth.id", "user = @request.auth.id", "") {
		changes = true
	}

	if collection.Fields.GetByName("user") == nil {
		collection.Fields.Add(&core.RelationField{
			Name:          "user",
			CollectionId:  usersCol.Id,
			Required:      true,
			MaxSelect:     1,
			CascadeDelete: true,
		})
		changes = true
	}
	if collection.Fields.GetByName("story") == nil {
		collection.Fields.Add(&core.RelationField{
			Name:          "story",
			CollectionId:  storiesCol.Id,
			Required:      true,
			MaxSelect:     1,
			CascadeDelete: false,
		})
		changes = true
	}
	if collection.Fields.GetByName("chapter") == nil {
		collection.Fields.Add(&core.RelationField{
			Name:          "chapter",
			CollectionId:  chaptersCol.Id,
			Required:      false,
			MaxSelect:     1,
			CascadeDelete: true,
		})
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

	// Add system fields
	if AddSystemFields(collection) {
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
