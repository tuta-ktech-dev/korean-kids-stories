# Premium Logic – Implementation Plan

## Model

- **Free:** 15 phút audio/ngày (900 giây)
- **Premium:** Unlimited audio (subscription: monthly/yearly)
- **Storage:** Local only (SharedPreferences) – không dùng account/backend

## Done ✓

1. **PremiumService** – SharedPreferences, daily limit, usage tracking
2. **ReaderCubit** – Gate `_startPlayback()` với `canPlayAudio()`, track usage trong listener
3. **ReaderState** – `freeLimitReached` flag, dialog khi hết quota
4. **Parent Zone** – Premium item hiện status (Premium active / X phút còn lại), sheet upgrade

## Done (Backend) ✓

- **POST /api/iap/verify** – Server-side verification (PocketBase Go)
  - **iOS:** Gọi Apple verifyReceipt API (production + sandbox 21007)
  - **Android:** Gọi Google Play `purchases.products.get` API
  - Body: `device_id` (required), `receipt_data` (iOS), `purchase_token` (Android)
  - Env: `IAP_SHARED_SECRET` (Apple), `GOOGLE_APPLICATION_CREDENTIALS` hoặc `GOOGLE_IAP_CREDENTIALS_JSON`
- **Chapter API** – Thêm `is_premium` vào response
  - GET chapters (list + view): kiểm tra X-Device-ID trong iap_verifications
  - Client gửi X-Device-ID (tự động qua PocketBase custom http client)

## Done (Frontend) ✓

- **IAP** (`in_app_purchase`): Buy, restore, gọi verify API → `setPremiumPurchased()` khi verified
- **IapService** – Parent Zone upgrade/restore buttons
- **Setup:** Xem [docs/IOS_IAP_SETUP.md](IOS_IAP_SETUP.md)

## Flow

1. **Trước khi play:** Kiểm tra `isPremium` hoặc `remainingFreeSecondsToday > 0`
2. **Khi play:** Mỗi giây đang phát → `addAudioSecondsUsed(1)` 
3. **Hết quota:** Pause + hiện dialog upgrade → "Nâng cấp Premium" (đi Main), "Đóng" (dismiss)
4. **IAP:** Mua xong → `setPremiumPurchased()` → lưu local

## Components

| Component | Role |
|-----------|------|
| `PremiumService` | Local state (isPremium, daily usage), usage tracking ✓ |
| `in_app_purchase` | Buy, restore, listen purchase stream ✓ |
| `ReaderCubit` | Gate play, track usage from position updates ✓ |

## Product ID (khi thêm IAP)

- Android: `premium` hoặc `com.hbstore.koreankids.premium`
- iOS: cùng ID trong App Store Connect

## Store Setup (sau khi code IAP)

- **Google Play:** Monetization → Products → Add "premium" (one-time)
- **App Store:** App Store Connect → In-App Purchases → Non-Consumable
