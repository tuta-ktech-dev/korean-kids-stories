package schema

import (
	"github.com/pocketbase/pocketbase/core"
)

// EnsureAllSchema ensures all collections exist
func EnsureAllSchema(app core.App) {
	// Order matters: users first, then stories, chapters, then others
	EnsureUsersExtendCollection(app)
	EnsureStoriesCollection(app)
	EnsureChaptersCollection(app)
	EnsureReadingProgressCollection(app)
	EnsureDictionaryCollection(app)
}
