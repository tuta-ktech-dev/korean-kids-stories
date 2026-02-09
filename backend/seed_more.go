package main

import (
	"fmt"
	"log"
	"os"

	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/core"
)

// SeedMoreStories adds more Korean stories for testing
func SeedMoreStories(app core.App) error {
	storiesCollection, err := app.FindCollectionByNameOrId("stories")
	if err != nil {
		return fmt.Errorf("stories collection not found: %v", err)
	}

	chaptersCollection, err := app.FindCollectionByNameOrId("chapters")
	if err != nil {
		return fmt.Errorf("chapters collection not found: %v", err)
	}

	log.Println("Seeding more Korean stories...")

	// Story 1: The Rabbit and the Turtle (토끼와 거북이)
	story1 := core.NewRecord(storiesCollection)
	story1.Set("title", "토끼와 거북이")
	story1.Set("category", "folktale")
	story1.Set("age_min", 4)
	story1.Set("age_max", 7)
	story1.Set("summary", "A classic tale about a speedy rabbit and a slow but steady turtle who have a race. Teaches children about patience and perseverance.")
	story1.Set("total_chapters", 2)
	story1.Set("tags", []string{"animals", "race", "patience", "classic"})
	story1.Set("is_published", true)
	if err := app.Save(story1); err != nil {
		return fmt.Errorf("failed to save story1: %v", err)
	}

	// Chapters for story 1
	chapter1_1 := core.NewRecord(chaptersCollection)
	chapter1_1.Set("story", story1.Id)
	chapter1_1.Set("chapter_number", 1)
	chapter1_1.Set("title", "레이스가 시작되다")
	chapter1_1.Set("content", "옛날 옛적에 토끼와 거북이가 살았습니다. 토끼는 매우 빨랐고, 거북이는 매우 느렸습니다.\n\n어느 날, 토끼가 거북이에게 말했습니다. \"너는 너무 느려! 나와 레이스를 합시다.\"\n\n거북이는 대답했습니다. \"좋아요. 꼭 이길 거예요!\"\n\n모든 동물들이 레이스를 보기 위해 모였습니다. 코끼리 심판이 외쳤습니다. \"준비... 시작!\"")
	chapter1_1.Set("is_free", true)
	if err := app.Save(chapter1_1); err != nil {
		return fmt.Errorf("failed to save chapter1_1: %v", err)
	}

	chapter1_2 := core.NewRecord(chaptersCollection)
	chapter1_2.Set("story", story1.Id)
	chapter1_2.Set("chapter_number", 2)
	chapter1_2.Set("title", "거북이가 이기다")
	chapter1_2.Set("content", "토끼는 매우 빨리 달렸습니다. 금방 거북이를 멀리 뒤로 밀어냈죠.\n\n\"이 거북이는 너무 느려. 난 잠깐 쉬어도 이길 수 있어.\"\n\n토끼는 나무 아래에서 잠이 들었습니다.\n\n한편, 거북이는 천천히 그치만 멈추지 않고 걸었습니다.\n\n결국 거북이가 결승선에 먼저 도착했습니다! 모든 동물들이 환호했습니다.\n\n토끼가 깨어났을 때는 이미 늦었습니다. 거북이가 이긴 것이죠.\n\n교훈: 느리지만 꾸준한 것이 이긴다는 것을 배웠습니다.")
	chapter1_2.Set("is_free", true)
	if err := app.Save(chapter1_2); err != nil {
		return fmt.Errorf("failed to save chapter1_2: %v", err)
	}

	// Story 2: The Sun and the Moon (해와 달)
	story2 := core.NewRecord(storiesCollection)
	story2.Set("title", "해와 달이 된 오눀이")
	story2.Set("category", "legend")
	story2.Set("age_min", 6)
	story2.Set("age_max", 9)
	story2.Set("summary", "A touching Korean legend about two siblings who become the sun and the moon. Teaches about sibling love and sacrifice.")
	story2.Set("total_chapters", 3)
	story2.Set("tags", []string{"siblings", "sacrifice", "celestial", "love"})
	story2.Set("is_published", true)
	if err := app.Save(story2); err != nil {
		return fmt.Errorf("failed to save story2: %v", err)
	}

	// Chapters for story 2
	chapter2_1 := core.NewRecord(chaptersCollection)
	chapter2_1.Set("story", story2.Id)
	chapter2_1.Set("chapter_number", 1)
	chapter2_1.Set("title", "마음씨 고운 남매")
	chapter2_1.Set("content", "옛날에 어떤 마을에 오누이가 살았습니다. 오빠는 허준, 여동생은 미나였습니다.\n\n부모님이 돌아가시자 오누이는 서로를 아끼며 살았습니다.\n\n어느 날, 마을에 호랑이가 나타났습니다. 모든 사람들이 무서워하며 집에 숨었습니다.")
	chapter2_1.Set("is_free", true)
	if err := app.Save(chapter2_1); err != nil {
		return fmt.Errorf("failed to save chapter2_1: %v", err)
	}

	chapter2_2 := core.NewRecord(chaptersCollection)
	chapter2_2.Set("story", story2.Id)
	chapter2_2.Set("chapter_number", 2)
	chapter2_2.Set("title", "호랑이의 위협")
	chapter2_2.Set("content", "호랑이가 오누이의 집에 찾아왔습니다. \"문 열어! 안 열으면 부순다!\"\n\n허준이 여동생을 숨기고 말했습니다. \"미나야, 천장에 숨어 있어. 절대 나이지 마.\"\n\n허준은 문 밖으로 나갔습니다. \"나 따라가. 여동생은 건드리지 마.\"\n\n호랑이는 허준을 데리고 산으로 갔습니다.")
	chapter2_2.Set("is_free", false)
	if err := app.Save(chapter2_2); err != nil {
		return fmt.Errorf("failed to save chapter2_2: %v", err)
	}

	chapter2_3 := core.NewRecord(chaptersCollection)
	chapter2_3.Set("story", story2.Id)
	chapter2_3.Set("chapter_number", 3)
	chapter2_3.Set("title", "해와 달이 되다")
	chapter2_3.Set("content", "미나는 오빠를 구하기 위해 산으로 갔습니다. 강을 건 너머 큰 돌 하나가 보였습니다.\n\n그때 하늘에서 신이 날아왔습니다. \"마음씨 고운 아이들이여, 너희를 하늘에 모시겠다.\"\n\n허준은 눈부신 해가 되어 세상을 밝히고, 미나는 은은한 달이 되어 밤을 비추게 되었습니다.\n\n그래서 오누이는 지금도 하늘에서 함께 살고 있습니다.")
	chapter2_3.Set("is_free", false)
	if err := app.Save(chapter2_3); err != nil {
		return fmt.Errorf("failed to save chapter2_3: %v", err)
	}

	// Story 3: Admiral Yi Sun-sin (이순신 장군)
	story3 := core.NewRecord(storiesCollection)
	story3.Set("title", "이순신 장군의 거북선")
	story3.Set("category", "history")
	story3.Set("age_min", 8)
	story3.Set("age_max", 10)
	story3.Set("summary", "The story of Korea's greatest naval admiral and his famous turtle ships that defended Korea from Japanese invasion.")
	story3.Set("total_chapters", 4)
	story3.Set("tags", []string{"admiral", "navy", "turtle-ship", "hero", "war"})
	story3.Set("is_published", true)
	if err := app.Save(story3); err != nil {
		return fmt.Errorf("failed to save story3: %v", err)
	}

	// Chapters for story 3
	chapter3_1 := core.NewRecord(chaptersCollection)
	chapter3_1.Set("story", story3.Id)
	chapter3_1.Set("chapter_number", 1)
	chapter3_1.Set("title", "나라를 지키는 장군")
	chapter3_1.Set("content", "조선시대, 이순신 장군이 살았습니다. 그는 매우 용감하고 똑똑한 장군이었습니다.\n\n1592년, 일본이 조선을 침략했습니다. 이순신 장군은 수군을 이끌고 싸웠습니다.\n\n처음엔 배가 적어 힘들었지만, 장군은 절대 포기하지 않았습니다.")
	chapter3_1.Set("is_free", true)
	if err := app.Save(chapter3_1); err != nil {
		return fmt.Errorf("failed to save chapter3_1: %v", err)
	}

	chapter3_2 := core.NewRecord(chaptersCollection)
	chapter3_2.Set("story", story3.Id)
	chapter3_2.Set("chapter_number", 2)
	chapter3_2.Set("title", "거북선이 나타나다")
	chapter3_2.Set("content", "이순신 장군은 특별한 배를 만들었습니다. 거북이 등껍질처럼 생긴 '거북선'이었죠.\n\n거북선은 철갑으로 둘러싸여 있어 적의 포를 막을 수 있었습니다.\n\n배 위에는 용 머리가 있어서 적을 위협했습니다.")
	chapter3_2.Set("is_free", true)
	if err := app.Save(chapter3_2); err != nil {
		return fmt.Errorf("failed to save chapter3_2: %v", err)
	}

	chapter3_3 := core.NewRecord(chaptersCollection)
	chapter3_3.Set("story", story3.Id)
	chapter3_3.Set("chapter_number", 3)
	chapter3_3.Set("title", "한산도 대첩")
	chapter3_3.Set("content", "1592년 7월, 한산도 앞바다에서 큰 전투가 벌어졌습니다.\n\n이순신 장군은 12척의 배로 133척의 적선을 맞서 싸웠습니다.\n\n거북선을 앞세워 용감하게 돌진했고, 조선군은 큰 승리를 거두었습니다.")
	chapter3_3.Set("is_free", false)
	if err := app.Save(chapter3_3); err != nil {
		return fmt.Errorf("failed to save chapter3_3: %v", err)
	}

	chapter3_4 := core.NewRecord(chaptersCollection)
	chapter3_4.Set("story", story3.Id)
	chapter3_4.Set("chapter_number", 4)
	chapter3_4.Set("title", "나라를 구한 영웅")
	chapter3_4.Set("content", "이순신 장군은 총 23번의 전투에서 모두 이겼습니다. 한 번도 진 적이 없었죠!\n\n1598년 노량해전에서 장군은 전사했지만, 그의 용기는 영원히 기억됩니다.\n\n지금도 한국 사람들은 이순신 장군을 가장 위대한 영웅으로 생각합니다.")
	chapter3_4.Set("is_free", false)
	if err := app.Save(chapter3_4); err != nil {
		return fmt.Errorf("failed to save chapter3_4: %v", err)
	}

	log.Println("✅ Successfully seeded 3 more stories with 9 chapters!")
	return nil
}

func main() {
	app := pocketbase.New()

	app.OnServe().BindFunc(func(se *core.ServeEvent) error {
		// Seed more stories
		if err := SeedMoreStories(app); err != nil {
			log.Printf("Failed to seed stories: %v", err)
		}
		return se.Next()
	})

	if err := app.Start(); err != nil {
		log.Fatal(err)
	}
}
