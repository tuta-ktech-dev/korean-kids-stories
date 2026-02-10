package hooks

import (
	"log"

	"github.com/pocketbase/dbx"
	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/core"
)

// RegisterFavoritesHooks registers hooks for the favorites collection
func RegisterFavoritesHooks(app *pocketbase.PocketBase) {
	app.OnRecordAfterCreateSuccess("favorites").BindFunc(func(e *core.RecordEvent) error {
		if err := updateStoryFavoriteCount(e.App, e.Record.GetString("story")); err != nil {
			log.Printf("Failed to update story favorite count: %v", err)
		}
		return e.Next()
	})

	app.OnRecordAfterDeleteSuccess("favorites").BindFunc(func(e *core.RecordEvent) error {
		if err := updateStoryFavoriteCount(e.App, e.Record.GetString("story")); err != nil {
			log.Printf("Failed to update story favorite count: %v", err)
		}
		return e.Next()
	})
}

func updateStoryFavoriteCount(app core.App, storyId string) error {
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

		favoritesCollection, err := txApp.FindCollectionByNameOrId("favorites")
		if err != nil {
			return err
		}

		count, err := txApp.CountRecords(
			favoritesCollection.Id,
			dbx.HashExp{"story": storyId},
		)
		if err != nil {
			return err
		}

		story.Set("favorite_count", count)
		return txApp.Save(story)
	})
}
