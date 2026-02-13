#!/usr/bin/env python3
"""
Tải tất cả level stickers, xóa background (rembg), upload lại lên PocketBase.
Usage: python process_all_level_stickers_bg_removal.py [--dry-run]
"""
import io
import json
import subprocess
import sys
import tempfile
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


def download_file(url: str) -> bytes:
    req = urllib.request.Request(url)
    with urllib.request.urlopen(req, timeout=60) as r:
        return r.read()


def remove_bg(image_bytes: bytes, output_path: Path, size: int = 512) -> None:
    from rembg import remove as rembg_remove
    from PIL import Image

    out_img = rembg_remove(image_bytes)
    img = Image.open(io.BytesIO(out_img)).convert("RGBA")
    img.thumbnail((size, size), Image.Resampling.LANCZOS)
    img.save(output_path, "PNG", optimize=True)


def upload_image(base_url: str, token: str, sticker_id: str, image_path: Path) -> dict:
    result = subprocess.run(
        [
            "curl", "-s", "-X", "PATCH",
            f"{base_url}/api/collections/stickers/records/{sticker_id}",
            "-H", f"Authorization: {token}",
            "-F", f"image=@{image_path.absolute()}",
        ],
        capture_output=True,
        text=True,
        timeout=60,
        cwd=image_path.parent,
    )
    if result.returncode != 0:
        raise RuntimeError(f"Upload failed: {result.stderr or result.stdout}")
    return json.loads(result.stdout)


def main():
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true", help="Chỉ download + rembg, không upload")
    args = parser.parse_args()

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
    stickers = [s for s in data.get("items", []) if s.get("image")]

    if not stickers:
        print("No level stickers with images.")
        sys.exit(1)

    print(f"Found {len(stickers)} level stickers with images.\n")

    for i, rec in enumerate(stickers):
        rid = rec["id"]
        name = rec.get("name_ko", rid)
        img_field = rec.get("image")
        filename = img_field if isinstance(img_field, str) else img_field[0]
        file_url = f"{base_url}/api/files/stickers/{rid}/{filename}"

        print(f"[{i+1}/{len(stickers)}] {name} ({rid})")

        try:
            img_data = download_file(file_url)
        except Exception as e:
            print(f"  Download FAIL: {e}")
            continue

        with tempfile.NamedTemporaryFile(suffix=".png", delete=False) as tmp:
            tmp_path = Path(tmp.name)
        try:
            remove_bg(img_data, tmp_path)
            if args.dry_run:
                out = Path(__file__).parent.parent / "frontend" / "assets" / "images" / f"sticker_{rid}_no_bg.png"
                out.parent.mkdir(parents=True, exist_ok=True)
                tmp_path.rename(out)
                print(f"  -> {out} (dry-run, no upload)")
            else:
                upload_image(base_url, token, rid, tmp_path)
                print(f"  -> OK (uploaded)")
        except Exception as e:
            print(f"  FAIL: {e}")
        finally:
            if tmp_path.exists():
                tmp_path.unlink()

    print("\nDone!")


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
