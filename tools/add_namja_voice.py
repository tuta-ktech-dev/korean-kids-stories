#!/usr/bin/env python3
"""
Thêm giọng 남자 (male) cho các chapter chỉ có 여자.
Dùng OpenAI TTS (voice onyx/echo = male). Cần OPENAI_API_KEY.
Usage:
  OPENAI_API_KEY=sk-xxx python add_namja_voice.py --limit 5
  OPENAI_API_KEY=sk-xxx python add_namja_voice.py   # tất cả
"""
import argparse
import json
import os
import re
import subprocess
import sys
import tempfile
import time
from collections import defaultdict
from pathlib import Path
from urllib.request import Request, urlopen
from urllib.error import HTTPError

sys.path.insert(0, str(Path(__file__).resolve().parent))
from pb_config import PB_BASE_URL, PB_EMAIL, PB_PASSWORD, require_pb_config

OPENAI_VOICE_MALE = "nova"  # nova (ấm, kể chuyện ok), onyx/echo (nam hơn)
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


def fetch_all(base_url: str, token: str, collection: str, filter_str: str = "") -> list:
    records = []
    page = 1
    while True:
        url = f"{base_url}/api/collections/{collection}/records?page={page}&perPage=200"
        if filter_str:
            url += f"&filter={filter_str}"
        req = Request(url, headers={"Authorization": f"Bearer {token}"})
        with urlopen(req, timeout=60) as r:
            data = json.loads(r.read())
        items = data.get("items", [])
        records.extend(items)
        if len(items) < 200:
            break
        page += 1
    return records


def strip_content(text: str) -> str:
    if not text:
        return ""
    text = re.sub(r"<[^>]+>", " ", text)
    return re.sub(r"\s+", " ", text).strip()


def generate_openai_tts(text: str, api_key: str, out_path: str, voice: str = OPENAI_VOICE_MALE,
                        model: str = "gpt-4o-mini-tts", instructions: str = None) -> bool:
    url = "https://api.openai.com/v1/audio/speech"
    payload = {
        "model": model,
        "input": text[:4096],
        "voice": voice,
        "response_format": "mp3",
    }
    if instructions and model == "gpt-4o-mini-tts":
        payload["instructions"] = instructions
    body = json.dumps(payload).encode()
    req = Request(
        url,
        data=body,
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
        },
        method="POST",
    )
    try:
        with urlopen(req, timeout=300) as r:
            with open(out_path, "wb") as f:
                f.write(r.read())
        return True
    except HTTPError as e:
        print(f"OpenAI TTS error: {e.code}", file=sys.stderr)
        if e.fp:
            try:
                print(e.fp.read().decode()[:500], file=sys.stderr)
            except Exception:
                pass
        return False


def get_duration_sec(path: str) -> float:
    try:
        out = subprocess.run(
            ["ffprobe", "-v", "error", "-show_entries", "format=duration",
             "-of", "default=noprint_wrappers=1:nokey=1", path],
            capture_output=True, text=True, timeout=5,
        )
        if out.returncode == 0 and out.stdout.strip():
            return float(out.stdout.strip())
    except (FileNotFoundError, subprocess.TimeoutExpired):
        pass
    return 0.0


def upload_audio(base_url: str, token: str, chapter_id: str, audio_path: str, duration: float) -> dict:
    args = [
        "curl", "-s", "-X", "POST",
        f"{base_url}/api/collections/chapter_audios/records",
        "-H", f"Authorization: Bearer {token}",
        "-F", f"chapter={chapter_id}",
        "-F", "narrator=남자",
        "-F", f"audio_file=@{audio_path}",
        "-F", f"audio_duration={duration}",
    ]
    result = subprocess.run(args, capture_output=True, text=True, timeout=120)
    if result.returncode != 0:
        raise RuntimeError(result.stderr or result.stdout)
    return json.loads(result.stdout)


def has_namja(narrators: set) -> bool:
    for n in narrators:
        if not n:
            continue
        x = n.strip().lower()
        if x in ("남자", "male", "nam") or "남자" in n:
            return True
    return False


def has_yeoja(narrators: set) -> bool:
    for n in narrators:
        if not n:
            continue
        x = n.strip().lower()
        if x in ("여자", "female", "nu", "nữ") or "여자" in n or "새 목소리" in n:
            return True
    return False


# gpt-4o-mini-tts ~$0.015/min; tts-1-hd $30/1M chars
BUDGET_USD = 3.0
EST_COST_PER_MIN = 0.015

def main():
    parser = argparse.ArgumentParser(description="Add 남자 voice with OpenAI TTS (nova, storytelling)")
    parser.add_argument("--limit", type=int, default=0, help="Max chapters (0=all)")
    parser.add_argument("--base-url", default="")
    parser.add_argument("--voice", default=OPENAI_VOICE_MALE, help="nova, coral, fable, onyx...")
    parser.add_argument("--max-chars", type=int, default=3500)
    parser.add_argument("--max-budget", type=float, default=BUDGET_USD, help="Stop when cost exceeds (USD)")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    api_key = os.environ.get("OPENAI_API_KEY")
    if not api_key and not args.dry_run:
        print("Error: set OPENAI_API_KEY env var", file=sys.stderr)
        sys.exit(1)

    require_pb_config()
    base_url = args.base_url or PB_BASE_URL

    print("Auth...")
    token = auth(base_url, PB_EMAIL, PB_PASSWORD)

    print("Fetch chapter_audios...")
    audios = fetch_all(base_url, token, "chapter_audios")
    ch_to_narrators = defaultdict(set)
    for r in audios:
        ch_to_narrators[r["chapter"]].add(r.get("narrator") or "")

    missing = [cid for cid, narrators in ch_to_narrators.items()
               if has_yeoja(narrators) and not has_namja(narrators)]
    print(f"Chapters thiếu 남자: {len(missing)}")

    if args.limit:
        missing = missing[: args.limit]
        print(f"Chỉ xử lý {len(missing)} chapter đầu")

    chapters_by_id = {}
    for ch_id in missing:
        try:
            req = Request(
                f"{base_url}/api/collections/chapters/records/{ch_id}",
                headers={"Authorization": f"Bearer {token}"},
            )
            with urlopen(req, timeout=30) as r:
                chapters_by_id[ch_id] = json.loads(r.read())
        except HTTPError as e:
            if e.code != 404:
                raise

    ok = 0
    fail = 0
    accumulated_cost = 0.0
    instructions = STORY_INSTRUCTIONS
    model = "gpt-4o-mini-tts"

    for i, ch_id in enumerate(missing):
        if accumulated_cost >= args.max_budget:
            print(f"\n>> Đã đạt ngân sách ${args.max_budget:.2f}, dừng.")
            break
        ch = chapters_by_id.get(ch_id)
        if not ch:
            continue
        content = strip_content(ch.get("content", ""))
        if not content or len(content) < 10:
            continue
        text = content[: args.max_chars]
        title = (ch.get("title") or "?")[:30]
        est_min = len(text) / 15  # ~15 chars/sec speech
        est_cost = est_min * EST_COST_PER_MIN
        if accumulated_cost + est_cost > args.max_budget:
            print(f"\n>> Chương tiếp theo ước ~${est_cost:.3f}, vượt ngân sách. Dừng.")
            break

        if args.dry_run:
            print(f"  [{i+1}] {ch_id} ({title}): would add 남자 ({len(text)} chars, ~${est_cost:.3f})")
            ok += 1
            accumulated_cost += est_cost
            continue

        print(f"  [{i+1}/{len(missing)}] {ch_id} ({title})...", end=" ", flush=True)
        with tempfile.NamedTemporaryFile(suffix=".mp3", delete=False) as tmp:
            mp3_path = tmp.name
        try:
            if not generate_openai_tts(text, api_key, mp3_path, args.voice, model, instructions):
                print("TTS fail")
                fail += 1
                continue
            dur = get_duration_sec(mp3_path)
            rec = upload_audio(base_url, token, ch_id, mp3_path, dur)
            cost = (dur / 60) * EST_COST_PER_MIN
            accumulated_cost += cost
            print(f"ok {rec.get('id')} ({dur:.0f}s, ~${cost:.3f}, total ${accumulated_cost:.2f})")
            ok += 1
        except Exception as e:
            print(f"err: {e}")
            fail += 1
        finally:
            Path(mp3_path).unlink(missing_ok=True)
        time.sleep(0.5)

    print(f"\nDone. ok={ok} fail={fail}")


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
