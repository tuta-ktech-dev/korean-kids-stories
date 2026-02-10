package schema

import (
	"log"

	"github.com/pocketbase/pocketbase/core"
)

// defaultAppConfigKeys defines default app_config entries to seed
var defaultAppConfigKeys = []struct {
	key   string
	value string
	label string
}{
	{"contact_address", "", "Địa chỉ / Address / 주소"},
	{"contact_phone", "", "Số điện thoại / Phone / 전화번호"},
	{"contact_email", "", "Email / 이메일"},
	{"facebook_url", "", "Facebook link"},
	{"naver_url", "", "Naver link / 네이버"},
	{"instagram_url", "", "Instagram link"},
	{"youtube_url", "", "YouTube link"},
	{"app_store_url", "", "App Store link"},
	{"play_store_url", "", "Play Store link"},
}

// SeedAppConfig creates default app_config entries if they don't exist
func SeedAppConfig(app core.App) {
	col, err := app.FindCollectionByNameOrId("app_config")
	if err != nil {
		return
	}

	for _, d := range defaultAppConfigKeys {
		existing, err := app.FindRecordsByFilter(col.Id, `key="`+escapeFilter(d.key)+`"`, "", 1, 0)
		if err != nil || len(existing) > 0 {
			continue
		}
		rec := core.NewRecord(col)
		rec.Set("key", d.key)
		rec.Set("value", d.value)
		rec.Set("label", d.label)
		if err := app.Save(rec); err != nil {
			log.Printf("app_config: seed %s failed: %v", d.key, err)
		} else {
			log.Printf("app_config: seeded %s", d.key)
		}
	}
}

// EnsureAppConfigCollection ensures the app_config collection exists
// Single-record or key-value config: address, phone, email, social links, etc.
func EnsureAppConfigCollection(app core.App) {
	collection, err := app.FindCollectionByNameOrId("app_config")
	if err != nil {
		collection = core.NewBaseCollection("app_config")
	}

	changes := false
	// Public read. Only admin can create/update/delete (admin bypasses rules).
	if SetRules(collection, "", "", LockRule, LockRule, LockRule) {
		changes = true
	}

	// key: unique identifier (e.g. contact_address, contact_phone, facebook_url)
	if AddTextField(collection, "key", true) {
		changes = true
	}
	// value: the config value
	if AddTextField(collection, "value", false) {
		changes = true
	}
	// Optional description for admin UI
	if AddTextField(collection, "label", false) {
		changes = true
	}

	if EnsureIndex(collection, "idx_app_config_key", true, "key", "") {
		changes = true
	}

	if AddSystemFields(collection) {
		changes = true
	}

	if changes {
		SaveCollection(app, collection)
	}
}
