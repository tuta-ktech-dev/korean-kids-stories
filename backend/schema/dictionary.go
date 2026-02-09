package schema

import (
	"github.com/pocketbase/pocketbase/core"
)

// EnsureDictionaryCollection ensures the dictionary collection exists
func EnsureDictionaryCollection(app core.App) {
	collection, err := app.FindCollectionByNameOrId("dictionary")
	if err != nil {
		collection = core.NewBaseCollection("dictionary")
	}

	changes := false
	// Public access for tap-to-define
	if SetRules(collection, "", "", "", "", "") {
		changes = true
	}

	if AddTextField(collection, "word", true) {
		changes = true
	}
	if AddTextField(collection, "reading", false) {
		changes = true
	}
	if f := collection.Fields.GetByName("meaning"); f == nil {
		collection.Fields.Add(&core.EditorField{
			Name:     "meaning",
			Required: true,
		})
		changes = true
	}
	if f := collection.Fields.GetByName("example"); f == nil {
		collection.Fields.Add(&core.EditorField{
			Name:     "example",
			Required: false,
		})
		changes = true
	}
	if AddSelectField(collection, "category", true, []string{"hanja", "old_korean", "name", "place"}, 1) {
		changes = true
	}

	if EnsureIndex(collection, "idx_dictionary_word", true, "word", "") {
		changes = true
	}

	// Add system fields
	if AddSystemFields(collection) {
		changes = true
	}

	if changes {
		SaveCollection(app, collection)
	}
}
