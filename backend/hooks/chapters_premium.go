package hooks

import (
	"regexp"
	"strings"
	"time"

	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/core"
)

const deviceIDHeader = "X-Device-ID"

var premiumProductIDs = []string{
	"com.hbstore.koreankids.monthly",
	"com.hbstore.koreankids.threemonth",
	"com.hbstore.koreankids.yearly",
}

// chapterFilterRe extracts chapter="xxx" from filter string
var chapterFilterRe = regexp.MustCompile(`chapter\s*=\s*"([^"]+)"`)

// RegisterChaptersPremiumHooks gates chapter_audios for locked chapters (is_free=false)
func RegisterChaptersPremiumHooks(app *pocketbase.PocketBase) {
	// Chapter is_free=false + user not premium → no audio
	app.OnRecordsListRequest("chapter_audios").BindFunc(func(e *core.RecordsListRequestEvent) error {
		if err := e.Next(); err != nil {
			return err
		}
		chapterID := extractChapterIDFromFilter(e.Request.URL.Query().Get("filter"))
		if chapterID == "" {
			return nil // no chapter filter, leave as-is
		}
		chapter, err := app.FindRecordById("chapters", chapterID)
		if err != nil || chapter == nil {
			return nil
		}
		if chapter.GetBool("is_free") {
			return nil // free chapter, everyone gets audio
		}
		if !checkDevicePremium(e.App, e.Request.Header.Get(deviceIDHeader)) {
			e.Records = []*core.Record{}
		}
		return nil
	})

	app.OnRecordsListRequest("chapters").BindFunc(func(e *core.RecordsListRequestEvent) error {
		if err := e.Next(); err != nil {
			return err
		}
		addIsPremiumToRecords(e.App, e.Records, e.Request.Header.Get(deviceIDHeader))
		return nil
	})
	app.OnRecordViewRequest("chapters").BindFunc(func(e *core.RecordRequestEvent) error {
		if err := e.Next(); err != nil {
			return err
		}
		if e.Record != nil {
			isPremium := checkDevicePremium(e.App, e.Request.Header.Get(deviceIDHeader))
			e.Record.Set("is_premium", isPremium)
		}
		return nil
	})
}

func addIsPremiumToRecords(app core.App, records []*core.Record, deviceID string) {
	isPremium := checkDevicePremium(app, deviceID)
	for _, r := range records {
		if r != nil {
			r.Set("is_premium", isPremium)
		}
	}
}

func extractChapterIDFromFilter(filter string) string {
	if filter == "" {
		return ""
	}
	m := chapterFilterRe.FindStringSubmatch(filter)
	if len(m) < 2 {
		return ""
	}
	return m[1]
}

func checkDevicePremium(app core.App, deviceID string) bool {
	if deviceID == "" {
		return false
	}
	col, err := app.FindCollectionByNameOrId("iap_verifications")
	if err != nil {
		return false
	}
	now := time.Now().UTC().Format("2006-01-02 15:04:05.000Z")
	for _, pid := range premiumProductIDs {
		r, err := app.FindFirstRecordByFilter(col.Id,
			`device_id="`+escapeFilter(deviceID)+`" && product_id="`+escapeFilter(pid)+`"`)
		if err != nil || r == nil {
			continue
		}
		exp := strings.TrimSpace(r.GetString("expires_at"))
		if exp == "" {
			return true // non-consumable or legacy
		}
		if exp > now {
			return true // subscription still active
		}
	}
	return false
}
