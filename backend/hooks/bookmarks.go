package hooks

import (
	"log"

	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/core"
)

// RegisterBookmarksHooks registers hooks for the bookmarks collection
func RegisterBookmarksHooks(app *pocketbase.PocketBase) {
	app.OnRecordCreateRequest("bookmarks").BindFunc(func(e *core.RecordRequestEvent) error {
		if err := updateStoryBookmarkCountsTransactional(app, e.Record.GetString("story")); err != nil {
			log.Printf("Failed to update story bookmark counts: %v", err)
		}
		return e.Next()
	})

	app.OnRecordUpdateRequest("bookmarks").BindFunc(func(e *core.RecordRequestEvent) error {
		oldStoryId := ""
		if orig := e.Record.Original(); orig != nil {
			oldStoryId = orig.GetString("story")
		}
		newStoryId := e.Record.GetString("story")
		for _, id := range uniqueStoryIds(oldStoryId, newStoryId) {
			if err := updateStoryBookmarkCountsTransactional(app, id); err != nil {
				log.Printf("Failed to update story bookmark counts: %v", err)
			}
		}
		return e.Next()
	})

	app.OnRecordDeleteRequest("bookmarks").BindFunc(func(e *core.RecordRequestEvent) error {
		if err := updateStoryBookmarkCountsTransactional(app, e.Record.GetString("story")); err != nil {
			log.Printf("Failed to update story bookmark counts: %v", err)
		}
		return e.Next()
	})
}

func updateStoryBookmarkCountsTransactional(app core.App, storyId string) error {
	if storyId == "" {
		return nil
	}

	return app.RunInTransaction(func(txApp core.App) error {
		storiesCollection, err := txApp.FindCollectionByNameOrId("stories")
		if err != nil {
			return err
		}

		story, err := txApp.FindRecordById(storiesCollection, storyId)
		if err != nil {
			return err
		}

		bookmarksCollection, err := txApp.FindCollectionByNameOrId("bookmarks")
		if err != nil {
			return err
		}

		safeStoryId := escapeFilter(storyId)
		filter := `story="` + safeStoryId + `"`

		bookmarks, err := txApp.FindRecordsByFilter(
			bookmarksCollection.Id,
			filter,
			"",
			10000,
			0,
		)
		if err != nil {
			return err
		}

		favoriteCount := 0
		bookmarkCount := 0
		for _, bm := range bookmarks {
			switch bm.GetString("type") {
			case "favorite":
				favoriteCount++
			case "bookmark":
				bookmarkCount++
			}
		}

		story.Set("favorite_count", favoriteCount)
		story.Set("bookmark_count", bookmarkCount)

		return txApp.Save(story)
	})
}
