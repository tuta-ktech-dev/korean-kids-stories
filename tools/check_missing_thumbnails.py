#!/usr/bin/env python3
"""
Kiểm tra truyện nào chưa có thumbnail (ảnh bìa).
Liệt kê story IDs + title để gen ảnh.
Usage:
  python check_missing_thumbnails.py
  python check_missing_thumbnails.py --base-url URL
"""
import argparse
import json
import sys

BASE_URL = "http://trananhtu.vn:8090"
EMAIL = "ichimoku.0902@gmail.com"
PASSWORD = "@nhTu09022001"


def auth(base_url: str) -> str:
    import urllib.request

    req = urllib.request.Request(
        f"{base_url}/api/collections/_superusers/auth-with-password",
        data=json.dumps({"identity": EMAIL, "password": PASSWORD}).encode(),
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=30) as r:
        data = json.loads(r.read().decode())
    return data["token"]


def fetch_json(base_url: str, token: str, url: str) -> dict:
    import urllib.request

    req = urllib.request.Request(url, headers={"Authorization": token})
    with urllib.request.urlopen(req, timeout=60) as r:
        return json.loads(r.read().decode())


def has_thumbnail(record: dict) -> bool:
    """Check if story has thumbnail file."""
    thumb = record.get("thumbnail")
    if not thumb:
        return False
    if isinstance(thumb, str) and thumb.strip():
        return True
    if isinstance(thumb, list) and len(thumb) > 0:
        return True
    return False


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--base-url", default=BASE_URL, help="PocketBase base URL")
    args = parser.parse_args()

    print("Authenticating...")
    token = auth(args.base_url)

    print("Fetching stories...")
    data = fetch_json(
        args.base_url,
        token,
        f"{args.base_url}/api/collections/stories/records?perPage=500&filter=is_published=true&sort=title",
    )
    stories = data.get("items", [])
    if not stories:
        print("No published stories found.")
        return

    missing = [s for s in stories if not has_thumbnail(s)]

    if not missing:
        print("All stories have thumbnails. Nothing to generate.")
        return

    print(f"\n=== {len(missing)} stories missing thumbnails ===\n")
    for s in missing:
        print(f"  {s['id']}|{s.get('title', '')}")

    print(f"\nTotal: {len(missing)} stories need thumbnails.")


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
