# iOS In-App Purchase – Subscription Setup

## Đã có sẵn trong code

- `in_app_purchase` package
- `IapService`: buy subscription, restore, verify với backend
- Parent Zone: nút Monthly / Yearly + Restore
- Backend: verify Apple receipt, parse `expires_date_ms`, lưu `expires_at`

## Cần làm để chạy Subscription trên iOS

### 1. App Store Connect

1. **Paid Applications Agreement**
   - [App Store Connect](https://appstoreconnect.apple.com) → Agreements, Tax, and Banking
   - Ký **Paid Applications** agreement
   - Thêm banking info + tax form

2. **Tạo Subscription Group**
   - App Store Connect → Your App → **Subscriptions**
   - **Subscription Groups** → **+** → đặt tên (ví dụ: Premium)
   - Group Reference Name: Premium

3. **Tạo Auto-Renewable Subscription products**
   - 월 프리미엄: `com.hbstore.koreankids.monthly` (1 tháng)
   - 3개월 프리미엄: `com.hbstore.koreankids.threemonth` (3 tháng)
   - 연 프리미엄: `com.hbstore.koreankids.yearly` (1 năm)
   - Hoàn thành **Metadata** (tên, mô tả) để fix "Missing Metadata"

4. **App-Specific Shared Secret**
   - Your App → **App Information** → **App-Specific Shared Secret** → Generate
   - Set env `IAP_SHARED_SECRET` trên backend

5. **Sandbox Test Account**
   - Users and Access → Sandbox → **Testers**
   - Tạo test account cho sandbox subscription test

### 2. Xcode

- Target **Runner** → **Signing & Capabilities** → **+** → **In-App Purchase**

### 3. Backend

```bash
export IAP_SHARED_SECRET="your-app-specific-shared-secret"
```

### 4. Product IDs

| Reference Name | Product ID | Duration |
|----------------|------------|----------|
| 월 프리미엄     | `com.hbstore.koreankids.monthly` | 1 tháng |
| 3개월 프리미엄  | `com.hbstore.koreankids.threemonth` | 3 tháng |
| 연 프리미엄    | `com.hbstore.koreankids.yearly` | 1 năm |

### 5. Subscription vs Non-Consumable

- **Subscription:** Backend lưu `expires_at`, check hết hạn khi verify `is_premium`
- **Non-consumable (premium):** Không có `expires_at`, premium vĩnh viễn

### 6. Testing

1. Thiết bị thật (Simulator không IAP)
2. Sandbox account
3. Parent Zone → Premium → **Monthly** hoặc **Yearly**
4. Mua thành công → backend verify → `expires_at` được lưu
5. **Restore** để sync khi cài lại app
