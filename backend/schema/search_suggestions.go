package schema

import (
	"log"
	"strings"

	"github.com/pocketbase/pocketbase/core"
)

// popular_searches_cache: aggregated from search_history, refreshed daily
func EnsurePopularSearchesCacheCollection(app core.App) {
	collection, err := app.FindCollectionByNameOrId("popular_searches_cache")
	if err != nil {
		collection = core.NewBaseCollection("popular_searches_cache")
	}

	changes := false
	// List/View: public. Create/Update/Delete: allow for cron (no auth in goroutine)
	if SetRules(collection, "id != ''", "id != ''", "query != ''", "id != ''", "id != ''") {
		changes = true
	}

	if AddTextField(collection, "query", true) {
		changes = true
	}
	if AddNumberField(collection, "hit_count", false, Ptr(0.0), nil) {
		changes = true
	}

	if AddSystemFields(collection) {
		changes = true
	}

	if EnsureIndex(collection, "idx_popular_hit_count", false, "hit_count", "") {
		changes = true
	}

	if changes {
		SaveCollection(app, collection)
	}
}

// RefreshPopularSearchesCache aggregates search_history and writes to popular_searches_cache.
// Paginates through search_history (bypasses per-user filter when no auth context).
func RefreshPopularSearchesCache(app core.App) error {
	historyCol, err := app.FindCollectionByNameOrId("search_history")
	if err != nil {
		return err
	}
	cacheCol, err := app.FindCollectionByNameOrId("popular_searches_cache")
	if err != nil {
		return err
	}

	// Aggregate: page through all search_history
	counts := make(map[string]int)
	for page := 1; ; page++ {
		records, err := app.FindRecordsByFilter(
			historyCol.Id,
			`query != ""`,
			"created",
			500,
			(page-1)*500,
		)
		if err != nil || len(records) == 0 {
			break
		}
		for _, r := range records {
			q := strings.TrimSpace(r.GetString("query"))
			if q != "" {
				counts[q]++
			}
		}
		if len(records) < 500 {
			break
		}
	}

	// Sort by count, take top 20
	type kv struct {
		k string
		v int
	}
	var sorted []kv
	for k, v := range counts {
		sorted = append(sorted, kv{k, v})
	}
	for i := 0; i < len(sorted)-1; i++ {
		for j := i + 1; j < len(sorted); j++ {
			if sorted[j].v > sorted[i].v {
				sorted[i], sorted[j] = sorted[j], sorted[i]
			}
		}
	}
	limit := 20
	if len(sorted) < limit {
		limit = len(sorted)
	}

	// Clear cache
	existing, _ := app.FindRecordsByFilter(cacheCol.Id, "", "-hit_count", 1000, 0)
	for _, r := range existing {
		_ = app.Delete(r)
	}

	// Insert top N, or fallback defaults when search_history is empty
	if limit == 0 {
		defaults := []string{"흥부와 놀부", "선녀와 나무꾼", "이순신", "거북선", "토끼"}
		for i, q := range defaults {
			rec := core.NewRecord(cacheCol)
			rec.Set("query", q)
			rec.Set("hit_count", len(defaults)-i)
			if err := app.Save(rec); err != nil {
				log.Printf("popular_searches: save failed: %v", err)
			}
		}
		log.Printf("popular_searches: seeded %d default terms", len(defaults))
	} else {
		for i := 0; i < limit; i++ {
			rec := core.NewRecord(cacheCol)
			rec.Set("query", sorted[i].k)
			rec.Set("hit_count", sorted[i].v)
			if err := app.Save(rec); err != nil {
				log.Printf("popular_searches: save failed: %v", err)
			}
		}
		log.Printf("popular_searches: refreshed %d terms from search_history", limit)
	}
	return nil
}
