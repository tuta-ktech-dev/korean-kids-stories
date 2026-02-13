#!/usr/bin/env python3
"""
Liệt kê story stickers chưa có ảnh (để gen).
Usage: python check_missing_sticker_images.py [--base-url URL]
"""
import argparse
import json
import sys
import urllib.request

BASE_URL = "http://trananhtu.vn:8090"
EMAIL = "ichimoku.0902@gmail.com"
PASSWORD = "@nhTu09022001"


def auth(base_url: str) -> str:
    req = urllib.request.Request(
        f"{base_url}/api/collections/_superusers/auth-with-password",
        data=json.dumps({"identity": EMAIL, "password": PASSWORD}).encode(),
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=30) as r:
        return json.loads(r.read().decode())["token"]


def fetch_json(base_url: str, token: str, url: str) -> dict:
    req = urllib.request.Request(url, headers={"Authorization": token})
    with urllib.request.urlopen(req, timeout=60) as r:
        return json.loads(r.read().decode())


def has_image(record: dict) -> bool:
    img = record.get("image")
    if not img:
        return False
    if isinstance(img, str) and img.strip():
        return True
    if isinstance(img, list) and len(img) > 0:
        return True
    return False


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--base-url", default=BASE_URL)
    args = parser.parse_args()

    print("Authenticating...")
    token = auth(args.base_url)

    data = fetch_json(
        args.base_url,
        token,
        f"{args.base_url}/api/collections/stickers/records?perPage=500&filter=type%3D%22story%22&expand=story",
    )
    stickers = data.get("items", [])

    missing = [s for s in stickers if not has_image(s)]
    if not missing:
        print("All story stickers have images.")
        return

    print(f"\n=== {len(missing)} stickers missing images ===\n")
    for s in missing:
        story = s.get("expand", {}).get("story", {})
        title = story.get("title", s.get("name_ko", ""))
        print(f"  {s['id']}|{s.get('story','')}|{title}")

    print(f"\nTotal: {len(missing)} need images.")


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
