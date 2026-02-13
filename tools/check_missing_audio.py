#!/usr/bin/env python3
"""
Kiểm tra truyện/chương nào chưa có audio (chapter_audios).
Liệt kê story IDs cần gen. Có thể chạy gen tự động.
Usage:
  python check_missing_audio.py              # chỉ liệt kê
  python check_missing_audio.py --gen        # gen audio cho các truyện thiếu
  python check_missing_audio.py --base-url URL
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
    """Authenticate and return token."""
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


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--base-url", default=BASE_URL, help="PocketBase base URL")
    parser.add_argument("--gen", action="store_true", help="Run story_to_audio.py for each missing story")
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

    print("Fetching chapters...")
    chapters_by_story: dict[str, list[dict]] = {}
    for s in stories:
        sid = s["id"]
        data = fetch_json(
            args.base_url,
            token,
            f"{args.base_url}/api/collections/chapters/records?perPage=200&filter=(story='{sid}')&sort=chapter_number",
        )
        chapters_by_story[sid] = data.get("items", [])

    print("Fetching chapter_audios...")
    data = fetch_json(
        args.base_url,
        token,
        f"{args.base_url}/api/collections/chapter_audios/records?perPage=2000&expand=chapter",
    )
    all_audios = data.get("items", [])
    # Paginate if more
    while data.get("totalPages", 1) > data.get("page", 1):
        page = data.get("page", 1) + 1
        data = fetch_json(
            args.base_url,
            token,
            f"{args.base_url}/api/collections/chapter_audios/records?perPage=2000&page={page}",
        )
        all_audios.extend(data.get("items", []))

    chapters_with_audio: set[str] = {a.get("chapter") for a in all_audios if a.get("chapter")}

    missing: list[tuple[dict, list[dict]]] = []
    for s in stories:
        sid = s["id"]
        chaps = chapters_by_story.get(sid, [])
        chaps_no_audio = [c for c in chaps if c["id"] not in chapters_with_audio]
        if chaps_no_audio:
            missing.append((s, chaps_no_audio))

    if not missing:
        print("All stories have audio. Nothing to generate.")
        return

    print(f"\n=== {len(missing)} stories missing audio ===\n")
    for s, chaps in missing:
        print(f"  {s['title']} (id={s['id']}) - {len(chaps)} chapters without audio")
        for c in chaps[:3]:
            print(f"    - Ch{c['chapter_number']}: {c['title'][:50]}...")
        if len(chaps) > 3:
            print(f"    ... +{len(chaps) - 3} more")
        print()

    if args.gen:
        script_dir = Path(__file__).resolve().parent
        story_to_audio = script_dir / "story_to_audio.py"
        if not story_to_audio.exists():
            print("Error: story_to_audio.py not found", file=sys.stderr)
            sys.exit(1)
        for s, _ in missing:
            sid = s["id"]
            print(f"\n>>> Generating audio for: {s['title']} ({sid})")
            rc = subprocess.run(
                [sys.executable, str(story_to_audio), "--story-id", sid, "--base-url", args.base_url],
                cwd=str(script_dir),
            )
            if rc.returncode != 0:
                print(f"  FAILED for {sid}", file=sys.stderr)
        print("\nDone.")
    else:
        print("Run with --gen to generate audio for these stories.")


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
