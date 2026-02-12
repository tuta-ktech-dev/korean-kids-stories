package hooks

import (
	"log"

	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/core"
)

// RegisterChapterAudiosHooks cập nhật stories.has_audio khi chapter_audios thay đổi
func RegisterChapterAudiosHooks(app *pocketbase.PocketBase) {
	app.OnRecordAfterCreateSuccess("chapter_audios").BindFunc(func(e *core.RecordEvent) error {
		if err := syncStoryHasAudio(app, e.Record.GetString("chapter")); err != nil {
			log.Printf("chapter_audios hook: %v", err)
		}
		return e.Next()
	})

	app.OnRecordAfterDeleteSuccess("chapter_audios").BindFunc(func(e *core.RecordEvent) error {
		if err := syncStoryHasAudio(app, e.Record.GetString("chapter")); err != nil {
			log.Printf("chapter_audios hook: %v", err)
		}
		return e.Next()
	})
}

// syncStoryHasAudio: chapterId -> chapter.story -> đếm chapter_audios của story -> set has_audio
func syncStoryHasAudio(app core.App, chapterId string) error {
	if chapterId == "" {
		return nil
	}

	return app.RunInTransaction(func(txApp core.App) error {
		chaptersCollection, err := txApp.FindCollectionByNameOrId("chapters")
		if err != nil {
			return err
		}
		chapter, err := txApp.FindRecordById(chaptersCollection, chapterId)
		if err != nil {
			return err
		}
		storyId := chapter.GetString("story")
		if storyId == "" {
			return nil
		}

		// Lấy tất cả chapter của story
		safeStoryId := escapeFilter(storyId)
		chapters, err := txApp.FindRecordsByFilter(
			chaptersCollection.Id,
			`story="`+safeStoryId+`"`,
			"chapter_number",
			500,
			0,
		)
		if err != nil {
			return err
		}

		chapterAudiosCollection, err := txApp.FindCollectionByNameOrId("chapter_audios")
		if err != nil {
			return err
		}

		hasAny := false
		if len(chapters) > 0 {
			// Filter: chapter in (id1, id2, ...) - chỉ cần 1 record để biết có audio
			var orParts []string
			for _, ch := range chapters {
				orParts = append(orParts, `chapter="`+escapeFilter(ch.Id)+`"`)
			}
			filter := orParts[0]
			for i := 1; i < len(orParts); i++ {
				filter += " || " + orParts[i]
			}
			audios, err := txApp.FindRecordsByFilter(
				chapterAudiosCollection.Id,
				filter,
				"-created",
				1,
				0,
			)
			hasAny = err == nil && len(audios) > 0
		}

		storiesCollection, err := txApp.FindCollectionByNameOrId("stories")
		if err != nil {
			return err
		}
		story, err := txApp.FindRecordById(storiesCollection, storyId)
		if err != nil {
			return err
		}
		story.Set("has_audio", hasAny)
		return txApp.Save(story)
	})
}
