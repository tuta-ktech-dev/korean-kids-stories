#!/usr/bin/env python3
"""
Tải 1 sticker level về, xóa background bằng rembg, lưu để xem thử.
Usage: python download_sticker_test_bg_removal.py [--base-url URL]
"""
import json
import sys
import urllib.request
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from pb_config import PB_BASE_URL, PB_EMAIL, PB_PASSWORD, require_pb_config

OUTPUT_DIR = Path(__file__).resolve().parent.parent / "frontend" / "assets" / "images"
OUTPUT_ORIGINAL = OUTPUT_DIR / "sticker_level_test_original.png"
OUTPUT_NO_BG = OUTPUT_DIR / "sticker_level_test_no_bg.png"


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


def download_file(url: str, dest: Path) -> None:
    req = urllib.request.Request(url)
    with urllib.request.urlopen(req, timeout=30) as r:
        dest.write_bytes(r.read())


def remove_bg(input_path: Path, output_path: Path) -> None:
    from rembg import remove as rembg_remove
    from PIL import Image
    import io

    with open(input_path, "rb") as f:
        inp = f.read()
    out_img = rembg_remove(inp)
    img = Image.open(io.BytesIO(out_img)).convert("RGBA")
    img.save(output_path)
    print(f"  Saved (no bg): {output_path}")


def main():
    require_pb_config()
    base_url = PB_BASE_URL

    print("Authenticating...")
    token = auth(base_url, PB_EMAIL, PB_PASSWORD)

    print("Fetching level stickers...")
    data = fetch_json(
        base_url,
        token,
        f"{base_url}/api/collections/stickers/records?perPage=50&filter=type%3D%22level%22&sort=sort_order",
    )
    stickers = data.get("items", [])

    # Find first with image
    with_image = [s for s in stickers if s.get("image")]
    if not with_image:
        print("No level sticker has image. Try story stickers?")
        data2 = fetch_json(
            base_url,
            token,
            f"{base_url}/api/collections/stickers/records?perPage=10&filter=type%3D%22story%22",
        )
        with_image = [s for s in data2.get("items", []) if s.get("image")]

    if not with_image:
        print("No stickers with images found.")
        sys.exit(1)

    rec = with_image[0]
    rid = rec["id"]
    img_field = rec.get("image")
    filename = img_field if isinstance(img_field, str) else (img_field[0] if img_field else None)

    if not filename:
        print("Sticker has no image filename.")
        sys.exit(1)

    file_url = f"{base_url}/api/files/stickers/{rid}/{filename}"
    print(f"Downloading: {rec.get('name_ko', rid)} ({file_url})")

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    download_file(file_url, OUTPUT_ORIGINAL)
    print(f"  Saved (original): {OUTPUT_ORIGINAL}")

    print("Removing background (rembg)...")
    remove_bg(OUTPUT_ORIGINAL, OUTPUT_NO_BG)

    print("\nDone! Xem 2 file:")
    print(f"  - Original: {OUTPUT_ORIGINAL}")
    print(f"  - No BG:    {OUTPUT_NO_BG}")


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
