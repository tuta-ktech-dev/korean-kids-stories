#!/usr/bin/env python3
"""
Xóa nền các ảnh streak và empty trong frontend/assets/images.
Output: PNG transparent (đổi extension trong pubspec nếu cần) hoặc WebP có alpha.
Usage: python process_assets_bg_removal.py
"""
import io
import sys
from pathlib import Path

ASSETS = Path(__file__).resolve().parent.parent / "frontend" / "assets" / "images"

STREAK_IMAGES = [
    "streak_3_days.webp",
    "streak_7_days.webp",
    "streak_14_days.webp",
    "streak_30_days.webp",
]

EMPTY_IMAGES = [
    "empty_no_stories.webp",
    "empty_no_search.webp",
    "empty_favorites.webp",
    "empty_reading_history.webp",
    "empty_story_stickers.webp",
    "empty_bookmarks.webp",
    "empty_notes.webp",
]


def remove_bg_and_save(input_path: Path, output_path: Path) -> None:
    from rembg import remove as rembg_remove
    from PIL import Image

    with open(input_path, "rb") as f:
        inp = f.read()

    out_img = rembg_remove(inp)
    img = Image.open(io.BytesIO(out_img)).convert("RGBA")

    # Save as PNG (full transparency support)
    img.save(output_path, "PNG", optimize=True)


def main():
    all_files = STREAK_IMAGES + EMPTY_IMAGES
    for name in all_files:
        src = ASSETS / name
        if not src.exists():
            print(f"Skip (not found): {name}")
            continue

        out_name = name.replace(".webp", ".png")
        dst = ASSETS / out_name

        print(f"Processing: {name} -> {out_name}")
        try:
            remove_bg_and_save(src, dst)
            if src != dst:
                src.unlink()
            print(f"  OK")
        except Exception as e:
            print(f"  FAIL: {e}")

    print("\nDone! Cập nhật pubspec + code dùng .png")


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
