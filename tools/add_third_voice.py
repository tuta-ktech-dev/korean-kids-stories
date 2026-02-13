#!/usr/bin/env python3
"""
Thêm giọng thứ 3 (coral) với narrator "코럴" cho các chapter đã có 남자+여자.
Chạy đến khi hết ngân sách.
Usage: OPENAI_API_KEY=sk-xxx python add_third_voice.py --max-budget 2.85
"""
import argparse
import json
import os
import re
import subprocess
import sys
import tempfile
import time
from pathlib import Path
from urllib.request import Request, urlopen
from urllib.error import HTTPError

sys.path.insert(0, str(Path(__file__).resolve().parent))
from pb_config import PB_BASE_URL, PB_EMAIL, PB_PASSWORD, require_pb_config

VOICE = "fable"
NARRATOR = "페이블"
STORY_INSTRUCTIONS = "Speak in a warm, gentle storytelling voice for children. Friendly and engaging, not formal."
EST_COST_PER_MIN = 0.015


def auth(base_url: str, email: str, password: str) -> str:
    req = Request(
        f"{base_url}/api/collections/_superusers/auth-with-password",
        data=json.dumps({"identity": email, "password": password}).encode(),
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    with urlopen(req, timeout=30) as r:
        return json.loads(r.read())["token"]


def fetch_all(base_url: str, token: str, collection: str) -> list:
    records = []
    page = 1
    while True:
        req = Request(
            f"{base_url}/api/collections/{collection}/records?page={page}&perPage=200",
            headers={"Authorization": f"Bearer {token}"},
        )
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


def gen_tts(api_key: str, text: str, out_path: Path) -> bool:
    payload = {
        "model": "gpt-4o-mini-tts",
        "input": text[:4096],
        "voice": VOICE,
        "instructions": STORY_INSTRUCTIONS,
        "response_format": "mp3",
    }
    req = Request(
        "https://api.openai.com/v1/audio/speech",
        data=json.dumps(payload).encode(),
        headers={"Authorization": f"Bearer {api_key}", "Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urlopen(req, timeout=300) as r:
            with open(out_path, "wb") as f:
                f.write(r.read())
        return True
    except HTTPError as e:
        print(f" Error {e.code}", file=sys.stderr)
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


def upload(base_url: str, token: str, ch_id: str, mp3_path: Path, dur: float) -> bool:
    result = subprocess.run(
        ["curl", "-s", "-X", "POST",
         f"{base_url}/api/collections/chapter_audios/records",
         "-H", f"Authorization: Bearer {token}",
         "-F", f"chapter={ch_id}",
         "-F", f"narrator={NARRATOR}",
         "-F", f"audio_file=@{mp3_path}",
         "-F", f"audio_duration={dur}"],
        capture_output=True, text=True, timeout=120,
    )
    return result.returncode == 0


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--max-budget", type=float, default=2.85, help="USD to spend")
    args = parser.parse_args()

    api_key = os.environ.get("OPENAI_API_KEY")
    if not api_key:
        print("Error: OPENAI_API_KEY", file=sys.stderr)
        sys.exit(1)

    require_pb_config()
    base_url = (PB_BASE_URL or "").rstrip("/")

    print("Auth...")
    token = auth(base_url, PB_EMAIL, PB_PASSWORD)

    print("Fetch chapter_audios...")
    audios = fetch_all(base_url, token, "chapter_audios")
    ch_has_koral = set()
    for r in audios:
        if (r.get("narrator") or "").strip() == NARRATOR:
            ch_has_koral.add(r["chapter"])

    print("Fetch chapters (có cả 남자+여자)...")
    chapters = fetch_all(base_url, token, "chapters")
    ch_to_data = {c["id"]: c for c in chapters}
    ch_to_narrators = {}
    for r in audios:
        cid = r["chapter"]
        if cid not in ch_to_narrators:
            ch_to_narrators[cid] = set()
        ch_to_narrators[cid].add((r.get("narrator") or "").strip())

    def has_both(cid):
        n = ch_to_narrators.get(cid, set())
        has_n = any(x in ("남자", "male") or "남자" in x for x in n if x)
        has_y = any(x in ("여자", "female", "새 목소리") or "여자" in x for x in n if x)
        return has_n and has_y

    to_add = [cid for cid in ch_to_data
              if has_both(cid) and cid not in ch_has_koral]
    print(f"Chapters cần thêm {NARRATOR}: {len(to_add)}")
    if not to_add:
        print("Đã đủ.")
        return

    ok = 0
    cost = 0.0
    for i, ch_id in enumerate(to_add):
        if cost >= args.max_budget:
            print(f"\n>> Hết ngân sách ${args.max_budget:.2f}")
            break
        ch = ch_to_data.get(ch_id)
        if not ch:
            continue
        text = strip_content(ch.get("content", ""))[:3500]
        if not text or len(text) < 10:
            continue
        title = (ch.get("title") or "?")[:30]
        est = (len(text) / 15 / 60) * EST_COST_PER_MIN
        if cost + est > args.max_budget:
            print(f"\n>> Chương tiếp ~${est:.3f} vượt budget")
            break

        print(f"  [{i+1}/{len(to_add)}] {ch_id} ({title})...", end=" ", flush=True)
        with tempfile.NamedTemporaryFile(suffix=".mp3", delete=False) as tmp:
            p = Path(tmp.name)
        try:
            if not gen_tts(api_key, text, p):
                continue
            dur = get_duration(p)
            if not upload(base_url, token, ch_id, p, dur):
                print("upload fail")
                continue
            c = (dur / 60) * EST_COST_PER_MIN
            cost += c
            ok += 1
            print(f"ok ({dur:.0f}s, ~${c:.3f}, total ${cost:.2f})")
        finally:
            p.unlink(missing_ok=True)
        time.sleep(0.5)

    print(f"\nDone. Added {ok} chapters, ~${cost:.2f}")


if __name__ == "__main__":
    main()
