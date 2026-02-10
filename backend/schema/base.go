package schema

import (
	"log"
	"strings"

	"github.com/pocketbase/pocketbase/core"
	"github.com/pocketbase/pocketbase/tools/types"
)

// SaveCollection saves the collection and logs the result
func SaveCollection(app core.App, collection *core.Collection) {
	if err := app.Save(collection); err != nil {
		log.Printf("Failed to save collection %s: %v", collection.Name, err)
	} else {
		log.Printf("Collection %s saved successfully", collection.Name)
	}
}

// Ptr returns a pointer to the given value
func Ptr[T any](v T) *T {
	return &v
}

// EnsureIndex adds an index if it doesn't exist
func EnsureIndex(collection *core.Collection, name string, unique bool, columns string, where string) bool {
	if hasIndex(collection, name) {
		return false
	}
	collection.AddIndex(name, unique, columns, where)
	return true
}

// escapeFilter escapes special characters in filter strings
func escapeFilter(s string) string {
	s = strings.ReplaceAll(s, `\`, `\\`)
	s = strings.ReplaceAll(s, `"`, `\"`)
	s = strings.ReplaceAll(s, `'`, `\'`)
	return s
}

func hasIndex(collection *core.Collection, name string) bool {
	for _, idx := range collection.Indexes {
		if strings.Contains(idx, "`"+name+"`") {
			return true
		}
	}
	return false
}

// AddTextField adds a text field if missing
func AddTextField(collection *core.Collection, name string, required bool) bool {
	if collection.Fields.GetByName(name) != nil {
		return false
	}
	collection.Fields.Add(&core.TextField{
		Name:     name,
		Required: required,
	})
	return true
}

// AddNumberField adds a number field if missing
func AddNumberField(collection *core.Collection, name string, required bool, min, max *float64) bool {
	if collection.Fields.GetByName(name) != nil {
		return false
	}
	collection.Fields.Add(&core.NumberField{
		Name:     name,
		Required: required,
		Min:      min,
		Max:      max,
	})
	return true
}

// AddBoolField adds a bool field if missing
func AddBoolField(collection *core.Collection, name string) bool {
	if collection.Fields.GetByName(name) != nil {
		return false
	}
	collection.Fields.Add(&core.BoolField{
		Name: name,
	})
	return true
}

// AddSelectField adds a select field if missing
func AddSelectField(collection *core.Collection, name string, required bool, values []string, maxSelect int) bool {
	if collection.Fields.GetByName(name) != nil {
		return false
	}
	collection.Fields.Add(&core.SelectField{
		Name:      name,
		Required:  required,
		Values:    values,
		MaxSelect: maxSelect,
	})
	return true
}

// AddFileField adds a file field if missing
func AddFileField(collection *core.Collection, name string, maxSelect int, maxSize int64, mimeTypes []string) bool {
	if collection.Fields.GetByName(name) != nil {
		return false
	}
	collection.Fields.Add(&core.FileField{
		Name:      name,
		MaxSelect: maxSelect,
		MaxSize:   maxSize,
		MimeTypes: mimeTypes,
	})
	return true
}

// AddRelationField adds a relation field if missing.
// targetCollectionName can be collection name (e.g. "users") or id.
// Resolves to actual CollectionId - required because PocketBase validates relation exists.
func AddRelationField(app core.App, collection *core.Collection, name string, targetCollectionName string, required bool, maxSelect int, cascadeDelete bool) bool {
	if collection.Fields.GetByName(name) != nil {
		return false
	}
	targetCol, err := app.FindCollectionByNameOrId(targetCollectionName)
	if err != nil {
		return false
	}
	collection.Fields.Add(&core.RelationField{
		Name:          name,
		CollectionId:  targetCol.Id,
		Required:      required,
		MaxSelect:     maxSelect,
		CascadeDelete: cascadeDelete,
	})
	return true
}

// AddJSONField adds a JSON field if missing
func AddJSONField(collection *core.Collection, name string, required bool) bool {
	if collection.Fields.GetByName(name) != nil {
		return false
	}
	collection.Fields.Add(&core.JSONField{
		Name:     name,
		Required: required,
	})
	return true
}

// AddSystemFields adds created and updated timestamp fields if missing
func AddSystemFields(collection *core.Collection) bool {
	changes := false
	// Add created field
	if collection.Fields.GetByName("created") == nil {
		collection.Fields.Add(&core.AutodateField{
			Name:     "created",
			OnCreate: true,
			OnUpdate: false,
		})
		changes = true
	}
	// Add updated field
	if collection.Fields.GetByName("updated") == nil {
		collection.Fields.Add(&core.AutodateField{
			Name:     "updated",
			OnCreate: true,
			OnUpdate: true,
		})
		changes = true
	}
	return changes
}

// LockRule is a sentinel value for SetRules. Pass for create/update/delete to restrict to admin only (nil rule).
const LockRule = "__lock__"

func SetRules(collection *core.Collection, list, view, create, update, delete string) bool {
	changed := false
	if collection.ListRule == nil || *collection.ListRule != list {
		collection.ListRule = types.Pointer(list)
		changed = true
	}
	if collection.ViewRule == nil || *collection.ViewRule != view {
		collection.ViewRule = types.Pointer(view)
		changed = true
	}
	if create == LockRule {
		if collection.CreateRule != nil {
			collection.CreateRule = nil
			changed = true
		}
	} else if collection.CreateRule == nil || *collection.CreateRule != create {
		collection.CreateRule = types.Pointer(create)
		changed = true
	}
	if update == LockRule {
		if collection.UpdateRule != nil {
			collection.UpdateRule = nil
			changed = true
		}
	} else if collection.UpdateRule == nil || *collection.UpdateRule != update {
		collection.UpdateRule = types.Pointer(update)
		changed = true
	}
	if delete == LockRule {
		if collection.DeleteRule != nil {
			collection.DeleteRule = nil
			changed = true
		}
	} else if collection.DeleteRule == nil || *collection.DeleteRule != delete {
		collection.DeleteRule = types.Pointer(delete)
		changed = true
	}
	return changed
}
