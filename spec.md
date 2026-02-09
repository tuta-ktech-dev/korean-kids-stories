# Korean Kids Stories App - Project Spec

**Tên dự án:** Korean Kids Stories (tạm)  
**Mục đích:** App Flutter cho trẻ em Hàn Quốc đọc/nghe truyện dân gian, lịch sử  
**Tech stack:** Flutter (Mobile) + Pocketbase (Backend) + Naver Clova Voice (TTS)  
**Auth:** Google OAuth, Apple OAuth  
**Ngôn ngữ:** Tiếng Hàn only  
**Ngưỡng tuổi:** 4-10 tuổi  

---

## 📁 Cấu trúc thư mục

```
korean-kids-stories/
├── backend/              # Pocketbase backend
│   ├── pb_migrations/    # Database migrations
│   ├── pb_hooks/         # Custom hooks
│   └── pocketbase        # Binary
├── frontend/             # Flutter app
│   ├── lib/
│   ├── assets/
│   └── pubspec.yaml
├── docs/                 # Documentation
│   └── api-spec.md
├── spec.md               # This file
└── README.md
```

---

## 📚 Database Collections

### 1. `stories` - Danh sách truyện
| Field | Type | Description |
|-------|------|-------------|
| title | string | Tên truyện |
| category | select | `folktale`, `history`, `legend` |
| age_min | number | Độ tuổi tối thiểu |
| age_max | number | Độ tuổi tối đa |
| thumbnail | file | Ảnh bìa |
| summary | string | Tóm tắt ngắn |
| total_chapters | number | Số chương |
| tags | json | Tags tìm kiếm |
| is_published | bool | Hiển thị hay không |
| created | date | Ngày tạo |

### 2. `chapters` - Chi tiết từng chương
| Field | Type | Description |
|-------|------|-------------|
| story | relation | → stories |
| chapter_number | number | Số thứ tự |
| title | string | Tên chương |
| content | text | Nội dung text |
| audio_file | file | File audio đã generate |
| audio_duration | number | Thờ lượng (giây) |
| word_timings | json | Array [{word, start_ms, end_ms}] cho read-along |
| illustrations | files | Ảnh minh họa |
| is_free | bool | Miễn phí hay trả phí |

### 3. `users` (mở rộng auth)
| Field | Type | Description |
|-------|------|-------------|
| name | string | Tên trẻ (nickname) |
| birth_year | number | Năm sinh để gợi ý content |
| avatar | file | Ảnh đại diện |
| streak_days | number | Ngày đọc liên tiếp |
| total_reading_minutes | number | Tổng thờ gian đọc |
| parent_email | email | Email phụ huynh |

### 4. `reading_progress` - Tiến độ đọc
| Field | Type | Description |
|-------|------|-------------|
| user | relation | → users |
| chapter | relation | → chapters |
| percent_read | number | % đã đọc |
| last_position | number | Vị trí dở (ms trong audio) |
| is_completed | bool | Đã đọc xong chưa |
| bookmarks | json | Các đoạn đã đánh dấu |

### 5. `dictionary` - Từ điển tap-to-define
| Field | Type | Description |
|-------|------|-------------|
| word | string | Từ gốc |
| reading | string | Cách đọc (nếu Hanja) |
| meaning | text | Giải thích đơn giản |
| example | text | Ví dụ câu |
| category | select | `hanja`, `old_korean`, `name`, `place` |

---

## 🎯 Core Features

### MVP Phase 1
- [ ] Đăng nhập Google/Apple
- [ ] Browse truyện theo category
- [ ] Đọc text cơ bản
- [ ] Nghe audio (pre-generated)
- [ ] Save progress

### Phase 2
- [ ] Read-along mode (highlight sync)
- [ ] Tap dictionary
- [ ] Offline download
- [ ] Reading streak
- [ ] Parent dashboard

### Phase 3
- [ ] Quiz sau truyện
- [ ] Avatar/Virtual pet
- [ ] Playlist audio
- [ ] Recommendation

---

## 🔧 API Endpoints (từ Pocketbase)

```
POST /api/collections/users/auth-with-oauth2    # Login Google/Apple
GET  /api/collections/stories/records           # List stories
GET  /api/collections/stories/records/:id       # Story detail
GET  /api/collections/chapters/records          # Filter by story
GET  /api/collections/chapters/records/:id      # Chapter + audio
POST /api/collections/reading_progress/records  # Save progress
```

---

## 🖼️ UI Screens (Flutter)

1. **Splash** - Logo, load auth
2. **Onboarding** - Chọn tên, tuổi
3. **Home** - Featured stories, categories
4. **Story Detail** - Info, chapters list
5. **Reader** - Text + audio player + read-along
6. **Library** - Đã tải, đang đọc
7. **Profile** - Stats, streak, settings
8. **Parent Zone** - Dashboard (có PIN lock)

---

## 📝 Notes

- **Read-along timing**: Cần script để generate từ audio, hoặc làm tay cho content đầu tiên
- **Images**: Tìm nguồn public domain Hàn (Wikimedia, National Library of Korea)
- **Content moderation**: Chặn copy, không có user-generated content
- **Compliance**: COPPA-safe, không thu thập data nhạy cảm

---

## 🚀 Next Steps

1. [ ] Setup Pocketbase binary + chạy local
2. [ ] Tạo collections trong Pocketbase
3. [ ] Thêm 1-2 truyện mẫu
4. [ ] Setup Flutter project
5. [ ] Implement OAuth login

**Owner:** Tú (Trần Anh Tú)  
**Assistant:** Biseo 🐾
