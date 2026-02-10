package hooks

import (
	"log"
	"time"

	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/core"
)

// RegisterViewsHooks registers hooks for the views collection
func RegisterViewsHooks(app *pocketbase.PocketBase) {
	app.OnRecordCreateRequest("views").BindFunc(func(e *core.RecordRequestEvent) error {
		storyId := e.Record.GetString("story")
		if storyId == "" {
			return e.Next()
		}

		if !isDuplicateView(app, e.Record, storyId) {
			if err := incrementViewCountAtomic(app, storyId); err != nil {
				log.Printf("Failed to increment view count: %v", err)
			}
		}

		return e.Next()
	})
}

func isDuplicateView(app core.App, viewRecord *core.Record, storyId string) bool {
	userId := viewRecord.GetString("user")
	ipAddress := viewRecord.GetString("ip_address")

	viewsCollection, err := app.FindCollectionByNameOrId("views")
	if err != nil {
		return false
	}

	safeStoryId := escapeFilter(storyId)
	cutoffTime := time.Now().Add(-1 * time.Hour).Format(time.RFC3339)

	var filter string
	if userId != "" {
		safeUserId := escapeFilter(userId)
		filter = `story="` + safeStoryId + `" && user="` + safeUserId + `" && created>="` + cutoffTime + `"`
	} else if ipAddress != "" {
		safeIp := escapeFilter(ipAddress)
		filter = `story="` + safeStoryId + `" && ip_address="` + safeIp + `" && created>="` + cutoffTime + `"`
	} else {
		return false
	}

	existing, err := app.FindRecordsByFilter(
		viewsCollection.Id,
		filter,
		"-created",
		1,
		0,
	)

	return err == nil && len(existing) > 0
}

func incrementViewCountAtomic(app core.App, storyId string) error {
	return app.RunInTransaction(func(txApp core.App) error {
		storiesCollection, err := txApp.FindCollectionByNameOrId("stories")
		if err != nil {
			return err
		}

		story, err := txApp.FindRecordById(storiesCollection, storyId)
		if err != nil {
			return err
		}

		currentCount := story.GetInt("view_count")
		story.Set("view_count", currentCount+1)

		return txApp.Save(story)
	})
}
