package main

import (
	"log"
	"os"
	"time"

	"korean-kids-stories/api"
	"korean-kids-stories/hooks"
	"korean-kids-stories/schema"

	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/apis"
	"github.com/pocketbase/pocketbase/core"
)

func main() {
	app := pocketbase.New()

	// Setup hooks for auto-updating counts
	hooks.SetupHooks(app)

	// Ensure schema on startup
	app.OnServe().BindFunc(func(se *core.ServeEvent) error {
		schema.EnsureAllSchema(app)
		schema.SeedAppConfig(app)
		schema.SeedContentPages(app)
		api.RegisterPopularRoutes(se)

		// Refresh popular searches every 24h
		go runPopularRefreshCron(app)

		return se.Next()
	})

	// Serve static files (pb_public)
	app.OnServe().BindFunc(func(se *core.ServeEvent) error {
		se.Router.GET("/*", apis.Static(os.DirFS("./pb_public"), false))
		return se.Next()
	})

	// Start the application
	if err := app.Start(); err != nil {
		log.Fatal(err)
	}
}

func runPopularRefreshCron(app core.App) {
	ticker := time.NewTicker(24 * time.Hour)
	defer ticker.Stop()
	// Initial refresh after 1 min (let DB be ready)
	time.Sleep(1 * time.Minute)
	schema.RefreshPopularSearchesCache(app)
	for range ticker.C {
		schema.RefreshPopularSearchesCache(app)
	}
}
