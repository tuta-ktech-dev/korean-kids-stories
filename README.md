# Korean Kids Stories 📚🇰🇷

App đọc/nghe truyện dân gian và lịch sử Hàn Quốc cho trẻ em (4-10 tuổi).

**Stack:** Flutter + Pocketbase + Naver Clova Voice TTS

---

## 🚀 Quick Start

### Backend (Pocketbase + Go)

**Requirements:** Go 1.23+

**1. Cài Go (nếu chưa có):**
```bash
# macOS với Homebrew
brew install go

# Kiểm tra
go version
```

**2. First time setup:**
```bash
cd backend
go mod tidy
```

**3. Chạy development:**
```bash
cd backend
go mod tidy
```

**Chạy development (hot reload với Air):**
```bash
# Cài Air (lần đầu)
go install github.com/air-verse/air@latest

# Chạy với hot reload
cd backend
air
```

**Hoặc chạy thường:**
```bash
cd backend
go run main.go serve --http="127.0.0.1:8090"
```

- Dashboard: http://127.0.0.1:8090/_/
- API: http://127.0.0.1:8090/api/

Lần đầu chạy sẽ yêu cầu tạo superuser account.

### Frontend (Flutter) - TBD
```bash
cd frontend
flutter run
```

---

## 📁 Structure

```
.
├── backend/
│   ├── main.go                # Entry point
│   ├── go.mod                 # Go dependencies
│   ├── go.sum                 # Go checksums
│   ├── .air.toml              # Air config for hot reload
│   ├── pb_data/               # Database + files (auto-generated)
│   ├── pb_migrations/         # Schema migrations
│   └── pb_public/             # Static files (optional)
├── frontend/                  # Flutter app (sắp tới)
├── docs/
│   └── api-spec.md
└── spec.md                    # Full project specification
```

---

## ✅ TODO

- [x] Setup Pocketbase Go backend
- [ ] Install dependencies (`go mod tidy`)
- [ ] Create database collections (stories, chapters, users, etc.)
- [ ] Tạo superuser admin
- [ ] Thêm 1-2 truyện mẫu
- [ ] Setup Flutter project
- [ ] Implement OAuth (Google/Apple)

---

**Created:** Feb 9, 2026  
**By:** Tú + Biseo 🐾
