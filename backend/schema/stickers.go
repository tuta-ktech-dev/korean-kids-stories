package schema

import (
	"fmt"
	"log"

	"github.com/pocketbase/pocketbase/core"
)

// levelRanks: 조선 관직 품계 (Level 1=lowest to 18=highest)
var levelRanks = []struct {
	rankKo string
	nameKo string
}{
	{"종9품", "장사랑"},
	{"정9품", "감사랑"},
	{"종8품", "인순부위"},
	{"정8품", "통덕랑"},
	{"종7품", "겸인순부위"},
	{"정7품", "사과"},
	{"종6품", "승정랑"},
	{"정6품", "수문장"},
	{"종5품", "통선랑"},
	{"정5품", "통덕랑"},
	{"종4품", "봉정대부"},
	{"정4품", "봉렬대부"},
	{"종3품", "통정대부"},
	{"정3품", "통훈대부"},
	{"종2품", "가선대부"},
	{"정2품", "자헌대부"},
	{"종1품", "숭정대부"},
	{"정1품", "대광보국숭록대부"},
}

// SeedLevelStickers creates 18 level stickers if they don't exist
func SeedLevelStickers(app core.App) {
	col, err := app.FindCollectionByNameOrId("stickers")
	if err != nil {
		return
	}
	for i, r := range levelRanks {
		level := float64(i + 1)
		key := "level_" + fmt.Sprint(i+1)

		existing, _ := app.FindRecordsByFilter(col.Id, "key=\""+escapeFilter(key)+"\"", "", 1, 0)
		if len(existing) > 0 {
			continue
		}
		rec := core.NewRecord(col)
		rec.Set("type", "level")
		rec.Set("key", key)
		rec.Set("level", level)
		rec.Set("rank_ko", r.rankKo)
		rec.Set("name_ko", r.nameKo)
		rec.Set("sort_order", float64(i+1))
		rec.Set("is_published", true)
		if err := app.Save(rec); err != nil {
			log.Printf("stickers: seed level_%d failed: %v", i+1, err)
		} else {
			log.Printf("stickers: seeded level_%d %s", i+1, r.nameKo)
		}
	}
}

// EnsureStickersCollection ensures the stickers collection exists.
// Type: level (관직) | story
func EnsureStickersCollection(app core.App) {
	storiesCollection, _ := app.FindCollectionByNameOrId("stories")

	collection, err := app.FindCollectionByNameOrId("stickers")
	if err != nil {
		collection = core.NewBaseCollection("stickers")
	}

	changes := false
	// List/view: public read for published stickers (guest can see level stickers)
	if SetRules(collection, "is_published = true", "is_published = true", "", "", "") {
		changes = true
	}

	if AddSelectField(collection, "type", true, []string{"level", "story"}, 1) {
		changes = true
	}
	if AddTextField(collection, "key", true) {
		changes = true
	}
	if AddTextField(collection, "name_ko", true) {
		changes = true
	}
	if AddTextField(collection, "description_ko", false) {
		changes = true
	}
	if AddFileField(collection, "image", 1, 2097152, []string{"image/jpeg", "image/png", "image/webp"}) {
		changes = true
	}
	if AddNumberField(collection, "sort_order", false, Ptr(0.0), nil) {
		changes = true
	}
	if AddBoolField(collection, "is_published") {
		changes = true
	}
	// For type=level: level (1-18), rank_ko (품계)
	if AddNumberField(collection, "level", false, Ptr(1.0), Ptr(18.0)) {
		changes = true
	}
	if AddTextField(collection, "rank_ko", false) {
		changes = true
	}
	// For type=story: relation to stories
	if storiesCollection != nil && collection.Fields.GetByName("story") == nil {
		collection.Fields.Add(&core.RelationField{
			Name:          "story",
			CollectionId:  storiesCollection.Id,
			Required:      false,
			MaxSelect:     1,
			CascadeDelete: false,
		})
		changes = true
	}

	if AddSystemFields(collection) {
		changes = true
	}

	if EnsureIndex(collection, "idx_stickers_type", false, "type", "") {
		changes = true
	}
	if EnsureIndex(collection, "idx_stickers_key", true, "key", "") {
		changes = true
	}

	if changes {
		SaveCollection(app, collection)
	}
}
