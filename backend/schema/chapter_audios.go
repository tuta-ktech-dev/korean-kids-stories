package schema

import (
	"log"

	"github.com/pocketbase/pocketbase/core"
)

// EnsureChapterAudiosCollection ensures the chapter_audios collection exists.
// One chapter can have multiple audio versions (different narrators/voices).
func EnsureChapterAudiosCollection(app core.App) {
	chaptersCollection, err := app.FindCollectionByNameOrId("chapters")
	if err != nil {
		log.Printf("Chapters collection not found, skipping chapter_audios creation")
		return
	}

	collection, err := app.FindCollectionByNameOrId("chapter_audios")
	if err != nil {
		collection = core.NewBaseCollection("chapter_audios")
	}

	changes := false
	// Auth required for list/view (audio files)
	if SetRules(collection, "@request.auth.id != ''", "@request.auth.id != ''", "", "", "") {
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
	// narrator: tên giọng đọc (e.g. "Clova Female", "Clova Male")
	if AddTextField(collection, "narrator", false) {
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

	if AddSystemFields(collection) {
		changes = true
	}

	if EnsureIndex(collection, "idx_chapter_audios_chapter", false, "chapter", "") {
		changes = true
	}

	if changes {
		SaveCollection(app, collection)
	}
}
