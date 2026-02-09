package schema

import (
	"github.com/pocketbase/pocketbase/core"
)

// EnsureReviewsCollection ensures the reviews collection exists
func EnsureReviewsCollection(app core.App) {
	// Get related collection IDs first
	usersCollection, err := app.FindCollectionByNameOrId("users")
	if err != nil {
		return
	}

	storiesCollection, err := app.FindCollectionByNameOrId("stories")
	if err != nil {
		return
	}

	collection, err := app.FindCollectionByNameOrId("reviews")
	if err != nil {
		collection = core.NewBaseCollection("reviews")
	}

	changes := false
	// Users can only see all reviews, but only create/update/delete their own
	if SetRules(collection, "", "", "@request.auth.id != ''", "user = @request.auth.id", "user = @request.auth.id") {
		changes = true
	}

	// Add relation fields
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

	if collection.Fields.GetByName("story") == nil {
		collection.Fields.Add(&core.RelationField{
			Name:          "story",
			CollectionId:  storiesCollection.Id,
			Required:      true,
			MaxSelect:     1,
			CascadeDelete: true,
		})
		changes = true
	}

	// Rating: 1-5 stars
	if AddNumberField(collection, "rating", true, Ptr(1.0), Ptr(5.0)) {
		changes = true
	}

	// Optional comment
	if f := collection.Fields.GetByName("comment"); f == nil {
		collection.Fields.Add(&core.EditorField{
			Name:     "comment",
			Required: false,
		})
		changes = true
	}

	// Add system fields
	if AddSystemFields(collection) {
		changes = true
	}

	if EnsureIndex(collection, "idx_reviews_user_story", true, "user,story", "") {
		changes = true
	}
	if EnsureIndex(collection, "idx_reviews_story", false, "story", "") {
		changes = true
	}

	if changes {
		SaveCollection(app, collection)
	}
}
