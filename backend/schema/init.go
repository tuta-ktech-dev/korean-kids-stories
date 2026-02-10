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
	EnsureChapterAudiosCollection(app)
	EnsureReadingProgressCollection(app)
	EnsureDictionaryCollection(app)
	EnsureReportsCollection(app)
	EnsureUserPreferencesCollection(app)
	EnsureContentPagesCollection(app)
	EnsureAppConfigCollection(app)
	EnsureTrackingCollections(app)
	EnsurePopularSearchesCacheCollection(app)
	EnsureFavoritesCollection(app)
	EnsureReadLaterCollection(app)
	EnsureNotesCollection(app)
	EnsureReviewsCollection(app)
	EnsureViewsCollection(app)
}
