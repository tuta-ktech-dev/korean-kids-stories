package schema

import (
	"log"

	"github.com/pocketbase/pocketbase/core"
)

// EnsureTrackingCollections ensures tracking collections exist
func EnsureTrackingCollections(app core.App) {
	EnsureReadingHistoryCollection(app)
	EnsureListeningSessionsCollection(app)
	EnsureSearchHistoryCollection(app)
	EnsureAppEventsCollection(app)
}

// Reading history - what user has read
func EnsureReadingHistoryCollection(app core.App) {
	usersCol, err := app.FindCollectionByNameOrId("users")
	if err != nil {
		log.Printf("Users collection not found, skipping reading_history creation")
		return
	}
	storiesCol, err := app.FindCollectionByNameOrId("stories")
	if err != nil {
		log.Printf("Stories collection not found, skipping reading_history creation")
		return
	}
	chaptersCol, err := app.FindCollectionByNameOrId("chapters")
	if err != nil {
		log.Printf("Chapters collection not found, skipping reading_history creation")
		return
	}

	collection, err := app.FindCollectionByNameOrId("reading_history")
	if err != nil {
		collection = core.NewBaseCollection("reading_history")
	}

	changes := false
	if SetRules(collection, "user = @request.auth.id", "user = @request.auth.id", "user = @request.auth.id", "", "") {
		changes = true
	}

	if collection.Fields.GetByName("user") == nil {
		collection.Fields.Add(&core.RelationField{
			Name:          "user",
			CollectionId:  usersCol.Id,
			Required:      true,
			MaxSelect:     1,
			CascadeDelete: true,
		})
		changes = true
	}
	if collection.Fields.GetByName("story") == nil {
		collection.Fields.Add(&core.RelationField{
			Name:          "story",
			CollectionId:  storiesCol.Id,
			Required:      true,
			MaxSelect:     1,
			CascadeDelete: false,
		})
		changes = true
	}
	if collection.Fields.GetByName("chapter") == nil {
		collection.Fields.Add(&core.RelationField{
			Name:          "chapter",
			CollectionId:  chaptersCol.Id,
			Required:      false,
			MaxSelect:     1,
			CascadeDelete: true,
		})
		changes = true
	}
	if AddSelectField(collection, "action", true, []string{"view", "read", "listen", "complete"}, 1) {
		changes = true
	}
	if AddNumberField(collection, "duration_seconds", false, nil, nil) {
		changes = true
	}
	if AddNumberField(collection, "progress_percent", false, Ptr(0.0), Ptr(100.0)) {
		changes = true
	}
	if AddTextField(collection, "device_info", false) {
		changes = true
	}

	if EnsureIndex(collection, "idx_history_user", false, "user", "") {
		changes = true
	}
	if EnsureIndex(collection, "idx_history_user_story", false, "user,story", "") {
		changes = true
	}

	if changes {
		SaveCollection(app, collection)
	}
}

// Listening sessions - track audio listening
func EnsureListeningSessionsCollection(app core.App) {
	usersCol, err := app.FindCollectionByNameOrId("users")
	if err != nil {
		log.Printf("Users collection not found, skipping listening_sessions creation")
		return
	}
	chaptersCol, err := app.FindCollectionByNameOrId("chapters")
	if err != nil {
		log.Printf("Chapters collection not found, skipping listening_sessions creation")
		return
	}

	collection, err := app.FindCollectionByNameOrId("listening_sessions")
	if err != nil {
		collection = core.NewBaseCollection("listening_sessions")
	}

	changes := false
	if SetRules(collection, "user = @request.auth.id", "user = @request.auth.id", "user = @request.auth.id", "user = @request.auth.id", "") {
		changes = true
	}

	if collection.Fields.GetByName("user") == nil {
		collection.Fields.Add(&core.RelationField{
			Name:          "user",
			CollectionId:  usersCol.Id,
			Required:      true,
			MaxSelect:     1,
			CascadeDelete: true,
		})
		changes = true
	}
	if collection.Fields.GetByName("chapter") == nil {
		collection.Fields.Add(&core.RelationField{
			Name:          "chapter",
			CollectionId:  chaptersCol.Id,
			Required:      true,
			MaxSelect:     1,
			CascadeDelete: true,
		})
		changes = true
	}
	if AddNumberField(collection, "start_position", false, nil, nil) {
		changes = true
	}
	if AddNumberField(collection, "end_position", false, nil, nil) {
		changes = true
	}
	if AddNumberField(collection, "duration_listened", true, Ptr(0.0), nil) {
		changes = true
	}
	if AddBoolField(collection, "completed") {
		changes = true
	}
	if AddTextField(collection, "device_info", false) {
		changes = true
	}

	if changes {
		SaveCollection(app, collection)
	}
}

// Search history
func EnsureSearchHistoryCollection(app core.App) {
	usersCol, err := app.FindCollectionByNameOrId("users")
	if err != nil {
		log.Printf("Users collection not found, skipping search_history creation")
		return
	}

	collection, err := app.FindCollectionByNameOrId("search_history")
	if err != nil {
		collection = core.NewBaseCollection("search_history")
	}

	changes := false
	if SetRules(collection, "user = @request.auth.id", "user = @request.auth.id", "user = @request.auth.id", "", "") {
		changes = true
	}

	if collection.Fields.GetByName("user") == nil {
		collection.Fields.Add(&core.RelationField{
			Name:          "user",
			CollectionId:  usersCol.Id,
			Required:      true,
			MaxSelect:     1,
			CascadeDelete: true,
		})
		changes = true
	}
	if AddTextField(collection, "query", true) {
		changes = true
	}
	if AddSelectField(collection, "search_type", true, []string{"story", "category", "general"}, 1) {
		changes = true
	}
	if AddNumberField(collection, "results_count", false, nil, nil) {
		changes = true
	}
	if AddBoolField(collection, "clicked_result") {
		changes = true
	}

	if EnsureIndex(collection, "idx_search_user", false, "user", "") {
		changes = true
	}

	if changes {
		SaveCollection(app, collection)
	}
}

// App events - general analytics
func EnsureAppEventsCollection(app core.App) {
	usersCol, err := app.FindCollectionByNameOrId("users")
	if err != nil {
		log.Printf("Users collection not found, skipping app_events creation")
		return
	}

	collection, err := app.FindCollectionByNameOrId("app_events")
	if err != nil {
		collection = core.NewBaseCollection("app_events")
	}

	changes := false
	// Events are anonymous or user-linked
	if SetRules(collection, "", "", "@request.auth.id != ''", "", "") {
		changes = true
	}

	if collection.Fields.GetByName("user") == nil {
		collection.Fields.Add(&core.RelationField{
			Name:          "user",
			CollectionId:  usersCol.Id,
			Required:      false,
			MaxSelect:     1,
			CascadeDelete: true,
		})
		changes = true
	}
	if AddSelectField(collection, "event_type", true, []string{
		"app_open", "app_close", "screen_view", "button_click",
		"story_favorite", "story_share", "download", "signup", "login", "logout",
	}, 1) {
		changes = true
	}
	if AddTextField(collection, "screen_name", false) {
		changes = true
	}
	if AddTextField(collection, "button_name", false) {
		changes = true
	}
	if AddJSONField(collection, "event_data", false) {
		changes = true
	}
	if AddTextField(collection, "device_id", false) {
		changes = true
	}
	if AddTextField(collection, "device_info", false) {
		changes = true
	}
	if AddTextField(collection, "session_id", false) {
		changes = true
	}

	if EnsureIndex(collection, "idx_events_type", false, "event_type", "") {
		changes = true
	}
	if EnsureIndex(collection, "idx_events_user", false, "user", "") {
		changes = true
	}
	if EnsureIndex(collection, "idx_events_session", false, "session_id", "") {
		changes = true
	}

	if changes {
		SaveCollection(app, collection)
	}
}
