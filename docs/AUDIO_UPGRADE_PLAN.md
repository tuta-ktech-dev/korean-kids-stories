# Kế hoạch nâng cấp Audio UI & Background Playback

> Phần audio rất quan trọng cho trải nghiệm nghe truyện. Plan này đề xuất cải thiện UI, UX và hỗ trợ play ở nền (background playback).

---

## 1. Hiện trạng

**Đã có:**
- Phát audio với `just_audio` trong Reader
- Tốc độ 0.85x mặc định cho trẻ em, slider điều chỉnh trong Settings
- Thanh progress theo vị trí audio
- Nút Play/Pause, Prev/Next chapter
- Icon tai nghe trên StoryCard, StoryDetailInfo

**Chưa có:**
- Background playback (tắt app / chuyển màn hình thì dừng)
- Mini player cố định khi đang nghe
- Media controls trên lock screen / notification
- Seek bar (kéo tới vị trí bất kỳ)
- Hiển thị thời gian (current / total)
- Có thể chọn giọng đọc (narrator) khi có nhiều version

---

## 2. Mục tiêu theo độ ưu tiên

### P0 - Background playback (play ở nền)
- Nghe tiếp khi tắt màn hình, chuyển app, home
- Media notification với Play/Pause, Prev/Next
- Lock screen controls (iOS/Android)

### P1 - UX & dễ dùng
- Mini player luôn hiện khi đang phát (có thể thu gọn)
- Seek bar có thể kéo
- Hiển thị thời gian: 1:23 / 5:40
- Auto-play chapter tiếp theo khi hết

### P2 - UI nâng cấp
- Chọn narrator/giọng đọc nếu có nhiều version
- Animation khi play/pause
- Theme/color thống nhất với app

---

## 3. Technical Plan

### 3.1 Background Playback

**Package:** `just_audio_background` (add-on cho just_audio)

```
dependencies:
  just_audio: ^0.9.46
  just_audio_background: ^0.0.1-beta.17
```

**Cần làm:**
1. Init `JustAudioBackground.init()` trong `main()` với Android notification channel
2. Wrap `AudioPlayer` với `AudioSource` có `MediaItem` (id, album, title, artUri)
3. Chuyển `ReaderCubit` sang dùng player global (hoặc service) thay vì tạo mới mỗi Reader
4. Android: permissions + service trong Manifest
5. iOS: background modes (audio)

**Kiến trúc đề xuất:**
- Tạo `AudioPlaybackService` (singleton) inject vào app
- Service quản lý: current story, chapter, position, playlist
- ReaderCubit gọi service thay vì trực tiếp dùng `AudioPlayer`
- Service emit state → UI subscribe (BlocListener / Stream)

### 3.2 Mini player

**Vị trí:** Bottom sheet cố định hoặc overlay dưới bottom nav

**Nội dung:**
- Thumbnail truyện (hoặc icon)
- Tên truyện, chapter hiện tại
- Seek bar + thời gian
- Play/Pause, đóng (minimize)
- Tap mở full Reader của chapter đang nghe

**Implementation:**
- Widget `AudioMiniPlayer` trong `MainScreen` hoặc overlay toàn app
- Hiện khi `AudioPlaybackService.isPlaying == true`
- Có thể thu gọn thành 1 dòng hoặc ẩn khi pause lâu

### 3.3 ReaderBottomBar nâng cấp

| Hiện tại | Đề xuất |
|----------|---------|
| LinearProgressIndicator | Seek bar có thể drag |
| Không có thời gian | `1:23 / 5:40` |
| 3 nút: prev, play, next | Giữ + thêm speed quick-toggle (0.75x, 0.85x, 1x) |
| Progress chỉ fill | Có thumb kéo được |

### 3.4 Auto-play next chapter

- Khi `ProcessingState.completed` và `position >= duration` → gọi `loadChapter(nextChapterId)` và `play()`
- Có thể thêm setting: "Tự phát chương tiếp" (on/off)

---

## 4. Phân chia task (sprint)

### Sprint 1: Background playback (1–2 ngày)
- [ ] Add `just_audio_background`, config Android/iOS
- [ ] Tạo `AudioPlaybackService` (global)
- [ ] Migrate ReaderCubit sang dùng service
- [ ] Test: tắt màn hình vẫn nghe, notification hiện

### Sprint 2: Mini player (1 ngày)
- [ ] `AudioMiniPlayer` widget
- [ ] Hiện/ẩn theo state
- [ ] Tap mở Reader đúng chapter

### Sprint 3: Reader UI (1 ngày)
- [ ] Seek bar có drag (Slider hoặc custom)
- [ ] Hiển thị thời gian
- [ ] Quick speed buttons (0.75x, 0.85x, 1x)

### Sprint 4: Polish (0.5 ngày)
- [ ] Auto-play next chapter (có setting)
- [ ] Chọn narrator nếu audios.length > 1
- [ ] Animation, accessibility

---

## 5. Tham khảo

- [just_audio_background](https://pub.dev/packages/just_audio_background)
- [audio_service](https://pub.dev/packages/audio_service) – nếu cần control phức tạp hơn
- [Android MediaSession](https://developer.android.com/guide/topics/media-apps/audio-app-builder)
- [iOS Background Modes - Audio](https://developer.apple.com/documentation/bundleresources/information_property_list/uibackgroundmodes)

---

## 6. Rủi ro & lưu ý

- **just_audio_background** đang beta → theo dõi breaking changes
- **Battery:** Background audio cần WAKE_LOCK, có thể ảnh hưởng pin
- **State sync:** Service phải đồng bộ với Reader (chapter, position) khi user mở lại Reader
- **Offline:** Chưa cache audio → cần mạng khi play; có thể thêm offline cache sau
