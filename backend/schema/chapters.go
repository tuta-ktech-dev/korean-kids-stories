package schema

import (
	"log"

	"github.com/pocketbase/pocketbase/core"
)

// EnsureChaptersCollection ensures the chapters collection exists
func EnsureChaptersCollection(app core.App) {
	// Get stories collection ID first
	storiesCollection, err := app.FindCollectionByNameOrId("stories")
	if err != nil {
		log.Printf("Stories collection not found, skipping chapters creation")
		return
	}

	collection, err := app.FindCollectionByNameOrId("chapters")
	if err != nil {
		collection = core.NewBaseCollection("chapters")
	}

	changes := false
	if SetRules(collection, "@request.auth.id != ''", "@request.auth.id != ''", "", "", "") {
		changes = true
	}

	// Add relation field with correct CollectionId
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
	if AddNumberField(collection, "chapter_number", true, Ptr(1.0), Ptr(1000.0)) {
		changes = true
	}
	if AddTextField(collection, "title", true) {
		changes = true
	}
	if f := collection.Fields.GetByName("content"); f == nil {
		collection.Fields.Add(&core.EditorField{
			Name:     "content",
			Required: true,
		})
		changes = true
	}
	if AddFileField(collection, "audio_file", 1, 52428800, []string{"audio/mpeg", "audio/mp4", "audio/wav", "audio/webm"}) {
		changes = true
	}
	if AddNumberField(collection, "audio_duration", false, nil, nil) {
		changes = true
	}
	if AddJSONField(collection, "word_timings", false) {
		changes = true
	}
	if AddFileField(collection, "illustrations", 10, 5242880, []string{"image/jpeg", "image/png", "image/webp"}) {
		changes = true
	}
	if AddBoolField(collection, "is_free") {
		changes = true
	}

	if EnsureIndex(collection, "idx_chapters_story", false, "story", "") {
		changes = true
	}
	if EnsureIndex(collection, "idx_chapters_number", false, "story,chapter_number", "") {
		changes = true
	}

	if changes {
		SaveCollection(app, collection)
	}
}
