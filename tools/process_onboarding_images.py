#!/usr/bin/env python3
"""
Xử lý ảnh onboarding để dễ hòa vào background (light/dark theme).
- Cách 1: Xóa background bằng rembg → transparent PNG, tự blend với mọi nền
- Cách 2: Fade viền → làm mềm góc ảnh để không có viền cứng

Usage:
  python process_onboarding_images.py [--method rembg|fade] [--input path] [--output path]
"""
import argparse
import sys
from pathlib import Path

# Frontend assets path
FRONTEND = Path(__file__).resolve().parent.parent / "frontend"
ASSETS = FRONTEND / "assets" / "images"
ONBOARDING_IMAGES = ["onboarding_1.png", "onboarding_2.png", "onboarding_3.png"]


def remove_bg_with_rembg(image_path: Path, output_path: Path) -> None:
    """Remove background using rembg - best for blending with any theme."""
    try:
        from rembg import remove as rembg_remove
        from PIL import Image
    except ImportError:
        print("Install: pip install rembg[cpu] Pillow")
        sys.exit(1)

    img = Image.open(image_path).convert("RGBA")
    out = rembg_remove(img)
    out.save(output_path)
    print(f"  rembg: {image_path.name} -> {output_path.name}")


def fade_edges(image_path: Path, output_path: Path, fade_pct: float = 0.15) -> None:
    """Fade edges to transparent - soft blend into background."""
    from PIL import Image, ImageDraw
    import math

    img = Image.open(image_path).convert("RGBA")
    w, h = img.size

    # Radial gradient: center opaque, edges fade to transparent
    fade_w = int(w * fade_pct)
    fade_h = int(h * fade_pct)
    cx, cy = w / 2, h / 2

    # Ellipse radius (use smaller dimension for circular fade)
    rx = (w - fade_w * 2) / 2
    ry = (h - fade_h * 2) / 2

    alpha = img.split()[3]
    alpha_data = alpha.load()

    for y in range(h):
        for x in range(w):
            # Distance from center (normalized 0 at center, 1 at edge of inner zone)
            dx = (x - cx) / rx if rx > 0 else 0
            dy = (y - cy) / ry if ry > 0 else 0
            d = math.sqrt(dx * dx + dy * dy)

            if d >= 1:
                # Outside ellipse - apply fade (1 = full opacity at edge, 0 = transparent at corners)
                # Smooth falloff
                t = min(1, (d - 1) * 3)  # 0..1 over the fade zone
                factor = 1 - t * t  # Quadratic falloff
                alpha_data[x, y] = int(alpha_data[x, y] * factor)
            # else: inside ellipse, keep original alpha

    img.putalpha(alpha)
    img.save(output_path)
    print(f"  fade: {image_path.name} -> {output_path.name}")


def main():
    parser = argparse.ArgumentParser(description="Process onboarding images for background blending")
    parser.add_argument(
        "--method",
        choices=["rembg", "fade"],
        default="rembg",
        help="rembg = remove background (transparent), fade = soft edges",
    )
    parser.add_argument("--input", type=Path, help="Single input file")
    parser.add_argument("--output", type=Path, help="Output path (default: overwrite input)")
    parser.add_argument("--fade-pct", type=float, default=0.15, help="Fade zone %% for fade method")
    args = parser.parse_args()

    if args.input:
        inputs = [args.input]
        if not args.input.exists():
            print(f"Error: {args.input} not found")
            sys.exit(1)
    else:
        inputs = [ASSETS / name for name in ONBOARDING_IMAGES if (ASSETS / name).exists()]

    if not inputs:
        print("No images found")
        sys.exit(1)

    for img_path in inputs:
        out_path = args.output or img_path
        if args.input and not args.output:
            # Single file, overwrite
            out_path = img_path
        elif not args.input and len(inputs) > 1:
            out_path = img_path  # Overwrite each

        if args.method == "rembg":
            remove_bg_with_rembg(img_path, out_path)
        else:
            fade_edges(img_path, out_path, args.fade_pct)


if __name__ == "__main__":
    main()
