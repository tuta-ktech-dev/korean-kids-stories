#!/usr/bin/env python3
"""
Upload thumbnail images to PocketBase stories.
Usage:
  python upload_thumbnails.py --image-dir DIR [--story-id ID] [--base-url URL]
  python upload_thumbnails.py --map "id1:path1.webp,id2:path2.webp" [--base-url URL]
"""
import argparse
import json
import subprocess
import sys
from pathlib import Path

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


def upload_thumbnail(base_url: str, token: str, story_id: str, image_path: str) -> dict:
    """PATCH story record with thumbnail file."""
    path = Path(image_path)
    if not path.exists():
        raise FileNotFoundError(f"Image not found: {image_path}")

    result = subprocess.run(
        [
            "curl", "-s", "-X", "PATCH",
            f"{base_url}/api/collections/stories/records/{story_id}",
            "-H", f"Authorization: {token}",
            "-F", f"thumbnail=@{path.absolute()}",
        ],
        capture_output=True,
        text=True,
        timeout=60,
        cwd=path.parent,
    )
    if result.returncode != 0:
        raise RuntimeError(f"Upload failed: {result.stderr or result.stdout}")
    return json.loads(result.stdout)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--base-url", default=BASE_URL, help="PocketBase base URL")
    parser.add_argument("--image-dir", help="Directory with images named {story_id}.webp")
    parser.add_argument("--story-id", help="Specific story ID (use with --image-dir)")
    parser.add_argument("--map", help='Comma-separated id:path pairs, e.g. "id1:path1.webp,id2:path2.webp"')
    parser.add_argument("--dry-run", action="store_true", help="Show what would be uploaded")
    args = parser.parse_args()

    pairs: list[tuple[str, str]] = []

    if args.map:
        for part in args.map.split(","):
            part = part.strip()
            if ":" in part:
                sid, p = part.split(":", 1)
                pairs.append((sid.strip(), p.strip()))
    elif args.image_dir:
        dir_path = Path(args.image_dir)
        if not dir_path.is_dir():
            print(f"Error: Not a directory: {dir_path}", file=sys.stderr)
            sys.exit(1)
        if args.story_id:
            for ext in ("webp", "jpg", "jpeg", "png"):
                p = dir_path / f"{args.story_id}.{ext}"
                if p.exists():
                    pairs.append((args.story_id, str(p)))
                    break
        else:
            seen: dict[str, str] = {}
            for pattern in ("*.webp", "*.jpg", "*.jpeg", "*.png"):
                for f in sorted(dir_path.glob(pattern)):
                    sid = f.stem
                    if len(sid) >= 10:  # PocketBase IDs are usually 15 chars
                        seen[sid] = str(f)
            pairs.extend(seen.items())
    else:
        print("Error: Use --map or --image-dir (and optionally --story-id)", file=sys.stderr)
        sys.exit(1)

    if not pairs:
        print("No image/story pairs to upload.")
        return

    print("Authenticating...")
    token = auth(args.base_url)

    for story_id, image_path in pairs:
        print(f"  {story_id}: {image_path}")
        if args.dry_run:
            continue
        try:
            rec = upload_thumbnail(args.base_url, token, story_id, image_path)
            thumb = rec.get("thumbnail") or rec.get("thumbnailUrl") or "uploaded"
            print(f"    -> OK ({thumb})")
        except Exception as e:
            print(f"    -> FAIL: {e}", file=sys.stderr)


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
