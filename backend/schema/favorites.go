package schema

import (
	"github.com/pocketbase/pocketbase/core"
)

// EnsureFavoritesCollection ensures the favorites collection exists
func EnsureFavoritesCollection(app core.App) {
	collection, err := app.FindCollectionByNameOrId("favorites")
	if err != nil {
		collection = core.NewBaseCollection("favorites")
	}

	changes := false
	if SetRules(collection, "user = @request.auth.id", "user = @request.auth.id", "user = @request.auth.id", "user = @request.auth.id", "") {
		changes = true
	}

	if AddRelationField(app, collection, "user", "users", true, 1, true) {
		changes = true
	}
	if AddRelationField(app, collection, "story", "stories", true, 1, false) {
		changes = true
	}

	if AddSystemFields(collection) {
		changes = true
	}

	if EnsureIndex(collection, "idx_favorites_user", false, "user", "") {
		changes = true
	}
	if EnsureIndex(collection, "idx_favorites_user_story", true, "user,story", "") {
		changes = true
	}

	if changes {
		SaveCollection(app, collection)
	}
}
