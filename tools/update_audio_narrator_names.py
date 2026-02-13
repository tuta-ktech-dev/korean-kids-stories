#!/usr/bin/env python3
"""
Cập nhật tên narrator trong chapter_audios cho dễ hiểu với bé.
Clova Female -> Cô, Clova Male -> Chú (hoặc tùy chọn ngôn ngữ).
"""
import argparse
import json
import sys
from pathlib import Path
from urllib.request import Request, urlopen
from urllib.error import HTTPError, URLError

sys.path.insert(0, str(Path(__file__).resolve().parent))
from pb_config import PB_BASE_URL, PB_EMAIL, PB_PASSWORD, require_pb_config

# Mapping: giá trị cũ -> giá trị mới (tiếng Hàn cho bé)
NARRATOR_MAP = {
    "clova female": "여자",
    "clova male": "남자",
    "female": "여자",
    "male": "남자",
    "kss": "여자",
    "mms": "남자",   # MMS giọng nam
    "cô": "여자",
    "chú": "남자",
}


def main():
    parser = argparse.ArgumentParser(description="Update narrator names in chapter_audios")
    parser.add_argument("--base-url", default="", help="PB_BASE_URL env")
    parser.add_argument("--email", default="", help="PB_EMAIL env")
    parser.add_argument("--password", default="", help="PB_PASSWORD env")
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Chỉ in ra, không thực sự update",
    )
    args = parser.parse_args()
    require_pb_config()
    base = (args.base_url or PB_BASE_URL).rstrip("/")
    email = args.email or PB_EMAIL
    password = args.password or PB_PASSWORD

    # 1. Auth
    auth_url = f"{base}/api/collections/_superusers/auth-with-password"
    auth_body = json.dumps({
        "identity": email,
        "password": password,
    }).encode()
    req = Request(
        auth_url,
        data=auth_body,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urlopen(req) as r:
            auth_res = json.loads(r.read())
    except HTTPError as e:
        print(f"Auth failed: {e.code} {e.reason}", file=sys.stderr)
        if e.fp:
            print(e.fp.read().decode(), file=sys.stderr)
        sys.exit(1)

    token = auth_res.get("token")
    if not token:
        print("No token in auth response", file=sys.stderr)
        sys.exit(1)
    print("Auth OK")

    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
    }

    # 2. Fetch all chapter_audios
    records = []
    page = 1
    per_page = 100
    while True:
        url = f"{base}/api/collections/chapter_audios/records?page={page}&perPage={per_page}"
        req = Request(url, headers=headers)
        with urlopen(req) as r:
            data = json.loads(r.read())
        items = data.get("items", [])
        records.extend(items)
        total = data.get("totalItems", 0)
        print(f"Fetched page {page}: {len(items)} records (total so far: {len(records)}/{total})")
        if len(records) >= total or not items:
            break
        page += 1

    # 3. Update narrator
    updated = 0
    for r in records:
        rid = r.get("id")
        old_narrator = (r.get("narrator") or "").strip()
        if not old_narrator:
            continue
        lower = old_narrator.lower()
        new_narrator = None
        for key, val in NARRATOR_MAP.items():
            if key in lower:
                new_narrator = val
                break
        if new_narrator is None or new_narrator == old_narrator:
            continue

        print(f"  {rid}: '{old_narrator}' -> '{new_narrator}'")
        if args.dry_run:
            updated += 1
            continue

        patch_url = f"{base}/api/collections/chapter_audios/records/{rid}"
        patch_body = json.dumps({"narrator": new_narrator}).encode()
        req = Request(
            patch_url,
            data=patch_body,
            headers=headers,
            method="PATCH",
        )
        try:
            with urlopen(req):
                updated += 1
        except HTTPError as e:
            print(f"    FAILED: {e.code}", file=sys.stderr)

    print(f"\nDone. Updated {updated} records.")
    if args.dry_run:
        print("(dry-run, no changes made)")


if __name__ == "__main__":
    main()
