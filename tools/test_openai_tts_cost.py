#!/usr/bin/env python3
"""
Test audio bằng OpenAI TTS, in ra chi phí.
Hỗ trợ nhiều giọng + instructions (gpt-4o-mini-tts) để kể chuyện ấm áp hơn.
Usage:
  OPENAI_API_KEY=sk-xxx python test_openai_tts_cost.py
  python test_openai_tts_cost.py --voice coral --instructions "Warm storytelling tone for children"
  python test_openai_tts_cost.py --list-voices  # xem danh sách giọng
"""
import argparse
import json
import os
import subprocess
import sys
from pathlib import Path

# Pricing (platform.openai.com/docs/pricing)
# tts-1-hd: $30/1M chars; gpt-4o-mini-tts: ~$0.60/1M input + $12/1M audio tokens (~$0.015/min)
TTS_HD_PRICE_PER_1M_CHARS = 30.0

# 11 giọng (gpt-4o-mini-tts) + 6 giọng (tts-1-hd)
VOICES = ["alloy", "ash", "ballad", "coral", "echo", "fable", "nova", "onyx", "sage", "shimmer"]

SAMPLE_KO = """옛날 옛적에 착한 형 흥부와 욕심 많은 동생 놀부가 살았습니다.
흥부는 가난했지만 마음이 넓었고, 놀부는 부자였지만 인색했습니다.
어느 날 제비가 다리가 부러져 흥부가 구해 주었지요."""

# Gợi ý cho kể chuyện trẻ em (ít nghiêm)
STORY_INSTRUCTIONS = "Speak in a warm, gentle storytelling voice for children. Friendly and engaging, not formal."


def gen_tts(api_key: str, text: str, out_path: Path, voice: str = "coral",
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

    import urllib.request
    import urllib.error
    req = urllib.request.Request(
        url,
        data=json.dumps(payload).encode(),
        headers={"Authorization": f"Bearer {api_key}", "Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=120) as r:
            with open(out_path, "wb") as f:
                f.write(r.read())
        return True
    except urllib.error.HTTPError as e:
        err = e.fp.read().decode() if e.fp else str(e)
        print(f"Error {e.code}: {err}", file=sys.stderr)
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
    parser = argparse.ArgumentParser()
    parser.add_argument("--voice", default="coral", help="alloy, ash, ballad, coral, echo, fable, nova, onyx, sage, shimmer")
    parser.add_argument("--model", default="gpt-4o-mini-tts", help="gpt-4o-mini-tts (có instructions) hoặc tts-1-hd")
    parser.add_argument("--instructions", default="", help="Chỉ gpt-4o-mini-tts. VD: Warm storytelling for kids")
    parser.add_argument("--list-voices", action="store_true")
    parser.add_argument("--story", action="store_true", help="Dùng tone kể chuyện (instructions có sẵn)")
    args = parser.parse_args()

    if args.list_voices:
        print("Giọng OpenAI TTS: alloy, ash, ballad, coral, echo, fable, nova, onyx, sage, shimmer")
        print("Gợi ý kể chuyện: coral, nova, fable, ballad (ấm, ít nghiêm)")
        return

    api_key = os.environ.get("OPENAI_API_KEY")
    if not api_key:
        print("Error: set OPENAI_API_KEY", file=sys.stderr)
        sys.exit(1)

    text = SAMPLE_KO.strip()
    chars = len(text)
    instructions = args.instructions or (STORY_INSTRUCTIONS if args.story else None)

    cost = (chars / 1_000_000) * TTS_HD_PRICE_PER_1M_CHARS
    if args.model == "gpt-4o-mini-tts":
        cost = 0.015 / 60 * 15  # ~$0.015/phút, ước 15s
    print(f"Text: {chars} chars | Voice: {args.voice} | Model: {args.model}")
    if instructions:
        print(f"Instructions: {instructions[:60]}...")
    print(f"Est. cost: ~${cost:.4f}")
    print()

    out_path = Path(__file__).parent / f"test_openai_tts_{args.voice}.mp3"
    if not gen_tts(api_key, text, out_path, args.voice, args.model, instructions):
        sys.exit(1)

    dur = get_duration(out_path)
    print(f"Saved: {out_path}")
    print(f"Duration: {dur:.1f}s")
    print(f"\n>> Nghe: open {out_path}")


if __name__ == "__main__":
    main()
