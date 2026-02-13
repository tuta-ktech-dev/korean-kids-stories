# Premium Logic – Implementation Plan

## Model

- **Free:** 15 phút audio/ngày (900 giây)
- **Premium:** Unlimited audio (mua 1 lần, non-consumable IAP)
- **Storage:** Local only (SharedPreferences) – không dùng account/backend

## Done ✓

1. **PremiumService** – SharedPreferences, daily limit, usage tracking
2. **ReaderCubit** – Gate `_startPlayback()` với `canPlayAudio()`, track usage trong listener
3. **ReaderState** – `freeLimitReached` flag, dialog khi hết quota
4. **Parent Zone** – Premium item hiện status (Premium active / X phút còn lại), sheet upgrade

## Pending

- **IAP** (`in_app_purchase`): Buy, restore, gọi `setPremiumPurchased()` khi mua xong

## Flow

1. **Trước khi play:** Kiểm tra `isPremium` hoặc `remainingFreeSecondsToday > 0`
2. **Khi play:** Mỗi giây đang phát → `addAudioSecondsUsed(1)` 
3. **Hết quota:** Pause + hiện dialog upgrade → "Nâng cấp Premium" (đi Main), "Đóng" (dismiss)
4. **IAP:** Mua xong → `setPremiumPurchased()` → lưu local

## Components

| Component | Role |
|-----------|------|
| `PremiumService` | Local state (isPremium, daily usage), usage tracking ✓ |
| `in_app_purchase` | Buy, restore, listen purchase stream (TODO) |
| `ReaderCubit` | Gate play, track usage from position updates ✓ |

## Product ID (khi thêm IAP)

- Android: `premium` hoặc `com.hbstore.koreankids.premium`
- iOS: cùng ID trong App Store Connect

## Store Setup (sau khi code IAP)

- **Google Play:** Monetization → Products → Add "premium" (one-time)
- **App Store:** App Store Connect → In-App Purchases → Non-Consumable
