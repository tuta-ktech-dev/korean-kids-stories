package schema

import (
	"log"

	"github.com/pocketbase/pocketbase/core"
)

// EnsureUserStickersCollection ensures the user_stickers collection exists.
func EnsureUserStickersCollection(app core.App) {
	usersCollection, err := app.FindCollectionByNameOrId("users")
	if err != nil {
		log.Printf("Users collection not found, skipping user_stickers creation")
		return
	}

	stickersCollection, err := app.FindCollectionByNameOrId("stickers")
	if err != nil {
		log.Printf("Stickers collection not found, skipping user_stickers creation")
		return
	}

	collection, err := app.FindCollectionByNameOrId("user_stickers")
	if err != nil {
		collection = core.NewBaseCollection("user_stickers")
	}

	changes := false
	if SetRules(collection,
		"user = @request.auth.id",
		"user = @request.auth.id",
		"user = @request.auth.id",
		"user = @request.auth.id",
		"user = @request.auth.id") {
		changes = true
	}

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
	if collection.Fields.GetByName("sticker") == nil {
		collection.Fields.Add(&core.RelationField{
			Name:          "sticker",
			CollectionId:  stickersCollection.Id,
			Required:      true,
			MaxSelect:     1,
			CascadeDelete: false,
		})
		changes = true
	}
	if AddSelectField(collection, "unlock_source", true, []string{"level_up", "story_complete"}, 1) {
		changes = true
	}

	if AddSystemFields(collection) {
		changes = true
	}

	if EnsureIndex(collection, "idx_user_stickers_user", false, "user", "") {
		changes = true
	}
	if EnsureIndex(collection, "idx_user_stickers_user_sticker", true, "user,sticker", "") {
		changes = true
	}

	if changes {
		SaveCollection(app, collection)
	}
}
