#!/usr/bin/env python3
"""
Tạo sticker records cho các truyện có has_sticker. Set has_sticker=true nếu cần.
Usage:
  python seed_story_stickers.py [--base-url URL] [--enable-all]
"""
import argparse
import json
import sys
import urllib.request
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from pb_config import PB_BASE_URL, PB_EMAIL, PB_PASSWORD, require_pb_config


def auth(base_url: str, email: str, password: str) -> str:
    req = urllib.request.Request(
        f"{base_url}/api/collections/_superusers/auth-with-password",
        data=json.dumps({"identity": email, "password": password}).encode(),
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=30) as r:
        return json.loads(r.read().decode())["token"]


def fetch_json(base_url: str, token: str, url: str) -> dict:
    req = urllib.request.Request(url, headers={"Authorization": token})
    with urllib.request.urlopen(req, timeout=60) as r:
        return json.loads(r.read().decode())


def patch(base_url: str, token: str, collection: str, record_id: str, data: dict) -> dict:
    import urllib.request
    req = urllib.request.Request(
        f"{base_url}/api/collections/{collection}/records/{record_id}",
        data=json.dumps(data).encode(),
        headers={"Authorization": token, "Content-Type": "application/json"},
        method="PATCH",
    )
    with urllib.request.urlopen(req, timeout=30) as r:
        return json.loads(r.read().decode())


def post(base_url: str, token: str, collection: str, data: dict) -> dict:
    req = urllib.request.Request(
        f"{base_url}/api/collections/{collection}/records",
        data=json.dumps(data).encode(),
        headers={"Authorization": token, "Content-Type": "application/json"},
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=30) as r:
        return json.loads(r.read().decode())


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--base-url", default="")
    parser.add_argument("--enable-all", action="store_true", help="Set has_sticker=true for all published stories")
    args = parser.parse_args()
    require_pb_config()
    base_url = args.base_url or PB_BASE_URL

    print("Authenticating...")
    token = auth(base_url, PB_EMAIL, PB_PASSWORD)

    # Fetch stories
    data = fetch_json(
        base_url,
        token,
        f"{base_url}/api/collections/stories/records?perPage=500&filter=is_published=true&sort=title",
    )
    stories = data.get("items", [])
    if not stories:
        print("No published stories.")
        return

    # Fetch existing story stickers
    sticker_data = fetch_json(
        base_url,
        token,
        f"{base_url}/api/collections/stickers/records?perPage=500&filter=type%3D%22story%22",
    )
    existing = {s["story"]: s for s in sticker_data.get("items", []) if s.get("story")}

    created = 0
    enabled = 0

    for s in stories:
        sid = s["id"]
        title = s.get("title", "")
        has_sticker = s.get("has_sticker", False)

        if args.enable_all and not has_sticker:
            patch(base_url, token, "stories", sid, {"has_sticker": True})
            enabled += 1
            print(f"  Enabled has_sticker: {title}")

        if sid not in existing:
            key = f"story_{sid}"
            post(base_url, token, "stickers", {
                "type": "story",
                "key": key,
                "name_ko": title,
                "story": sid,
                "sort_order": 0,
                "is_published": True,
            })
            created += 1
            print(f"  Created sticker: {title} ({key})")

    print(f"\nCreated {created} stickers, enabled has_sticker for {enabled} stories.")


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
