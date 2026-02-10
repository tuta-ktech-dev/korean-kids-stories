package hooks

import (
	"log"

	"github.com/pocketbase/pocketbase"
)

// SetupHooks configures all Pocketbase hooks
func SetupHooks(app *pocketbase.PocketBase) {
	RegisterViewsHooks(app)
	RegisterReviewsHooks(app)
	RegisterBookmarksHooks(app)

	log.Println("✅ Hooks configured successfully")
}
