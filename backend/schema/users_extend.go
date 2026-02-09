package schema

import (
	"github.com/pocketbase/pocketbase/core"
)

// EnsureUsersExtendCollection extends the default users collection
func EnsureUsersExtendCollection(app core.App) {
	collection, err := app.FindCollectionByNameOrId("users")
	if err != nil {
		// If users doesn't exist, let PocketBase create it first
		return
	}

	changes := false

	if AddTextField(collection, "name", false) {
		changes = true
	}
	if AddNumberField(collection, "birth_year", false, Ptr(2000.0), Ptr(2030.0)) {
		changes = true
	}
	if AddFileField(collection, "avatar", 1, 2097152, []string{"image/jpeg", "image/png", "image/webp"}) {
		changes = true
	}
	if AddNumberField(collection, "streak_days", false, nil, nil) {
		changes = true
	}
	if AddNumberField(collection, "total_reading_minutes", false, nil, nil) {
		changes = true
	}
	if f := collection.Fields.GetByName("parent_email"); f == nil {
		collection.Fields.Add(&core.EmailField{
			Name:     "parent_email",
			Required: false,
		})
		changes = true
	}

	if changes {
		SaveCollection(app, collection)
	}
}
