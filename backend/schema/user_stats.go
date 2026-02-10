package schema

import (
	"log"

	"github.com/pocketbase/pocketbase/core"
)

// EnsureUserStatsCollection ensures the user_stats collection exists.
// 1 user = 1 record (upsert on create)
func EnsureUserStatsCollection(app core.App) {
	usersCollection, err := app.FindCollectionByNameOrId("users")
	if err != nil {
		log.Printf("Users collection not found, skipping user_stats creation")
		return
	}

	collection, err := app.FindCollectionByNameOrId("user_stats")
	if err != nil {
		collection = core.NewBaseCollection("user_stats")
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
	if AddNumberField(collection, "total_xp", false, Ptr(0.0), nil) {
		changes = true
	}
	if AddNumberField(collection, "level", false, Ptr(1.0), Ptr(18.0)) {
		changes = true
	}
	if AddNumberField(collection, "streak_days", false, Ptr(0.0), nil) {
		changes = true
	}
	if AddTextField(collection, "last_activity_date", false) {
		changes = true
	}
	if AddNumberField(collection, "chapters_read", false, Ptr(0.0), nil) {
		changes = true
	}
	if AddNumberField(collection, "chapters_listened", false, Ptr(0.0), nil) {
		changes = true
	}
	if AddNumberField(collection, "stories_completed", false, Ptr(0.0), nil) {
		changes = true
	}

	if AddSystemFields(collection) {
		changes = true
	}

	if EnsureIndex(collection, "idx_user_stats_user", true, "user", "") {
		changes = true
	}

	if changes {
		SaveCollection(app, collection)
	}
}
