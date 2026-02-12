#!/usr/bin/env python3
"""
Lấy 1 bộ truyện từ PocketBase, tạo TTS audio, upload lên chapter_audios.
Usage: python story_to_audio.py [--story-id ID] [--base-url URL]
"""
import argparse
import json
import logging
import os
import re
import sys
import tempfile
from pathlib import Path

# Add parent for imports
sys.path.insert(0, str(Path(__file__).resolve().parent))

logging.getLogger("TTS.tts.utils.text.tokenizer").setLevel(logging.ERROR)

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


def fetch_story_and_chapters(base_url: str, token: str, story_id: str | None = None) -> tuple[dict, list]:
    """Fetch a story and its chapters."""
    import urllib.request
    if story_id:
        # Get specific story
        req = urllib.request.Request(
            f"{base_url}/api/collections/stories/records/{story_id}",
            headers={"Authorization": token},
        )
        with urllib.request.urlopen(req, timeout=30) as r:
            story = json.loads(r.read().decode())
    else:
        # Get first story
        req = urllib.request.Request(
            f"{base_url}/api/collections/stories/records?perPage=1&filter=is_published=true",
            headers={"Authorization": token},
        )
        with urllib.request.urlopen(req, timeout=30) as r:
            data = json.loads(r.read().decode())
            story = data["items"][0] if data.get("items") else None
    if not story:
        raise ValueError("No story found")

    sid = story["id"]
    req = urllib.request.Request(
        f"{base_url}/api/collections/chapters/records?filter=(story='{sid}')&sort=chapter_number",
        headers={"Authorization": token},
    )
    with urllib.request.urlopen(req, timeout=30) as r:
        data = json.loads(r.read().decode())
    chapters = data.get("items", [])
    return story, chapters


def strip_content(text: str) -> str:
    """Strip HTML and normalize for TTS."""
    if not text:
        return ""
    text = re.sub(r"<[^>]+>", " ", text)
    text = re.sub(r"\s+", " ", text).strip()
    return text


def generate_tts(text: str, model_path: str, config_path: str, out_path: str) -> bool:
    """Generate TTS audio with KSS model."""
    from TTS.api import TTS
    import json as _json

    # Patch config for cleaner voice
    with open(config_path, encoding="utf-8") as f:
        cfg = _json.load(f)
    ma = cfg.get("model_args") or cfg.get("model") or {}
    if isinstance(ma, dict):
        ma["inference_noise_scale"] = ma.get("inference_noise_scale", 0.667) * 0.6
        ma["inference_noise_scale_dp"] = ma.get("inference_noise_scale_dp", 1.0) * 0.8
    with tempfile.NamedTemporaryFile(mode="w", suffix=".json", delete=False, encoding="utf-8") as tmp:
        _json.dump(cfg, tmp, ensure_ascii=False, indent=2)
        _cfg_path = tmp.name
    try:
        tts = TTS(model_path=model_path, config_path=_cfg_path, progress_bar=False)
        tts.tts_to_file(text=text.strip(), file_path=out_path)
        return True
    finally:
        Path(_cfg_path).unlink(missing_ok=True)


def upload_audio(base_url: str, token: str, chapter_id: str, audio_path: str, narrator: str = "KSS") -> dict:
    """Upload audio to chapter_audios collection (via curl for reliable multipart)."""
    import subprocess
    result = subprocess.run(
        [
            "curl", "-s", "-X", "POST",
            f"{base_url}/api/collections/chapter_audios/records",
            "-H", f"Authorization: {token}",
            "-F", f"chapter={chapter_id}",
            "-F", f"narrator={narrator}",
            "-F", f"audio_file=@{audio_path}",
        ],
        capture_output=True,
        text=True,
        timeout=120,
    )
    if result.returncode != 0:
        raise RuntimeError(f"Upload failed: {result.stderr or result.stdout}")
    return json.loads(result.stdout)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--story-id", help="Story ID (default: first published)")
    parser.add_argument("--base-url", default=BASE_URL, help="PocketBase base URL")
    parser.add_argument("--model", default="/tmp/best_model.pth", help="KSS model path")
    parser.add_argument("--config", default="/tmp/config.json", help="KSS config path")
    parser.add_argument("--max-chars", type=int, default=500, help="Max chars per TTS chunk (default 500)")
    parser.add_argument("--dry-run", action="store_true", help="Fetch only, no TTS/upload")
    args = parser.parse_args()

    if not Path(args.model).exists() or not Path(args.config).exists():
        print("Error: KSS model not found. Download first:", file=sys.stderr)
        print("  curl -L -o /tmp/best_model.pth https://huggingface.co/neurlang/coqui-vits-kss-korean/resolve/main/best_model.pth", file=sys.stderr)
        print("  curl -L -o /tmp/config.json https://huggingface.co/neurlang/coqui-vits-kss-korean/resolve/main/config.json", file=sys.stderr)
        sys.exit(1)

    os.environ["COQUI_TOS_AGREED"] = "1"

    print("Auth...")
    token = auth(args.base_url)
    print("Fetch story + chapters...")
    story, chapters = fetch_story_and_chapters(args.base_url, token, args.story_id)
    print(f"Story: {story.get('title')} (id={story['id']}), chapters: {len(chapters)}")

    if args.dry_run:
        for ch in chapters:
            content = strip_content(ch.get("content", ""))
            print(f"  Ch{ch['chapter_number']}: {len(content)} chars")
        return

    for ch in chapters:
        ch_id = ch["id"]
        content = strip_content(ch.get("content", ""))
        if not content:
            print(f"  Ch{ch['chapter_number']}: no content, skip")
            continue

        # Chunk if too long (VITS has limits)
        chunks = []
        for i in range(0, len(content), args.max_chars):
            chunks.append(content[i : i + args.max_chars])
        full_text = " ".join(chunks) if len(chunks) > 1 else content
        if len(full_text) > 1500:  # cap for speed
            full_text = full_text[:1500] + "."
        print(f"  Ch{ch['chapter_number']}: generating TTS ({len(full_text)} chars)...")

        with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as tmp:
            wav_path = tmp.name
        try:
            generate_tts(full_text, args.model, args.config, wav_path)
            print(f"  Ch{ch['chapter_number']}: uploading...")
            rec = upload_audio(args.base_url, token, ch_id, wav_path)
            print(f"  Ch{ch['chapter_number']}: done -> {rec.get('id')}")
        finally:
            Path(wav_path).unlink(missing_ok=True)

    print("Done.")


if __name__ == "__main__":
    import multiprocessing
    try:
        multiprocessing.set_start_method("spawn", force=True)
    except RuntimeError:
        pass
    try:
        main()
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
    os._exit(0)
