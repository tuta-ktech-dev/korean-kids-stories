package main

import (
	"log"

	"github.com/pocketbase/pocketbase/core"
)

// SeedStories adds sample stories for testing
func SeedStories(app core.App) error {
	// Check if stories collection has any data
	storiesCollection, err := app.FindCollectionByNameOrId("stories")
	if err != nil {
		return err
	}

	// Check if already has stories
	existing, err := app.FindAllRecords(storiesCollection)
	if err != nil {
		return err
	}
	if len(existing) > 0 {
		log.Println("Stories already exist, skipping seed")
		return nil
	}

	log.Println("Seeding sample stories...")

	// Sample story 1: Heungbu and Nolbu
	story1 := core.NewRecord(storiesCollection)
	story1.Set("title", "흥부와 놀부")
	story1.Set("category", "folktale")
	story1.Set("age_min", 5)
	story1.Set("age_max", 8)
	story1.Set("summary", "A kind younger brother and a greedy older brother learn about the rewards of kindness and the consequences of greed.")
	story1.Set("total_chapters", 3)
	story1.Set("tags", []string{"kindness", "family", "traditional"})
	story1.Set("is_published", true)
	if err := app.Save(story1); err != nil {
		return err
	}

	// Sample story 2: The Woodcutter and the Fairy
	story2 := core.NewRecord(storiesCollection)
	story2.Set("title", "선녀와 나무꾼")
	story2.Set("category", "legend")
	story2.Set("age_min", 6)
	story2.Set("age_max", 10)
	story2.Set("summary", "A woodcutter falls in love with a heavenly fairy who descends to earth. A tale of love and sacrifice.")
	story2.Set("total_chapters", 5)
	story2.Set("tags", []string{"love", "fairy", "heaven"})
	story2.Set("is_published", true)
	if err := app.Save(story2); err != nil {
		return err
	}

	// Sample story 3: King Sejong
	story3 := core.NewRecord(storiesCollection)
	story3.Set("title", "세종대왕 이야기")
	story3.Set("category", "history")
	story3.Set("age_min", 8)
	story3.Set("age_max", 10)
	story3.Set("summary", "The story of King Sejong the Great, who created Hangul to help all Korean people read and write.")
	story3.Set("total_chapters", 4)
	story3.Set("tags", []string{"king", "hangul", "invention"})
	story3.Set("is_published", true)
	if err := app.Save(story3); err != nil {
		return err
	}

	log.Println("✅ Sample stories seeded successfully!")
	return nil
}
