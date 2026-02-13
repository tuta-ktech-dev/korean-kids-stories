# Kế hoạch tính năng - Korean Kids Stories

## Tổng quan hiện trạng

| Tính năng | Trạng thái | Ghi chú |
|-----------|------------|---------|
| Tốc độ audio | ✅ Có sẵn | ReaderCubit.playbackSpeed (0.75–1.0), setting trong reader |
| Streak logic | ✅ Có sẵn | HistoryCubit._calculateStreak, ReadingStats |
| Dark/Light theme | ⚠️ Một phần | ThemeMode.system, chưa có toggle user |
| reading_history | ✅ Có sẵn | PocketBase collection, log action + duration |

---

## Phase 1: Dành cho bé (2–3 ngày)

### 1.1 Đọc liên tục (Streak) – Badge UI
**Độ phức tạp: Thấp** | **Thời gian: 0.5 ngày**

- **Đã có:** `HistoryCubit._calculateStreak`, `ReadingStats.currentStreak`, `longestStreak`
- **Cần làm:**
  - History: Hiển thị streak badge ("Đã đọc 7 ngày 🔥") ở header hoặc tab
  - Profile/Home: Widget nhỏ hiển thị current streak
  - Badge milestone: 3, 7, 14, 30 ngày (optional)
- **Files:** `history_view.dart`, `history_state.dart`, `profile_view.dart`, `home_view.dart`
- **L10n:** `streakDays`, `streakLongest`, `streakBadge`

---

### 1.2 Mục tiêu hàng ngày
**Độ phức tạp: Trung bình** | **Thời gian: 1 ngày**

- **Ý tưởng:** Phụ huynh hoặc bé đặt mục tiêu (vd: 1 truyện/ngày, 3 chương/ngày)
- **Cần làm:**
  - SettingsCubit: `dailyGoalStories` (0 = off), `dailyGoalChapters` (0 = off)
  - ProgressRepo: Lấy số truyện/chương đọc trong ngày (theo lastReadAt)
  - UI: Home/History hiển thị "1/3 chương hôm nay" hoặc "1/1 truyện"
  - Parent Zone: Đặt mục tiêu (stories: 0,1,2,3 | chapters: 0,3,5,10)
- **Files:** `settings_cubit.dart`, `progress_repository.dart`, `history_cubit.dart`, `parent_zone_view.dart`, `home_view.dart`
- **Data:** Có thể dùng reading_history hoặc đếm từ progress (lastReadAt date = today)

---

### 1.3 Hẹn giờ tắt audio (Sleep timer)
**Độ phức tạp: Thấp** | **Thời gian: 0.5 ngày**

- **Cần làm:**
  - ReaderBottomBar: Nút timer (5 / 10 / 15 phút) hoặc "Off"
  - ReaderCubit: `sleepTimerMinutes`, `Timer? _sleepTimer`
  - Khi hết giờ: pause audio, (optional) dim màn hình hoặc thông báo
- **Files:** `reader_bottom_bar.dart`, `reader_cubit.dart`, `reader_state.dart`
- **L10n:** `sleepTimer`, `sleepTimerOff`, `sleepTimer5min`, v.v.

---

### 1.4 Đề xuất theo lịch sử
**Độ phức tạp: Trung bình** | **Thời gian: 1 ngày**

- **Ý tưởng:** Section "Dựa trên những gì bạn đã đọc" – gợi ý theo category, tag, hoặc similarity đơn giản
- **Cần làm:**
  - ProgressRepo: `getReadStoryIds()`, `getReadCategories()` (đã có)
  - HomeCubit: Section `recommendedByHistory` – stories cùng category, chưa đọc, sort by popularity
  - Fallback: nếu ít history → dùng popular
- **Files:** `home_cubit.dart`, `home_state.dart`, `home_view.dart`, `progress_repository.dart`
- **L10n:** `recommendedForYou`, `basedOnYourReading`

---

## Phase 2: Dành cho phụ huynh (3–4 ngày)

### 2.1 Báo cáo đọc
**Độ phức tạp: Trung bình** | **Thời gian: 1.5 ngày**

- **Cần làm:**
  - API: PocketBase reading_history – filter by user, date range
  - Hoặc local: aggregate từ ProgressRepo.getAllProgress() theo lastReadAt
  - Parent Zone: Màn hình "Báo cáo" – Tab theo ngày/tuần
  - Metrics: thời gian đọc, số chương, số truyện, truyện đọc nhiều nhất
- **Files:** `reading_history_repository.dart` (extend), `report_view.dart`, `parent_zone_view.dart`
- **PocketBase:** Cần endpoint hoặc RPC `getReadingReport(userId, from, to)`

---

### 2.2 Mục tiêu đọc (phụ huynh đặt)
**Độ phức tạp: Thấp** | **Thời gian: 0.5 ngày**

- Trùng logic 1.2 – chỉ khác: cài đặt nằm trong Parent Zone
- SettingsCubit: `dailyGoalStories`, `dailyGoalChapters` (lưu SharedPreferences)
- Parent Zone: UI chọn mục tiêu
- Xem 2.2 như phần mở rộng của 1.2

---

### 2.3 Thông báo
**Độ phức tạp: Cao** | **Thời gian: 2 ngày**

- **Dependencies:** `flutter_local_notifications`, (optional) `timezone`
- **Cần làm:**
  - Khởi tạo LocalNotifications
  - Notification types:
    - Nhắc đọc: "Đã lâu chưa đọc, mở app và đọc truyện nhé!"
    - Hoàn thành truyện: "Bé đã hoàn thành [Tên truyện]!"
  - SettingsCubit: `reminderEnabled`, `reminderHour`, `reminderMinute`
  - Parent Zone: Bật/tắt reminder, chọn giờ
  - Android: channel, permissions; iOS: request authorization
- **Files:** `main.dart`, `notification_service.dart`, `parent_zone_view.dart`, `settings_cubit.dart`
- **L10n:** `notifications`, `reminderToRead`, `storyCompleteNotification`

---

### 2.4 Hoạt động trong Parent Zone
**Độ phức tạp: Trung bình** | **Thời gian: 1 ngày**

- **Cần làm:**
  - API: Lấy reading_history (user, sort by created desc)
  - Hoặc local: HistoryCubit + ProgressRepo – format cho Parent
  - Parent Zone: Section "Hoạt động gần đây" – danh sách: [Truyện], [Chương], [Thời gian], [Thời lượng]
- **Files:** `reading_history_repository.dart`, `parent_zone_view.dart`, `activity_item.dart`
- **Data:** reading_history có `story`, `chapter`, `action`, `duration_seconds`, `created`

---

## Phase 3: Kỹ thuật / trải nghiệm (3–4 ngày)

### 3.1 Offline
**Độ phức tạp: Cao** | **Thời gian: 2–3 ngày**

- **Cần làm:**
  - Cache story content + chapters (SQLite / Hive / Isar)
  - Nút "Tải để đọc offline" trên StoryDetail
  - Reader: Ưu tiên đọc từ cache nếu có
  - Sync: Khi online, cập nhật cache
  - Download images/audio cho offline
- **Packages:** `sqflite` hoặc `hive`, `dio` cache, `path_provider`
- **Files:** `offline_repository.dart`, `story_repository.dart`, `story_detail_view.dart`
- **Backend:** Có thể cần API trả full story+chapters trong 1 request

---

### 3.2 Chế độ ban đêm / Sepia
**Độ phức tạp: Thấp** | **Thời gian: 0.5 ngày**

- **Cần làm:**
  - SettingsCubit: `themeMode` (system/light/dark), `readerBackground` (default/sepia/night)
  - Reader: Container màu nền sepia (#f4ecd8) hoặc dark (#1a1a2e)
  - App: MaterialApp.themeMode từ Settings
- **Files:** `settings_cubit.dart`, `main.dart`, `reader_view.dart`, `app_theme.dart`
- **L10n:** `readerBackground`, `readerBackgroundDefault`, `readerBackgroundSepia`, `readerBackgroundNight`

---

### 3.3 Tốc độ audio
**Trạng thái: Đã có sẵn**

- ReaderCubit có `playbackSpeed` (0.75–1.0)
- UI trong reader settings (slide)
- Không cần thêm

---

## Thứ tự triển khai đề xuất

| # | Tính năng | Phase | Ước lượng |
|---|-----------|-------|----------|
| 1 | Streak badge UI | 1.1 | 0.5 ngày |
| 2 | Sleep timer | 1.3 | 0.5 ngày |
| 3 | Mục tiêu hàng ngày + Parent | 1.2 + 2.2 | 1 ngày |
| 4 | Đề xuất theo lịch sử | 1.4 | 1 ngày |
| 5 | Chế độ sepia/reader | 3.2 | 0.5 ngày |
| 6 | Hoạt động Parent Zone | 2.4 | 1 ngày |
| 7 | Báo cáo đọc | 2.1 | 1.5 ngày |
| 8 | Thông báo | 2.3 | 2 ngày |
| 9 | Offline | 3.1 | 2–3 ngày |

**Tổng ước lượng:** ~10–11 ngày.

---

## Phụ thuộc kỹ thuật

1. **PocketBase reading_history:** Cần đảm bảo schema và quyền đọc
2. ** flutter_local_notifications:** Cần setup Android/iOS
3. **Offline:** Cần chọn storage (Hive/SQLite) và chiến lược cache

---

## Ghi chú

- Phase 1 nên làm trước (tác động trực tiếp lên bé)
- Offline (3.1) có thể tách sang phase sau vì phức tạp hơn
- Notification cần test trên thiết bị thật (Android + iOS)
