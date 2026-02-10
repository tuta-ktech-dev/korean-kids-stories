package hooks

import (
	"fmt"
	"log"
	"time"

	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/core"
)

// XP constants (from docs/STICKER_SYSTEM.md)
const (
	xpChapterRead   = 10
	xpChapterListen = 15 // includes read
	xpStoryBonus    = 50
)

// Level thresholds (min XP to reach level N): Level 1: 0, L2: 100, L3: 250, ... L18: 31000+
var xpLevelThresholds = []float64{
	0, 100, 250, 500, 1000, 1750, 2500, 3500, 5000, 6500, 8500,
	11000, 14000, 17500, 21500, 26000, 31000,
}

func levelFromXP(totalXP float64) int {
	for i := len(xpLevelThresholds) - 1; i >= 0; i-- {
		if totalXP >= xpLevelThresholds[i] {
			return i + 1
		}
	}
	return 1
}

// RegisterReadingProgressHooks registers hooks for reading_progress (sticker, XP, level, streak)
func RegisterReadingProgressHooks(app *pocketbase.PocketBase) {
	app.OnRecordAfterCreateSuccess("reading_progress").BindFunc(func(e *core.RecordEvent) error {
		if e.Record.GetBool("is_completed") {
			if err := processChapterCompleted(e.App, e.Record); err != nil {
				log.Printf("reading_progress create: processChapterCompleted failed: %v", err)
			}
		}
		return e.Next()
	})

	app.OnRecordAfterUpdateSuccess("reading_progress").BindFunc(func(e *core.RecordEvent) error {
		oldCompleted := false
		if orig := e.Record.Original(); orig != nil {
			oldCompleted = orig.GetBool("is_completed")
		}
		newCompleted := e.Record.GetBool("is_completed")
		if !oldCompleted && newCompleted {
			if err := processChapterCompleted(e.App, e.Record); err != nil {
				log.Printf("reading_progress update: processChapterCompleted failed: %v", err)
			}
		}
		return e.Next()
	})
}

func processChapterCompleted(app core.App, progressRec *core.Record) error {
	userID := progressRec.GetString("user")
	chapterID := progressRec.GetString("chapter")
	if userID == "" || chapterID == "" {
		return nil
	}

	return app.RunInTransaction(func(txApp core.App) error {
		chaptersCol, err := txApp.FindCollectionByNameOrId("chapters")
		if err != nil {
			return err
		}
		chapter, err := txApp.FindRecordById(chaptersCol, chapterID)
		if err != nil {
			return err
		}
		storyID := chapter.GetString("story")
		if storyID == "" {
			return nil
		}

		// Check if user listened to this chapter (listening_sessions with completed=true)
		hasListen := false
		sessionsCol, err := txApp.FindCollectionByNameOrId("listening_sessions")
		if err == nil {
			filter := `user="` + escapeFilter(userID) + `" && chapter="` + escapeFilter(chapterID) + `" && completed=true`
			sessions, _ := txApp.FindRecordsByFilter(sessionsCol.Id, filter, "-created", 1, 0)
			hasListen = len(sessions) > 0
		}

		// XP for this chapter
		chapterXP := xpChapterRead
		if hasListen {
			chapterXP = xpChapterListen
		}

		// Get or create user_stats
		statsCol, err := txApp.FindCollectionByNameOrId("user_stats")
		if err != nil {
			return err
		}

		stats, _ := txApp.FindFirstRecordByFilter(statsCol.Id, `user="`+escapeFilter(userID)+`"`)
		newUser := stats == nil
		if stats == nil {
			stats = core.NewRecord(statsCol)
			stats.Set("user", userID)
			stats.Set("total_xp", float64(0))
			stats.Set("level", float64(1))
			stats.Set("streak_days", float64(0))
			stats.Set("chapters_read", float64(0))
			stats.Set("chapters_listened", float64(0))
			stats.Set("stories_completed", float64(0))
		}

		oldLevel := int(stats.GetFloat("level"))
		totalXP := stats.GetFloat("total_xp")
		chaptersRead := stats.GetFloat("chapters_read")
		chaptersListened := stats.GetFloat("chapters_listened")
		storiesCompleted := stats.GetFloat("stories_completed")
		streakDays := stats.GetFloat("streak_days")
		lastActivity := stats.GetString("last_activity_date")

		// Add XP and counters
		totalXP += float64(chapterXP)
		chaptersRead++
		if hasListen {
			chaptersListened++
		}

		// Streak
		today := time.Now().Format("2006-01-02")
		switch lastActivity {
		case "":
			streakDays = 1
		case today:
			// already active today, keep streak
		default:
			yesterday := time.Now().Add(-24 * time.Hour).Format("2006-01-02")
			if lastActivity == yesterday {
				streakDays++
			} else {
				streakDays = 1
			}
		}
		stats.Set("last_activity_date", today)

		// Check story completed
		storyCompleted := false
		storiesCol, err := txApp.FindCollectionByNameOrId("stories")
		if err == nil {
			story, err := txApp.FindRecordById(storiesCol, storyID)
			if err == nil {
				totalChapters := int(story.GetFloat("total_chapters"))
				if totalChapters > 0 {
					progressCol, _ := txApp.FindCollectionByNameOrId("reading_progress")
					if progressCol != nil {
						// Count completed chapters for this story by this user
						chaptersOfStory, _ := txApp.FindRecordsByFilter(
							chaptersCol.Id,
							`story="`+escapeFilter(storyID)+`"`,
							"chapter_number",
							500,
							0,
						)
						completedCount := 0
						for _, ch := range chaptersOfStory {
							cid := ch.Id
							filter := `user="` + escapeFilter(userID) + `" && chapter="` + escapeFilter(cid) + `" && is_completed=true`
							progs, _ := txApp.FindRecordsByFilter(progressCol.Id, filter, "", 1, 0)
							if len(progs) > 0 {
								completedCount++
							}
						}
						storyCompleted = completedCount >= totalChapters
					}
				}
			}
		}

		if storyCompleted {
			totalXP += xpStoryBonus
			storiesCompleted++

			// Unlock story sticker if has_sticker
			story, _ := txApp.FindRecordById(storiesCol, storyID)
			if story != nil && story.GetBool("has_sticker") {
				if err := unlockStorySticker(txApp, userID, storyID); err != nil {
					log.Printf("unlockStorySticker failed: %v", err)
				}
			}
		}

		// Level & level sticker
		newLevel := levelFromXP(totalXP)
		if newLevel > 18 {
			newLevel = 18
		}
		if newLevel > oldLevel {
			if err := unlockLevelSticker(txApp, userID, newLevel); err != nil {
				log.Printf("unlockLevelSticker failed: %v", err)
			}
		} else if newUser {
			// New user: unlock level 1 sticker (no level-up event since we start at 1)
			if err := unlockLevelSticker(txApp, userID, 1); err != nil {
				log.Printf("unlockLevelSticker(level 1) failed: %v", err)
			}
		}

		stats.Set("total_xp", totalXP)
		stats.Set("level", float64(newLevel))
		stats.Set("chapters_read", chaptersRead)
		stats.Set("chapters_listened", chaptersListened)
		stats.Set("stories_completed", storiesCompleted)
		stats.Set("streak_days", streakDays)

		return txApp.Save(stats)
	})
}

func unlockLevelSticker(app core.App, userID string, level int) error {
	if level < 1 || level > 18 {
		return nil
	}
	stickersCol, err := app.FindCollectionByNameOrId("stickers")
	if err != nil {
		return err
	}
	userStickersCol, err := app.FindCollectionByNameOrId("user_stickers")
	if err != nil {
		return err
	}

	key := fmt.Sprintf("level_%d", level)
	sticker, err := app.FindFirstRecordByFilter(stickersCol.Id, `type="level" && key="`+escapeFilter(key)+`"`)
	if err != nil || sticker == nil {
		return nil // level sticker may not exist yet (seed)
	}

	// Check if already unlocked
	existing, _ := app.FindRecordsByFilter(userStickersCol.Id,
		`user="`+escapeFilter(userID)+`" && sticker="`+escapeFilter(sticker.Id)+`"`, "", 1, 0)
	if len(existing) > 0 {
		return nil
	}

	us := core.NewRecord(userStickersCol)
	us.Set("user", userID)
	us.Set("sticker", sticker.Id)
	us.Set("unlock_source", "level_up")
	return app.Save(us)
}

func unlockStorySticker(app core.App, userID string, storyID string) error {
	stickersCol, err := app.FindCollectionByNameOrId("stickers")
	if err != nil {
		return err
	}
	userStickersCol, err := app.FindCollectionByNameOrId("user_stickers")
	if err != nil {
		return err
	}

	sticker, err := app.FindFirstRecordByFilter(stickersCol.Id,
		`type="story" && story="`+escapeFilter(storyID)+`"`)
	if err != nil || sticker == nil {
		return nil // story may not have sticker record yet
	}

	existing, _ := app.FindRecordsByFilter(userStickersCol.Id,
		`user="`+escapeFilter(userID)+`" && sticker="`+escapeFilter(sticker.Id)+`"`, "", 1, 0)
	if len(existing) > 0 {
		return nil
	}

	us := core.NewRecord(userStickersCol)
	us.Set("user", userID)
	us.Set("sticker", sticker.Id)
	us.Set("unlock_source", "story_complete")
	return app.Save(us)
}
