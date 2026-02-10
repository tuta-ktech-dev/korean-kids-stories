# Sticker System - Phân tích & Thiết kế DB/Backend

## 1. Tổng quan 2 loại Sticker

### Loại 1: Level Stickers (관직 Stickers)
- Theo ** quan chức Hàn Quốc thời Joseon** (조선 관직)
- User lên level → nhận sticker đại diện quan chức đó
- Mỗi cấp có: **mũ/ấn/áo** (복식, 인장 등) - có thể gộp 1 ảnh hoặc tách nhiều item
- **18 cấp** theo 품계: 종9품 (thấp nhất) → 정1품 (cao nhất)
- Ví dụ: Level 1 = 장사랑 (종9품), Level 18 = 대광보국숭록대부 (정1품)

### Loại 2: Story Stickers
- **Có truyện có**, **có truyện không**
- Unlock khi user **hoàn thành truyện** (đọc/nghe hết tất cả chapter)
- Mỗi truyện có sticker riêng (ảnh minh họa nhân vật, biểu tượng truyện...)
- `stories.has_sticker = true` → truyện đó có sticker để unlock

---

## 2. Bảng quan chức Joseon (Level → Rank mapping)

| Level | 품계 | 문관 (Văn quan) | 무관 (Võ quan) | Ghi chú |
|-------|------|-----------------|----------------|---------|
| 1 | 종9품 | 장사랑 | 선략부위 | Thấp nhất |
| 2 | 정9품 | 감사랑 | 수문부위 | |
| 3 | 종8품 | 인순부위 | 인순부위 | |
| 4 | 정8품 | 통덕랑 | 통력부위 | |
| 5 | 종7품 | 겸인순부위 | 겸선전부사 | |
| 6 | 정7품 | 사과 | 선무랑 | 참하관 |
| 7 | 종6품 | 승정랑 | 정훈랑 | |
| 8 | 정6품 | 수문장 | 지의 | 참상관 |
| 9 | 종5품 | 통선랑 | 무공랑 | |
| 10 | 정5품 | 통덕랑 | 적순장군 | |
| 11 | 종4품 | 봉정대부 | 호분장군 | |
| 12 | 정4품 | 봉렬대부 | 절충장군 | |
| 13 | 종3품 | 통정대부 | 어모장군 | |
| 14 | 정3품 | 통훈대부 | 어모장군 | 당하관 |
| 15 | 종2품 | 가선대부 | 부호군 | |
| 16 | 정2품 | 자헌대부 | 절충장군 | 대감 |
| 17 | 종1품 | 숭정대부 | 숭례부사 | |
| 18 | 정1품 | 대광보국숭록대부 | 보국숭록대부 | Cao nhất |

*Có thể rút gọn còn 10–12 level cho trẻ dễ hiểu, hoặc giữ 18 level.*

---

## 3. XP & Level Calculation

### Công thức XP
| Hành động | XP |
|-----------|-----|
| Hoàn thành 1 chapter (đọc ≥90%) | +10 |
| Hoàn thành 1 chapter (nghe audio hết) | +15 |
| Hoàn thành 1 truyện (tất cả chapter) | +50 bonus |
| Streak mỗi ngày | +5/ngày |

### Level threshold (ví dụ)
```
Level 1:  0 - 99 XP      (장사랑)
Level 2:  100 - 249
Level 3:  250 - 499
...
Level 18: 8500+
```
Công thức gọn: `level = min(18, floor(sqrt(totalXP / 5)) + 1)` hoặc dùng bảng cố định.

---

## 4. Database Schema (PocketBase)

### 4.1. `stickers` (Master - tất cả sticker)

| Field | Type | Mô tả |
|-------|------|-------|
| type | select | `level` \| `story` |
| key | text | Unique: `level_1`, `level_2`, ... hoặc `story_{id}` |
| name_ko | text | Tên hiển thị (e.g. "장사랑", "토끼와 거북이") |
| description_ko | text | Mô tả ngắn (optional) |
| image | file | Ảnh sticker |
| sort_order | number | Thứ tự hiển thị |
| **Cho type=level:** | | |
| level | number | Level tương ứng (1–18) |
| rank_ko | text | Tên 품계 (e.g. "종9품") |
| **Cho type=story:** | | |
| story | relation | → stories (nullable) |

### 4.2. `user_stickers` (Sticker user đã unlock)

| Field | Type | Mô tả |
|-------|------|-------|
| user | relation | → users |
| sticker | relation | → stickers |
| unlocked_at | date | Thời điểm unlock |
| unlock_source | select | `level_up` \| `story_complete` |

**Unique index:** `(user, sticker)` – mỗi user mỗi sticker chỉ unlock 1 lần.

### 4.3. `user_stats` (hoặc mở rộng `users`)

Tách riêng để dễ scale và audit.

| Field | Type | Mô tả |
|-------|------|-------|
| user | relation | → users (1-1) |
| total_xp | number | Tổng XP |
| level | number | Level hiện tại (1–18) |
| streak_days | number | Ngày đọc/nghe liên tiếp |
| last_activity_date | date | Ngày hoạt động gần nhất |
| chapters_read | number | Số chapter đã đọc xong |
| chapters_listened | number | Số chapter đã nghe xong |
| stories_completed | number | Số truyện hoàn thành |

**Hoặc:** Giữ `streak_days`, `total_reading_minutes` trong `users` và thêm `total_xp`, `level` vào `users_extend`.

### 4.4. `stories` – thêm field

| Field | Type | Mô tả |
|-------|------|-------|
| has_sticker | bool | Truyện có sticker hay không |

---

## 5. Backend Logic (Go Hooks)

### 5.1. Cập nhật XP & Level khi hoàn thành chapter

**Hook:** `reading_progress` – khi `is_completed` chuyển từ false → true

```go
// On update reading_progress
// If is_completed became true:
//   1. Get user_stats (or user)
//   2. Add XP (10 for read, 15 if had audio)
//   3. Check if story completed → +50, unlock story sticker
//   4. Recalculate level
//   5. If level up → unlock level sticker
//   6. Update streak
```

### 5.2. Unlock Story Sticker

- Khi user hoàn thành **tất cả chapter** của 1 truyện có `has_sticker = true`
- Tạo record `user_stickers` với `unlock_source = story_complete`
- Lấy `sticker` từ `stickers` where `type = story` AND `story = {storyId}`

### 5.3. Unlock Level Sticker

- Khi `level` tăng (sau khi +XP)
- Tạo `user_stickers` với `unlock_source = level_up`
- Lấy `sticker` từ `stickers` where `type = level` AND `level = newLevel`

### 5.4. Streak

- `last_activity_date`: nếu hôm nay đã active → không đổi
- Nếu mới active:  
  - `last_activity_date` = yesterday → `streak_days++`  
  - Khác → `streak_days = 1`
- Cập nhật `last_activity_date = today`

---

## 6. API Endpoints

### Read (Frontend gọi)

| Endpoint | Mô tả |
|----------|-------|
| `GET /api/collections/stickers/records` | List stickers (filter by type) |
| `GET /api/collections/user_stickers/records?filter=user=xxx` | Sticker user đã có |
| `GET /api/collections/user_stats/records?filter=user=xxx` | Stats (XP, level, streak) |

### Custom API (optional – để tính realtime)

| Endpoint | Mô tả |
|----------|-------|
| `GET /api/users/me/stats` | XP, level, streak từ reading_progress |
| `GET /api/users/me/stickers` | Danh sách sticker unlock |

---

## 7. Seed Data

### Level stickers (18 records)

```json
{"type": "level", "key": "level_1", "level": 1, "rank_ko": "종9품", "name_ko": "장사랑", "sort_order": 1}
{"type": "level", "key": "level_2", "level": 2, "rank_ko": "정9품", "name_ko": "감사랑", "sort_order": 2}
...
```

### Story stickers

- Seed khi tạo truyện: nếu `has_sticker = true` → tạo record trong `stickers` với `type = story`, `story = xxx`.

---

## 8. Thứ tự triển khai

1. **Schema:** `stickers`, `user_stickers`, `user_stats` (hoặc extend users) ✅
2. **Stories:** Thêm `has_sticker` ✅
3. **Seed:** Level stickers (1–18) ✅ `SeedLevelStickers` trong main.go
4. **Hooks:** 
   - `reading_progress` → cập nhật XP, level, unlock sticker (TODO)
   - Streak logic (TODO)
5. **API:** Endpoints đọc stats & stickers
6. **Frontend:** Màn Sticker Album, hiển thị level/badge

---

## 9. Files đã tạo/cập nhật

| File | Mô tả |
|------|-------|
| `backend/schema/stickers.go` | Collection stickers + SeedLevelStickers |
| `backend/schema/user_stickers.go` | Collection user_stickers |
| `backend/schema/user_stats.go` | Collection user_stats |
| `backend/schema/stories.go` | Thêm has_sticker |
| `backend/schema/init.go` | Register 3 collections mới |
| `backend/main.go` | Gọi SeedLevelStickers |

---

## 10. Lưu ý

- **Ảnh sticker:** Cần nguồn minh họa quan chức (mũ, áo, ấn) – có thể dùng public domain hoặc tự vẽ.
- **Story sticker:** Có thể dùng ảnh từ `stories.thumbnail` hoặc upload riêng.
- **Performance:** `user_stats` có thể cache/aggregate từ `reading_progress` khi cần; hoặc tính realtime mỗi lần vào app.
