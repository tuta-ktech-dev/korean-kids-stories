#!/bin/bash
# Test sticker hook flow on localhost:8090
# Usage: ./test_sticker_hook.sh
# Requires: backend running on localhost:8090, a test user, and at least one story with chapters

BASE="${1:-http://localhost:8090}"

echo "=== Testing Sticker Hook on $BASE ==="

# 1. Login as admin (to get token for API operations)
echo ""
echo "1. Auth as superuser..."
TOKEN=$(curl -s -X POST "$BASE/api/collections/_superusers/auth-with-password" \
  -H "Content-Type: application/json" \
  -d '{"identity":"ichimoku.0902@gmail.com","password":"@nhTu09022001"}' | jq -r '.token')

if [ -z "$TOKEN" ] || [ "$TOKEN" = "null" ]; then
  echo "   FAIL: Could not get admin token. Is backend running?"
  exit 1
fi
echo "   OK: Got admin token"

# 2. Get first user (we need a user to assign progress to)
echo ""
echo "2. Get first user..."
USER_ID=$(curl -s "$BASE/api/collections/users/records?perPage=1" -H "Authorization: $TOKEN" | jq -r '.items[0].id')
if [ -z "$USER_ID" ] || [ "$USER_ID" = "null" ]; then
  echo "   FAIL: No users in DB. Create a user first."
  exit 1
fi
echo "   User ID: $USER_ID"

# 3. Get or create a chapter
echo ""
echo "3. Get first chapter..."
CHAPTER_ID=$(curl -s "$BASE/api/collections/chapters/records?perPage=1&sort=chapter_number" -H "Authorization: $TOKEN" | jq -r '.items[0].id')
STORY_ID=$(curl -s "$BASE/api/collections/chapters/records?perPage=1&sort=chapter_number" -H "Authorization: $TOKEN" | jq -r '.items[0].story')

if [ -z "$CHAPTER_ID" ] || [ "$CHAPTER_ID" = "null" ]; then
  echo "   No chapters. Creating test chapter for first story..."
  STORY_ID=$(curl -s "$BASE/api/collections/stories/records?perPage=1" -H "Authorization: $TOKEN" | jq -r '.items[0].id')
  if [ -z "$STORY_ID" ] || [ "$STORY_ID" = "null" ]; then
    echo "   FAIL: No stories in DB. Add stories first."
    exit 1
  fi
  CREATE_CH=$(curl -s -X POST "$BASE/api/collections/chapters/records" \
    -H "Authorization: $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"story\":\"$STORY_ID\",\"chapter_number\":1,\"title\":\"Test Chapter\",\"content\":\"<p>Test content for sticker hook.</p>\"}")
  CHAPTER_ID=$(echo "$CREATE_CH" | jq -r '.id')
  if [ -z "$CHAPTER_ID" ] || [ "$CHAPTER_ID" = "null" ]; then
    echo "   FAIL: Could not create chapter. Response: $CREATE_CH"
    exit 1
  fi
  echo "   Created chapter: $CHAPTER_ID (story: $STORY_ID)"
else
  echo "   Chapter ID: $CHAPTER_ID"
  echo "   Story ID: $STORY_ID"
fi

# 4. Check stickers collection (level stickers)
echo ""
echo "4. Check stickers (level_1..level_18)..."
STICKER_COUNT=$(curl -s "$BASE/api/collections/stickers/records?filter=type%3D%22level%22&perPage=20" -H "Authorization: $TOKEN" | jq '.totalItems')
echo "   Level stickers: $STICKER_COUNT"

# 5. Create reading_progress with is_completed=true
# Note: reading_progress requires user = @request.auth.id, so we must use the user's own auth
# Admin token won't work for creating progress for another user.
# We need to either: (a) use a user's password to auth as them, or (b) use DB directly / admin API
# PocketBase admin API - can we create records for other users? Usually create uses auth user.
echo ""
echo "5. Creating reading_progress as admin might fail (rule: user=@request.auth.id)..."
echo "   Trying to create via service runner / direct insert..."

# Check if there's a way - the schema says create rule is "user = @request.auth.id"
# So we MUST be logged in as that user. Let's try with admin - maybe we need to use 
# the Serve API or a custom endpoint. Actually the hooks run on the backend - any create/update
# that passes the rules will trigger. The rules say user must match auth. So we need to 
# auth as the user. Do we have a test user password? From the conversation we had ichimoku.0902@gmail.com / @nhTu09022001 for admin.
# For regular users we'd need their credentials.

# Alternative: Use pb migrate or a backend script that uses app.Save() directly bypassing rules
# Or we could add a temporary test endpoint that creates progress (for dev only).

# For this script, let's try authenticating as the user - we need a user with known password
# Use unique email so we get a fresh user (tests level_1 sticker unlock for new users)
EMAIL="test$(date +%s)@sticker.local"
PASS="Test123456"

# Try to create user and auth
USER_TOKEN=$(curl -s -X POST "$BASE/api/collections/users/auth-with-password" \
  -H "Content-Type: application/json" \
  -d "{\"identity\":\"$EMAIL\",\"password\":\"$PASS\"}" | jq -r '.token')

if [ -z "$USER_TOKEN" ] || [ "$USER_TOKEN" = "null" ]; then
  echo "   Creating test user..."
  CREATE_RESULT=$(curl -s -X POST "$BASE/api/collections/users/records" \
    -H "Authorization: $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"$EMAIL\",\"password\":\"$PASS\",\"passwordConfirm\":\"$PASS\",\"name\":\"Test Sticker\"}")
  if echo "$CREATE_RESULT" | jq -e '.id' >/dev/null 2>&1; then
    USER_ID=$(echo "$CREATE_RESULT" | jq -r '.id')
  fi
fi

# Auth as test user to get token
AUTH_RESULT=$(curl -s -X POST "$BASE/api/collections/users/auth-with-password" \
  -H "Content-Type: application/json" \
  -d "{\"identity\":\"$EMAIL\",\"password\":\"$PASS\"}")
USER_TOKEN=$(echo "$AUTH_RESULT" | jq -r '.token')
if [ -n "$USER_TOKEN" ] && [ "$USER_TOKEN" != "null" ]; then
  USER_ID=$(echo "$AUTH_RESULT" | jq -r '.record.id')
fi

if [ -n "$USER_TOKEN" ] && [ "$USER_TOKEN" != "null" ]; then
  echo "   Auth as test user OK (id: $USER_ID)"
  echo ""
  echo "6. Create/update reading_progress with is_completed=true..."
  EXISTING=$(curl -s "$BASE/api/collections/reading_progress/records?filter=user%3D%22$USER_ID%22%20%26%26%20chapter%3D%22$CHAPTER_ID%22&perPage=1" -H "Authorization: $USER_TOKEN" | jq -r '.items[0].id')
  
  if [ -n "$EXISTING" ] && [ "$EXISTING" != "null" ]; then
    echo "   Updating existing progress $EXISTING..."
    RESULT=$(curl -s -X PATCH "$BASE/api/collections/reading_progress/records/$EXISTING" \
      -H "Authorization: $USER_TOKEN" \
      -H "Content-Type: application/json" \
      -d "{\"percent_read\":100,\"is_completed\":true}")
  else
    RESULT=$(curl -s -X POST "$BASE/api/collections/reading_progress/records" \
      -H "Authorization: $USER_TOKEN" \
      -H "Content-Type: application/json" \
      -d "{\"user\":\"$USER_ID\",\"chapter\":\"$CHAPTER_ID\",\"percent_read\":100,\"is_completed\":true}")
  fi
  
  PROG_ID=$(echo "$RESULT" | jq -r '.id')
  if [ -n "$PROG_ID" ] && [ "$PROG_ID" != "null" ]; then
    echo "   OK: reading_progress $PROG_ID (is_completed=true)"
  else
    echo "   FAIL: $RESULT"
  fi
  
  echo ""
  echo "7. Check user_stats..."
  curl -s "$BASE/api/collections/user_stats/records?filter=user%3D%22$USER_ID%22" -H "Authorization: $TOKEN" | jq '.items[] | {total_xp, level, chapters_read, stories_completed}'
  
  echo ""
  echo "8. Check user_stickers..."
  curl -s "$BASE/api/collections/user_stickers/records?filter=user%3D%22$USER_ID%22&expand=sticker" -H "Authorization: $TOKEN" | jq '.items[] | {unlock_source, sticker: .expand.sticker.name_ko}'
else
  echo "   Skipping progress create - use an existing user's login in the app to test."
  echo "   Or run backend with a test script that uses app.Save() to bypass auth."
fi

echo ""
echo "=== Done ==="
