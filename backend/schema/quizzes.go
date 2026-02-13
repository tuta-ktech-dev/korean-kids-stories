package schema

import (
	"github.com/pocketbase/pocketbase/core"
)

// EnsureQuizzesCollection ensures the quizzes collection exists
func EnsureQuizzesCollection(app core.App) {
	// Get related collection IDs first
	storiesCollection, err := app.FindCollectionByNameOrId("stories")
	if err != nil {
		return
	}

	chaptersCollection, err := app.FindCollectionByNameOrId("chapters")
	if err != nil {
		return
	}

	collection, err := app.FindCollectionByNameOrId("quizzes")
	if err != nil {
		collection = core.NewBaseCollection("quizzes")
	}

	changes := false
	// Public can view published quizzes
	if SetRules(collection, "is_published = true", "is_published = true", LockRule, LockRule, LockRule) {
		changes = true
	}

	// Add relation fields
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

	if collection.Fields.GetByName("chapter") == nil {
		collection.Fields.Add(&core.RelationField{
			Name:          "chapter",
			CollectionId:  chaptersCollection.Id,
			Required:      false, // Optional - quiz can be for whole story
			MaxSelect:     1,
			CascadeDelete: true,
		})
		changes = true
	}

	// Question
	if AddTextField(collection, "question", true) {
		changes = true
	}

	// Options array
	if AddJSONField(collection, "options", true) {
		changes = true
	}

	// Correct answer index (0-3)
	if AddNumberField(collection, "correct_answer", true, Ptr(0.0), Ptr(3.0)) {
		changes = true
	}

	// Explanation
	if AddTextField(collection, "explanation", false) {
		changes = true
	}

	// Published flag
	if AddBoolField(collection, "is_published") {
		changes = true
	}

	// Add system fields
	if AddSystemFields(collection) {
		changes = true
	}

	// Indexes
	if EnsureIndex(collection, "idx_quizzes_story", false, "story", "") {
		changes = true
	}
	if EnsureIndex(collection, "idx_quizzes_chapter", false, "chapter", "") {
		changes = true
	}
	if EnsureIndex(collection, "idx_quizzes_story_published", false, "story,is_published", "") {
		changes = true
	}

	if changes {
		SaveCollection(app, collection)
	}
}
