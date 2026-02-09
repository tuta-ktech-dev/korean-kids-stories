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

	// Setup hooks for auto-updating counts
	SetupHooks(app)

	// Ensure schema on startup
	app.OnServe().BindFunc(func(se *core.ServeEvent) error {
		schema.EnsureAllSchema(app)

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
