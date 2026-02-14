# iOS dSYM Validation – objective_c.framework

## Lỗi

```
The archive did not include a dSYM for the objective_c.framework with the UUIDs [xxx].
Ensure that the archive's dSYM folder includes a DWARF file for objective_c.framework with the expected UUIDs.
```

## Nguyên nhân

- `objective_c.framework` là **system framework** của Apple (Darwin runtime)
- Xcode 16+ validation đôi khi báo thiếu dSYM cho các framework
- Apple không cung cấp dSYM cho system frameworks trong archive của app

## Giải pháp thử

1. **Upload qua Transporter**
   - Build IPA: `flutter build ipa`
   - Mở app **Transporter** (Mac App Store)
   - Kéo file `.ipa` vào Transporter
   - Bỏ qua validation trong Xcode, upload trực tiếp

2. **Dùng `flutter build ipa`**
   - Thay vì Archive trong Xcode, chạy: `cd frontend && flutter build ipa`
   - File ra: `build/ios/ipa/*.ipa`
   - Upload file này qua Transporter hoặc Xcode Organizer

3. **STRIP_STYLE = 'non-global'** (đã cấu hình trong Podfile)
   - Tránh crash `DOBJC_initializeApi` với path_provider, local_auth trên thiết bị thật
   - Một số trường hợp giảm vấn đề validation

## Ghi chú

- Thường đây là **warning**, không chặn upload – build vẫn có thể process trên App Store Connect
- Nếu vẫn fail, thử upload qua Transporter hoặc chờ bản cập nhật Xcode/Flutter
