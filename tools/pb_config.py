"""
PocketBase config từ env. Load .env từ project root nếu có.
"""
import os
from pathlib import Path


def _load_dotenv():
    """Load .env từ project root hoặc tools/."""
    for p in [Path(__file__).resolve().parent.parent / ".env", Path(__file__).resolve().parent / ".env"]:
        if p.exists():
            for line in p.read_text().splitlines():
                line = line.strip()
                if line and not line.startswith("#") and "=" in line:
                    k, v = line.split("=", 1)
                    v = v.strip().strip('"').strip("'")
                    os.environ.setdefault(k.strip(), v)
            break


_load_dotenv()

PB_BASE_URL = os.environ.get("PB_BASE_URL", "")
PB_EMAIL = os.environ.get("PB_EMAIL", "")
PB_PASSWORD = os.environ.get("PB_PASSWORD", "")


def require_pb_config():
    """Raise nếu thiếu config. Gọi trước khi auth."""
    if not PB_BASE_URL or not PB_EMAIL or not PB_PASSWORD:
        raise SystemExit(
            "Thiếu PB_BASE_URL, PB_EMAIL, PB_PASSWORD. "
            "Đặt trong .env hoặc export. Xem tools/.env.example"
        )
