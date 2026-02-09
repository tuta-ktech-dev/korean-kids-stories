package main

import (
	"log"
	"os"

	"korean-kids-stories/schema"

	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/apis"
	"github.com/pocketbase/pocketbase/core"
)

func main() {
	app := pocketbase.New()

	// Ensure schema on startup
	app.OnServe().BindFunc(func(se *core.ServeEvent) error {
		schema.EnsureAllSchema(app)
		
		// Seed sample data if empty
		if err := SeedStories(app); err != nil {
			log.Printf("Failed to seed stories: %v", err)
		}
		
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
