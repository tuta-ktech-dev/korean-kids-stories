package schema

import (
	"log"

	"github.com/pocketbase/pocketbase/core"
)

// EnsureReadingProgressCollection ensures the reading_progress collection exists
func EnsureReadingProgressCollection(app core.App) {
	// Get related collection IDs first
	usersCollection, err := app.FindCollectionByNameOrId("users")
	if err != nil {
		log.Printf("Users collection not found, skipping reading_progress creation")
		return
	}

	chaptersCollection, err := app.FindCollectionByNameOrId("chapters")
	if err != nil {
		log.Printf("Chapters collection not found, skipping reading_progress creation")
		return
	}

	collection, err := app.FindCollectionByNameOrId("reading_progress")
	if err != nil {
		collection = core.NewBaseCollection("reading_progress")
	}

	changes := false
	if SetRules(collection,
		"user = @request.auth.id",
		"user = @request.auth.id",
		"user = @request.auth.id",
		"user = @request.auth.id",
		"") {
		changes = true
	}

	// Add relation fields with correct CollectionIds
	if collection.Fields.GetByName("user") == nil {
		collection.Fields.Add(&core.RelationField{
			Name:          "user",
			CollectionId:  usersCollection.Id,
			Required:      true,
			MaxSelect:     1,
			CascadeDelete: true,
		})
		changes = true
	}

	if collection.Fields.GetByName("chapter") == nil {
		collection.Fields.Add(&core.RelationField{
			Name:          "chapter",
			CollectionId:  chaptersCollection.Id,
			Required:      true,
			MaxSelect:     1,
			CascadeDelete: true,
		})
		changes = true
	}
	if AddNumberField(collection, "percent_read", true, Ptr(0.0), Ptr(100.0)) {
		changes = true
	}
	if AddNumberField(collection, "last_position", false, nil, nil) {
		changes = true
	}
	if AddBoolField(collection, "is_completed") {
		changes = true
	}
	if AddJSONField(collection, "bookmarks", false) {
		changes = true
	}

	if EnsureIndex(collection, "idx_progress_user_chapter", true, "user,chapter", "") {
		changes = true
	}

	if changes {
		SaveCollection(app, collection)
	}
}
