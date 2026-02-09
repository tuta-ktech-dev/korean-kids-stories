package schema

import (
	"github.com/pocketbase/pocketbase/core"
)

// EnsureViewsCollection ensures the views collection exists
func EnsureViewsCollection(app core.App) {
	// Get related collection IDs first
	usersCollection, err := app.FindCollectionByNameOrId("users")
	if err != nil {
		return
	}

	storiesCollection, err := app.FindCollectionByNameOrId("stories")
	if err != nil {
		return
	}

	chaptersCollection, _ := app.FindCollectionByNameOrId("chapters")

	collection, err := app.FindCollectionByNameOrId("views")
	if err != nil {
		collection = core.NewBaseCollection("views")
	}

	changes := false
	// Allow anyone to create view records (for tracking)
	if SetRules(collection, "", "", "", "", "") {
		changes = true
	}

	// Add relation fields
	if collection.Fields.GetByName("user") == nil {
		collection.Fields.Add(&core.RelationField{
			Name:          "user",
			CollectionId:  usersCollection.Id,
			Required:      false, // Allow anonymous views
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

	// Optional chapter relation
	if chaptersCollection != nil && collection.Fields.GetByName("chapter") == nil {
		collection.Fields.Add(&core.RelationField{
			Name:          "chapter",
			CollectionId:  chaptersCollection.Id,
			Required:      false,
			MaxSelect:     1,
			CascadeDelete: true,
		})
		changes = true
	}

	// IP address for tracking unique views
	if AddTextField(collection, "ip_address", false) {
		changes = true
	}

	// User agent
	if AddTextField(collection, "user_agent", false) {
		changes = true
	}

	// Add system fields
	if AddSystemFields(collection) {
		changes = true
	}

	if EnsureIndex(collection, "idx_views_story", false, "story", "") {
		changes = true
	}
	if EnsureIndex(collection, "idx_views_user_story", false, "user,story", "") {
		changes = true
	}
	if EnsureIndex(collection, "idx_views_ip_story", false, "ip_address,story", "") {
		changes = true
	}

	if changes {
		SaveCollection(app, collection)
	}
}
