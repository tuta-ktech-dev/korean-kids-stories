# Release Checklist - Version 1.0.0

> Build v1 trước khi thêm In-App Purchase

## 1. Code / Config

### ✅ Đã sẵn sàng
- [x] Version: `1.0.0+1` (pubspec.yaml)
- [x] App name: 꼬마 한동화 - Kids Tales
- [x] Bundle ID: `com.koreankids.korean_kids_stories`
- [x] API: `trananhtu.vn:8090` (dev = prod)
- [x] iOS Info.plist có NSAppTransportSecurity (cho phép HTTP)
- [x] `debugShowCheckedModeBanner: false`

### ⚠️ Cần sửa trước release

| Item | File | Ghi chú |
|------|------|---------|
| **Android signing** | `android/app/build.gradle.kts` | Hiện dùng debug key. Cần tạo release keystore cho Play Store |
| ~~**API HTTPS**~~ | `lib/core/config/app_config.dart` | ✅ Đã dùng `https://trananhtu.vn` (prod). Cần deploy htaccess proxy trên server |
| ~~**print()**~~ | `lib/core/audio/audio_handler.dart` | ✅ Đã đổi `debugPrint` |

### 📝 debugPrint - OK để giữ
Các `debugPrint` trong cubits/repos **tự động không chạy** trong release build (Flutter strip chúng). Không cần xóa.

---

## 1.5. API HTTPS (Server)

App đã dùng `https://trananhtu.vn` cho prod. Trên server cần:

1. **Deploy .htaccess** (copy từ `backend/deploy/.htaccess.example`):
   - Đổi tên thành `.htaccess`
   - Đặt vào document root của trananhtu.vn
   - Proxy `/api` → `http://127.0.0.1:8090`

2. **Nếu .htaccess [P] bị chặn** (lỗi 500): dùng `backend/deploy/apache-vhost.conf.example`

3. **Test**: `curl https://trananhtu.vn/api/popular-searches`

---

## 2. Android Release

### Keystore (bắt buộc cho Play Store)
```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Thêm vào `android/key.properties`:
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=../upload-keystore.jks
```

Cập nhật `android/app/build.gradle.kts` signingConfig cho release.

### Build
```bash
cd frontend && flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

---

## 3. iOS Release

### Yêu cầu
- Apple Developer account ($99/năm)
- Xcode: chọn team, provisioning profile
- App Store Connect: tạo app, điền metadata

### Build
```bash
cd frontend && flutter build ipa
```
Hoặc mở Xcode → Archive → Distribute App

---

## 4. Store Listing (cả 2 nền tảng)

### Cần chuẩn bị
- [ ] **Screenshots** (iPhone 6.7", 6.5", 5.5" + iPad nếu support)
- [ ] **App description** (EN, KO, VI nếu có)
- [ ] **Keywords**
- [ ] **Privacy Policy URL** (bắt buộc)
- [ ] **App icon** (1024x1024 cho iOS)
- [ ] **Category**: Kids / Education

### Privacy Policy
Cả App Store và Play Store yêu cầu. Có thể dùng:
- GitHub Pages
- Notion (public page)
- Website riêng

---

## 5. In-App Purchase (sau v1)
Khi thêm IAP:
- iOS: App Store Connect → In-App Purchases
- Android: Play Console → Monetization → Products
- Package: `in_app_purchase` hoặc `purchases_flutter` (RevenueCat)

---

## Quick Fixes (có thể làm ngay)

1. **Đổi print → debugPrint** trong `audio_handler.dart`
2. **API HTTPS**: Nếu `trananhtu.vn` đã có SSL → đổi sang `https://trananhtu.vn:443` hoặc port tương ứng
3. **Android signing**: Làm trước khi upload lên Play Console
