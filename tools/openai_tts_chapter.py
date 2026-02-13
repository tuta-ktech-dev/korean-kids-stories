#!/usr/bin/env python3
"""
Tạo 1 audio cho 1 chapter bằng OpenAI TTS, upload lên chapter_audios.
Dùng cho test giọng ChatGPT/OpenAI.
Usage: OPENAI_API_KEY=sk-xxx python openai_tts_chapter.py [--chapter-id ID]
"""
import argparse
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from pb_config import PB_BASE_URL, PB_EMAIL, PB_PASSWORD, require_pb_config
# Truyện 1 chapter: 흥부와 놀부
DEFAULT_CHAPTER_ID = "cryv1m3q1qg6r97"
NARRATOR = "새 목소리"  # Tên hiển thị cho bé (không ghi brand)


def auth(base_url: str, email: str, password: str) -> str:
    """Authenticate and return Bearer token."""
    from urllib.request import Request, urlopen
    req = Request(
        f"{base_url}/api/collections/_superusers/auth-with-password",
        data=json.dumps({"identity": email, "password": password}).encode(),
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    with urlopen(req, timeout=30) as r:
        data = json.loads(r.read().decode())
    return data["token"]


def fetch_chapter(base_url: str, token: str, chapter_id: str) -> dict:
    """Fetch chapter content."""
    from urllib.request import Request, urlopen
    req = Request(
        f"{base_url}/api/collections/chapters/records/{chapter_id}",
        headers={"Authorization": f"Bearer {token}"},
    )
    with urlopen(req, timeout=30) as r:
        return json.loads(r.read().decode())


def strip_content(text: str) -> str:
    """Strip HTML and normalize for TTS."""
    if not text:
        return ""
    text = re.sub(r"<[^>]+>", " ", text)
    text = re.sub(r"\s+", " ", text).strip()
    return text


def generate_openai_tts(text: str, api_key: str, out_path: str, voice: str = "shimmer") -> bool:
    """Generate TTS with OpenAI API. Returns mp3."""
    # OpenAI TTS supports Korean. Use urllib to avoid extra deps.
    import urllib.request
    url = "https://api.openai.com/v1/audio/speech"
    body = json.dumps({
        "model": "tts-1-hd",
        "input": text[:4096],  # API limit
        "voice": voice,
        "response_format": "mp3",
    }).encode()
    req = urllib.request.Request(
        url,
        data=body,
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
        },
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=120) as r:
            with open(out_path, "wb") as f:
                f.write(r.read())
        return True
    except urllib.error.HTTPError as e:
        print(f"OpenAI TTS error: {e.code} {e.reason}", file=sys.stderr)
        if e.fp:
            print(e.fp.read().decode(), file=sys.stderr)
        return False


def get_audio_duration_sec(mp3_path: str) -> float:
    """Get duration in seconds using ffprobe or fallback."""
    try:
        out = subprocess.run(
            ["ffprobe", "-v", "error", "-show_entries", "format=duration",
             "-of", "default=noprint_wrappers=1:nokey=1", mp3_path],
            capture_output=True, text=True, timeout=5,
        )
        if out.returncode == 0 and out.stdout.strip():
            return float(out.stdout.strip())
    except (FileNotFoundError, subprocess.TimeoutExpired):
        pass
    return 0.0


def upload_audio(base_url: str, token: str, chapter_id: str, audio_path: str,
                 narrator: str, duration_sec: float = 0) -> dict:
    """Upload audio to chapter_audios."""
    args = [
        "curl", "-s", "-X", "POST",
        f"{base_url}/api/collections/chapter_audios/records",
        "-H", f"Authorization: Bearer {token}",
        "-F", f"chapter={chapter_id}",
        "-F", f"narrator={narrator}",
        "-F", f"audio_file=@{audio_path}",
    ]
    if duration_sec > 0:
        args.extend(["-F", f"audio_duration={duration_sec}"])
    result = subprocess.run(args, capture_output=True, text=True, timeout=120)
    if result.returncode != 0:
        raise RuntimeError(f"Upload failed: {result.stderr or result.stdout}")
    return json.loads(result.stdout)


def main():
    parser = argparse.ArgumentParser(description="Generate 1 chapter audio with OpenAI TTS")
    parser.add_argument("--chapter-id", default=DEFAULT_CHAPTER_ID, help="Chapter ID")
    parser.add_argument("--base-url", default="", help="PocketBase URL (hoặc PB_BASE_URL env)")
    parser.add_argument("--voice", default="shimmer",
                        help="OpenAI voice: alloy, echo, fable, onyx, nova, shimmer")
    parser.add_argument("--max-chars", type=int, default=2000, help="Max chars (API limit 4096)")
    parser.add_argument("--dry-run", action="store_true", help="Fetch only, no TTS/upload")
    args = parser.parse_args()

    api_key = os.environ.get("OPENAI_API_KEY")
    if not api_key and not args.dry_run:
        print("Error: set OPENAI_API_KEY env var", file=sys.stderr)
        print("  export OPENAI_API_KEY=sk-...", file=sys.stderr)
        sys.exit(1)

    require_pb_config()
    base_url = args.base_url or PB_BASE_URL
    print("Auth...")
    pb_token = auth(base_url, PB_EMAIL, PB_PASSWORD)
    print("Fetch chapter...")
    ch = fetch_chapter(base_url, pb_token, args.chapter_id)
    content = strip_content(ch.get("content", ""))
    if not content:
        print("No content in chapter", file=sys.stderr)
        sys.exit(1)
    text = content[:args.max_chars]
    print(f"Chapter: {ch.get('title', 'N/A')} ({len(text)} chars)")

    if args.dry_run:
        print(f"[dry-run] Would generate TTS and upload as narrator='{NARRATOR}'")
        return

    with tempfile.NamedTemporaryFile(suffix=".mp3", delete=False) as tmp:
        mp3_path = tmp.name
    try:
        print("Generating OpenAI TTS...")
        if not generate_openai_tts(text, api_key, mp3_path, args.voice):
            sys.exit(1)
        duration = get_audio_duration_sec(mp3_path)
        print(f"  Duration: {duration:.1f}s")
        print("Uploading...")
        rec = upload_audio(
            base_url, pb_token, args.chapter_id, mp3_path,
            narrator=NARRATOR, duration_sec=duration,
        )
        print(f"Done -> {rec.get('id')} (narrator={NARRATOR})")
    finally:
        Path(mp3_path).unlink(missing_ok=True)


if __name__ == "__main__":
    main()
