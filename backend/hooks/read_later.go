package hooks

import (
	"log"

	"github.com/pocketbase/dbx"
	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/core"
)

// RegisterReadLaterHooks registers hooks for the read_later collection
func RegisterReadLaterHooks(app *pocketbase.PocketBase) {
	app.OnRecordAfterCreateSuccess("read_later").BindFunc(func(e *core.RecordEvent) error {
		if err := updateStoryBookmarkCount(e.App, e.Record.GetString("story")); err != nil {
			log.Printf("Failed to update story bookmark count: %v", err)
		}
		return e.Next()
	})

	app.OnRecordAfterUpdateSuccess("read_later").BindFunc(func(e *core.RecordEvent) error {
		oldStoryId := ""
		if orig := e.Record.Original(); orig != nil {
			oldStoryId = orig.GetString("story")
		}
		newStoryId := e.Record.GetString("story")
		for _, id := range uniqueStoryIds(oldStoryId, newStoryId) {
			if err := updateStoryBookmarkCount(e.App, id); err != nil {
				log.Printf("Failed to update story bookmark count: %v", err)
			}
		}
		return e.Next()
	})

	app.OnRecordAfterDeleteSuccess("read_later").BindFunc(func(e *core.RecordEvent) error {
		if err := updateStoryBookmarkCount(e.App, e.Record.GetString("story")); err != nil {
			log.Printf("Failed to update story bookmark count: %v", err)
		}
		return e.Next()
	})
}

func updateStoryBookmarkCount(app core.App, storyId string) error {
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

		readLaterCollection, err := txApp.FindCollectionByNameOrId("read_later")
		if err != nil {
			return err
		}

		count, err := txApp.CountRecords(
			readLaterCollection.Id,
			dbx.HashExp{"story": storyId},
		)
		if err != nil {
			return err
		}

		story.Set("bookmark_count", count)
		return txApp.Save(story)
	})
}
