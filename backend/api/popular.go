package api

import (
	"os"

	"korean-kids-stories/schema"

	"github.com/pocketbase/pocketbase/core"
)

// RegisterPopularRoutes adds GET /api/popular-searches and internal refresh
func RegisterPopularRoutes(se *core.ServeEvent) {
	se.Router.GET("/api/popular-searches", popularHandler(se.App))
	se.Router.POST("/api/internal/refresh-popular", refreshPopularHandler(se.App))
}

func popularHandler(app core.App) func(*core.RequestEvent) error {
	return func(e *core.RequestEvent) error {
		cacheCol, err := app.FindCollectionByNameOrId("popular_searches_cache")
		if err != nil {
			return e.JSON(500, map[string]string{"error": "cache not found"})
		}

		// Check if cache is stale (older than 24h)
		records, err := app.FindRecordsByFilter(
			cacheCol.Id,
			"",
			"-hit_count",
			20,
			0,
		)
		if err != nil {
			return e.JSON(500, map[string]string{"error": err.Error()})
		}

		// If empty, try refresh (e.g. first run)
		if len(records) == 0 {
			_ = schema.RefreshPopularSearchesCache(app)
			records, _ = app.FindRecordsByFilter(cacheCol.Id, "", "-hit_count", 20, 0)
		}

		queries := make([]string, 0, len(records))
		for _, r := range records {
			if q := r.GetString("query"); q != "" {
				queries = append(queries, q)
			}
		}

		e.Response.Header().Set("Cache-Control", "public, max-age=86400")
		return e.JSON(200, map[string]any{"queries": queries})
	}
}

func refreshPopularHandler(app core.App) func(*core.RequestEvent) error {
	return func(e *core.RequestEvent) error {
		// Require cron secret (set in env)
		secret := e.Request.Header.Get("X-Cron-Secret")
		if secret == "" || secret != getCronSecret() {
			return e.JSON(401, map[string]string{"error": "unauthorized"})
		}

		if err := schema.RefreshPopularSearchesCache(app); err != nil {
			return e.JSON(500, map[string]string{"error": err.Error()})
		}
		return e.JSON(200, map[string]string{"status": "ok"})
	}
}

func getCronSecret() string {
	if s := os.Getenv("CRON_SECRET"); s != "" {
		return s
	}
	return "change-me-in-production"
}
