#!/usr/bin/env python3
"""
Upload ảnh sticker lên PocketBase (stickers.image).
Giới hạn 2MB. Dùng --remove-bg để remove background trước khi upload (output PNG transparent).
Usage:
  python upload_sticker_images.py --map "sticker_id:path.jpg,..." [--base-url URL] [--remove-bg]
  python upload_sticker_images.py --image-dir DIR [--base-url URL] [--remove-bg]
"""
import argparse
import io
import json
import subprocess
import sys
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from pb_config import PB_BASE_URL, PB_EMAIL, PB_PASSWORD, require_pb_config


def remove_background(input_path: str, output_path: str, size: int = 512) -> str:
    """Remove background với rembg, resize, save PNG. Returns output path."""
    from rembg import remove
    from PIL import Image

    with open(input_path, "rb") as f:
        inp = f.read()
    out_img = remove(inp)
    img = Image.open(io.BytesIO(out_img)).convert("RGBA")
    img.thumbnail((size, size), Image.Resampling.LANCZOS)
    img.save(output_path, "PNG", optimize=True)
    return output_path


def auth(base_url: str, email: str, password: str) -> str:
    import urllib.request

    req = urllib.request.Request(
        f"{base_url}/api/collections/_superusers/auth-with-password",
        data=json.dumps({"identity": email, "password": password}).encode(),
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=30) as r:
        return json.loads(r.read().decode())["token"]


def upload_image(base_url: str, token: str, sticker_id: str, image_path: str) -> dict:
    path = Path(image_path)
    if not path.exists():
        raise FileNotFoundError(f"Not found: {image_path}")

    result = subprocess.run(
        [
            "curl", "-s", "-X", "PATCH",
            f"{base_url}/api/collections/stickers/records/{sticker_id}",
            "-H", f"Authorization: {token}",
            "-F", f"image=@{path.absolute()}",
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
    parser.add_argument("--base-url", default="")
    parser.add_argument("--map", help='id1:path1.jpg,id2:path2.jpg')
    parser.add_argument("--image-dir", help="Dir with sticker_xxx.webp or {sticker_id}.jpg")
    parser.add_argument("--remove-bg", action="store_true", help="Remove background trước khi upload (rembg)")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()
    require_pb_config()
    base_url = args.base_url or PB_BASE_URL

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
        seen: dict[str, str] = {}
        for pattern in ("*.webp", "*.jpg", "*.jpeg", "*.png"):
            for f in sorted(dir_path.glob(pattern)):
                stem = f.stem
                # Chỉ lấy file sticker_xxx (id = xxx)
                if stem.startswith("sticker_") and len(stem) > 8:
                    sid = stem[8:]
                    seen[sid] = str(f)
        pairs.extend(seen.items())
    else:
        print("Error: Use --map or --image-dir", file=sys.stderr)
        sys.exit(1)

    if not pairs:
        print("No sticker/image pairs.")
        return

    print("Authenticating...")
    token = auth(base_url, PB_EMAIL, PB_PASSWORD)

    for sticker_id, image_path in pairs:
        print(f"  {sticker_id}: {image_path}")
        if args.dry_run:
            continue
        upload_path = image_path
        tmp_path_to_clean: str | None = None
        if args.remove_bg:
            try:
                tmp = tempfile.NamedTemporaryFile(suffix=".png", delete=False)
                tmp_path = tmp.name
                tmp.close()
                remove_background(image_path, tmp_path)
                upload_path = tmp_path
                tmp_path_to_clean = tmp_path
                print(f"    (bg removed)")
            except Exception as e:
                print(f"    remove_bg FAIL: {e}, uploading original", file=sys.stderr)
        try:
            rec = upload_image(base_url, token, sticker_id, upload_path)
            img = rec.get("image") or "uploaded"
            print(f"    -> OK ({img})")
        except Exception as e:
            print(f"    -> FAIL: {e}", file=sys.stderr)
        finally:
            if tmp_path_to_clean and Path(tmp_path_to_clean).exists():
                Path(tmp_path_to_clean).unlink(missing_ok=True)


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
