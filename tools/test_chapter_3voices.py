#!/usr/bin/env python3
"""
Gen 1 chapter với 3 giọng khác nhau (coral, nova, fable) để so sánh.
Không upload, chỉ lưu file local.
Usage: OPENAI_API_KEY=sk-xxx python test_chapter_3voices.py [--chapter-id ID]
"""
import json
import os
import re
import subprocess
import sys
from pathlib import Path
from urllib.request import Request, urlopen
from urllib.error import HTTPError

sys.path.insert(0, str(Path(__file__).resolve().parent))
from pb_config import PB_BASE_URL, PB_EMAIL, PB_PASSWORD, require_pb_config

DEFAULT_CHAPTER_ID = "cryv1m3q1qg6r97"  # 흥부와 놀부
VOICES = ["coral", "nova", "fable"]
STORY_INSTRUCTIONS = "Speak in a warm, gentle storytelling voice for children. Friendly and engaging, not formal."


def auth(base_url: str, email: str, password: str) -> str:
    req = Request(
        f"{base_url}/api/collections/_superusers/auth-with-password",
        data=json.dumps({"identity": email, "password": password}).encode(),
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    with urlopen(req, timeout=30) as r:
        return json.loads(r.read())["token"]


def fetch_chapter(base_url: str, token: str, chapter_id: str) -> dict:
    req = Request(
        f"{base_url}/api/collections/chapters/records/{chapter_id}",
        headers={"Authorization": f"Bearer {token}"},
    )
    with urlopen(req, timeout=30) as r:
        return json.loads(r.read())


def strip_content(text: str) -> str:
    if not text:
        return ""
    text = re.sub(r"<[^>]+>", " ", text)
    return re.sub(r"\s+", " ", text).strip()


def gen_tts(api_key: str, text: str, out_path: Path, voice: str) -> bool:
    url = "https://api.openai.com/v1/audio/speech"
    payload = {
        "model": "gpt-4o-mini-tts",
        "input": text[:4096],
        "voice": voice,
        "instructions": STORY_INSTRUCTIONS,
        "response_format": "mp3",
    }
    req = Request(
        url,
        data=json.dumps(payload).encode(),
        headers={"Authorization": f"Bearer {api_key}", "Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urlopen(req, timeout=180) as r:
            with open(out_path, "wb") as f:
                f.write(r.read())
        return True
    except HTTPError as e:
        print(f"  {voice}: Error {e.code}", file=sys.stderr)
        if e.fp:
            print(e.fp.read().decode()[:200], file=sys.stderr)
        return False


def get_duration(path: Path) -> float:
    try:
        out = subprocess.run(
            ["ffprobe", "-v", "error", "-show_entries", "format=duration",
             "-of", "default=noprint_wrappers=1:nokey=1", str(path)],
            capture_output=True, text=True, timeout=5,
        )
        return float(out.stdout.strip()) if out.returncode == 0 else 0
    except Exception:
        return 0


def main():
    api_key = os.environ.get("OPENAI_API_KEY")
    if not api_key:
        print("Error: set OPENAI_API_KEY", file=sys.stderr)
        sys.exit(1)

    chapter_id = os.environ.get("CHAPTER_ID", DEFAULT_CHAPTER_ID)
    if len(sys.argv) > 1 and not sys.argv[1].startswith("-"):
        chapter_id = sys.argv[1]

    require_pb_config()
    base_url = (PB_BASE_URL or "").rstrip("/")
    print("Auth PocketBase...")
    token = auth(base_url, PB_EMAIL, PB_PASSWORD)
    print("Fetch chapter...")
    ch = fetch_chapter(base_url, token, chapter_id)
    content = strip_content(ch.get("content", ""))
    if not content:
        print("No content", file=sys.stderr)
        sys.exit(1)
    text = content[:3500]
    title = (ch.get("title") or "chapter")[:30]
    print(f"Chapter: {title} ({len(text)} chars)\n")

    out_dir = Path(__file__).parent
    for i, voice in enumerate(VOICES, 1):
        print(f"[{i}/3] Generating {voice}...", end=" ", flush=True)
        out_path = out_dir / f"chapter_{voice}.mp3"
        if gen_tts(api_key, text, out_path, voice):
            dur = get_duration(out_path)
            print(f"ok ({dur:.0f}s) -> {out_path.name}")
        else:
            print("fail")

    print(f"\n>> Nghe: open tools/chapter_coral.mp3 tools/chapter_nova.mp3 tools/chapter_fable.mp3")


if __name__ == "__main__":
    main()
