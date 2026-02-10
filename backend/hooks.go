package main

import (
	"log"
	"strings"
	"time"

	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/core"
)

// SetupHooks configures all Pocketbase hooks
func SetupHooks(app *pocketbase.PocketBase) {
	// Hook: Auto increment view_count when a view is created
	app.OnRecordCreateRequest("views").BindFunc(func(e *core.RecordRequestEvent) error {
		// Get the story being viewed
		storyId := e.Record.GetString("story")
		if storyId == "" {
			return e.Next()
		}

		// Check for duplicate view (same user or IP within 1 hour)
		if !isDuplicateView(app, e.Record, storyId) {
			// Increment view_count with transaction (race-condition safe)
			if err := incrementViewCountAtomic(app, storyId); err != nil {
				log.Printf("Failed to increment view count: %v", err)
			}
		}

		return e.Next()
	})

	// Hook: Update story average rating when a review is created/updated/deleted
	app.OnRecordCreateRequest("reviews").BindFunc(func(e *core.RecordRequestEvent) error {
		if err := updateStoryRatingTransactional(app, e.Record.GetString("story")); err != nil {
			log.Printf("Failed to update story rating: %v", err)
		}
		return e.Next()
	})

	app.OnRecordUpdateRequest("reviews").BindFunc(func(e *core.RecordRequestEvent) error {
		if err := updateStoryRatingTransactional(app, e.Record.GetString("story")); err != nil {
			log.Printf("Failed to update story rating: %v", err)
		}
		return e.Next()
	})

	app.OnRecordDeleteRequest("reviews").BindFunc(func(e *core.RecordRequestEvent) error {
		if err := updateStoryRatingTransactional(app, e.Record.GetString("story")); err != nil {
			log.Printf("Failed to update story rating: %v", err)
		}
		return e.Next()
	})

	// Hook: Update story favorite_count and bookmark_count when bookmarks change
	app.OnRecordCreateRequest("bookmarks").BindFunc(func(e *core.RecordRequestEvent) error {
		if err := updateStoryBookmarkCountsTransactional(app, e.Record.GetString("story")); err != nil {
			log.Printf("Failed to update story bookmark counts: %v", err)
		}
		return e.Next()
	})

	app.OnRecordUpdateRequest("bookmarks").BindFunc(func(e *core.RecordRequestEvent) error {
		// Need to update both old and new story (in case type/story changed)
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

	log.Println("✅ Hooks configured successfully")
}

// uniqueStoryIds returns unique non-empty story IDs
func uniqueStoryIds(ids ...string) []string {
	seen := make(map[string]bool)
	var result []string
	for _, id := range ids {
		if id != "" && !seen[id] {
			seen[id] = true
			result = append(result, id)
		}
	}
	return result
}

// escapeFilter escapes special characters in filter strings to prevent injection
func escapeFilter(s string) string {
	s = strings.ReplaceAll(s, `\`, `\\`)
	s = strings.ReplaceAll(s, `"`, `\"`)
	s = strings.ReplaceAll(s, `'`, `\'`)
	return s
}

// isDuplicateView checks if this is a duplicate view (same user/IP within 1 hour)
func isDuplicateView(app core.App, viewRecord *core.Record, storyId string) bool {
	userId := viewRecord.GetString("user")
	ipAddress := viewRecord.GetString("ip_address")

	viewsCollection, err := app.FindCollectionByNameOrId("views")
	if err != nil {
		return false
	}

	// Escape inputs to prevent filter injection
	safeStoryId := escapeFilter(storyId)
	cutoffTime := time.Now().Add(-1 * time.Hour).Format(time.RFC3339)

	// Build filter with escaped values
	var filter string
	if userId != "" {
		safeUserId := escapeFilter(userId)
		filter = `story="` + safeStoryId + `" && user="` + safeUserId + `" && created>="` + cutoffTime + `"`
	} else if ipAddress != "" {
		safeIp := escapeFilter(ipAddress)
		filter = `story="` + safeStoryId + `" && ip_address="` + safeIp + `" && created>="` + cutoffTime + `"`
	} else {
		return false // No way to track uniqueness
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

// incrementViewCountAtomic increments view_count using transaction (race-condition safe)
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

		// Atomic increment within transaction
		currentCount := story.GetInt("view_count")
		story.Set("view_count", currentCount+1)

		return txApp.Save(story)
	})
}

// updateStoryRatingTransactional updates rating using transaction
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

		// Escape storyId for filter
		safeStoryId := escapeFilter(storyId)
		filter := `story="` + safeStoryId + `"`

		// Get all reviews for this story
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

		// Calculate average
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

// updateStoryBookmarkCountsTransactional updates favorite_count and bookmark_count from bookmarks
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
