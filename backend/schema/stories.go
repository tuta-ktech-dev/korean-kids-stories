package schema

import (
	"github.com/pocketbase/pocketbase/core"
)

// EnsureStoriesCollection ensures the stories collection exists
func EnsureStoriesCollection(app core.App) {
	collection, err := app.FindCollectionByNameOrId("stories")
	if err != nil {
		collection = core.NewBaseCollection("stories")
	}

	changes := false
	if SetRules(collection, "is_published = true", "is_published = true", "", "", "") {
		changes = true
	}

	if AddTextField(collection, "title", true) {
		changes = true
	}
	if AddSelectField(collection, "category", true, []string{"folktale", "history", "legend"}, 1) {
		changes = true
	}
	if AddNumberField(collection, "age_min", true, Ptr(1.0), Ptr(15.0)) {
		changes = true
	}
	if AddNumberField(collection, "age_max", true, Ptr(1.0), Ptr(15.0)) {
		changes = true
	}
	if AddFileField(collection, "thumbnail", 1, 5242880, []string{"image/jpeg", "image/png", "image/webp"}) {
		changes = true
	}
	if AddTextField(collection, "summary", false) {
		changes = true
	}
	if AddNumberField(collection, "total_chapters", true, Ptr(1.0), Ptr(100.0)) {
		changes = true
	}
	if AddJSONField(collection, "tags", false) {
		changes = true
	}
	if AddBoolField(collection, "is_published") {
		changes = true
	}

	// Add system fields
	if AddSystemFields(collection) {
		changes = true
	}

	if EnsureIndex(collection, "idx_stories_category", false, "category", "") {
		changes = true
	}
	if EnsureIndex(collection, "idx_stories_published", false, "is_published", "") {
		changes = true
	}

	if changes {
		SaveCollection(app, collection)
	}
}
