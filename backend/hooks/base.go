package hooks

import (
	"strings"
)

// escapeFilter escapes special characters in filter strings to prevent injection
func escapeFilter(s string) string {
	s = strings.ReplaceAll(s, `\`, `\\`)
	s = strings.ReplaceAll(s, `"`, `\"`)
	s = strings.ReplaceAll(s, `'`, `\'`)
	return s
}

// uniqueStoryIds returns unique non-empty story IDs
func uniqueStoryIds(ids ...string) []string {
	seen := make(map[string]bool)
	var result []string
	for _, id := range ids {
		if id != "" && !seen[id] {
			seen[id] = true
			result = append(result, id)
		}
	}
	return result
}
