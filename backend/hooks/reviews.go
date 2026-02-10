package hooks

import (
	"log"

	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/core"
)

// RegisterReviewsHooks registers hooks for the reviews collection
func RegisterReviewsHooks(app *pocketbase.PocketBase) {
	app.OnRecordAfterCreateSuccess("reviews").BindFunc(func(e *core.RecordEvent) error {
		if err := updateStoryRatingTransactional(e.App, e.Record.GetString("story")); err != nil {
			log.Printf("Failed to update story rating: %v", err)
		}
		return e.Next()
	})

	app.OnRecordAfterUpdateSuccess("reviews").BindFunc(func(e *core.RecordEvent) error {
		if err := updateStoryRatingTransactional(e.App, e.Record.GetString("story")); err != nil {
			log.Printf("Failed to update story rating: %v", err)
		}
		return e.Next()
	})

	app.OnRecordAfterDeleteSuccess("reviews").BindFunc(func(e *core.RecordEvent) error {
		if err := updateStoryRatingTransactional(e.App, e.Record.GetString("story")); err != nil {
			log.Printf("Failed to update story rating: %v", err)
		}
		return e.Next()
	})
}

func updateStoryRatingTransactional(app core.App, storyId string) error {
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

		reviewsCollection, err := txApp.FindCollectionByNameOrId("reviews")
		if err != nil {
			return err
		}

		safeStoryId := escapeFilter(storyId)
		filter := `story="` + safeStoryId + `"`

		reviews, err := txApp.FindRecordsByFilter(
			reviewsCollection.Id,
			filter,
			"-created",
			1000,
			0,
		)
		if err != nil {
			return err
		}

		if len(reviews) == 0 {
			story.Set("average_rating", nil)
			story.Set("review_count", 0)
		} else {
			var total float64
			for _, review := range reviews {
				total += review.GetFloat("rating")
			}
			average := total / float64(len(reviews))
			story.Set("average_rating", average)
			story.Set("review_count", len(reviews))
		}

		return txApp.Save(story)
	})
}
