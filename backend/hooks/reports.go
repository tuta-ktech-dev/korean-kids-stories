package hooks

import (
	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/core"
)

// RegisterReportsHooks registers hooks for the reports collection
func RegisterReportsHooks(app *pocketbase.PocketBase) {
	app.OnRecordCreateRequest("reports").BindFunc(func(e *core.RecordRequestEvent) error {
		if e.Auth != nil {
			e.Record.Set("user", e.Auth.Id)
		}
		return e.Next()
	})
}
