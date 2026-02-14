# Backend (PocketBase + Go)

## Build

```bash
GOOS=linux GOARCH=amd64 go build -o pocketbase_linux .
```

## Chạy local

```bash
./pocketbase_linux serve --http="0.0.0.0:8090"
```

## Deploy

1. Build: `GOOS=linux GOARCH=amd64 go build -o pocketbase_linux .`
2. Upload `pocketbase_linux` lên server (thay binary cũ)
3. Restart: `./pocketbase_linux serve --http="0.0.0.0:8090"`

## API

- `GET /api/popular-searches` – Popular search terms (cache 24h)
- `POST /api/internal/refresh-popular` – Refresh cache (header `X-Cron-Secret`)

## Test

```bash
curl http://trananhtu.vn:8090/api/popular-searches
```

## Biến môi trường

- `CRON_SECRET` – Secret cho refresh API (mặc định: change-me-in-production)
- **IAP (Apple):** `IAP_SHARED_SECRET` – App-Specific Shared Secret từ App Store Connect
- **IAP (Google):** `GOOGLE_APPLICATION_CREDENTIALS` (path to service-account.json) hoặc `GOOGLE_IAP_CREDENTIALS_JSON` (JSON string)
- `GOOGLE_PACKAGE_NAME` – optional, mặc định `com.hbstore.koreankids`