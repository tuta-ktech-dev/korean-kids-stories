#!/usr/bin/env python3
"""
Thêm giọng 여자 (female) cho các chapter chỉ có 남자.
Hỗ trợ KSS + XTTS (local). Tự chọn: KSS ưu tiên, không có thì XTTS.
Usage:
  python add_yeoja_voice.py --list-models   # xem model có sẵn
  python add_yeoja_voice.py --limit 1       # auto: KSS hoặc XTTS
  python add_yeoja_voice.py --xtts --limit 1   # bắt buộc XTTS
  python add_yeoja_voice.py --model ... --config ...   # bắt buộc KSS
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

# Paths (tools/models/ gitignored)
_SCRIPT_DIR = Path(__file__).resolve().parent
MODELS_DIR = _SCRIPT_DIR / "models"
KSS_MODEL_DEFAULT = str(MODELS_DIR / "best_model.pth")
KSS_CONFIG_DEFAULT = str(MODELS_DIR / "config.json")
# XTTS: mặc định dùng WAV từ KSS (ko_kss.wav) hoặc tools/models/speaker_female.wav
XTTS_SPEAKER_DEFAULT = str(_SCRIPT_DIR / "ko_kss.wav")  # fallback
XTTS_SPEAKER_MODELS = str(MODELS_DIR / "speaker_female.wav")  # ưu tiên


def list_available_models():
    """Kiểm tra và in ra các model local có thể dùng."""
    lines = []
    lines.append("=== Kiểm tra model TTS local ===\n")

    # 1. KSS (VITS Korean - giọng nữ)
    kss_model = Path(KSS_MODEL_DEFAULT)
    kss_config = Path(KSS_CONFIG_DEFAULT)
    kss_ok = kss_model.exists() and kss_config.exists()
    lines.append(f"1. KSS (VITS Korean - 여자):")
    lines.append(f"   Model:  {kss_model} {'✓' if kss_model.exists() else '✗ chưa có'}")
    lines.append(f"   Config: {kss_config} {'✓' if kss_config.exists() else '✗ chưa có'}")
    if not kss_ok:
        lines.append("   Tải: mkdir -p tools/models && curl -L -o tools/models/best_model.pth ...")
        lines.append("        curl -L -o tools/models/config.json https://huggingface.co/neurlang/coqui-vits-kss-korean/resolve/main/config.json")
    lines.append("")

    # 2. XTTS v2 (multilingual, cần speaker_wav)
    xtts_speaker = Path(XTTS_SPEAKER_MODELS)
    xtts_fallback = Path(XTTS_SPEAKER_DEFAULT)
    xtts_ok = xtts_speaker.exists() or xtts_fallback.exists()
    try:
        from TTS.api import TTS
        tts = TTS()
        models = tts.list_models()
        xtts = [m for m in models if "xtts" in m.lower()]
        lines.append(f"2. XTTS (multilingual, Korean):")
        lines.append(f"   Speaker: {xtts_speaker} {'✓' if xtts_speaker.exists() else '✗'}")
        lines.append(f"   Fallback: {xtts_fallback} {'✓' if xtts_fallback.exists() else '✗'}")
        lines.append(f"   Built-in: {xtts[:2]} ...")
        if not xtts_ok:
            lines.append("   Tạo: chạy KSS 1 câu → tools/ko_kss.wav, hoặc copy WAV >3s vào tools/models/speaker_female.wav")
    except ImportError:
        lines.append("2. XTTS: Chưa cài Coqui TTS (pip install coqui-tts[codec])")
    except Exception as e:
        lines.append(f"2. XTTS: {e}")
    lines.append("")

    # 3. Coqui built-in
    lines.append("3. Built-in khác: EN (LJSpeech), JA (Kokoro)... - không hỗ trợ Korean tốt")
    lines.append("")
    lines.append(">> Chạy (tự chọn KSS hoặc XTTS):")
    if kss_ok:
        lines.append("   python add_yeoja_voice.py --limit 1   # dùng KSS")
    if xtts_ok:
        lines.append("   python add_yeoja_voice.py --xtts --limit 1   # dùng XTTS")
    if not kss_ok and not xtts_ok:
        lines.append("   Tải KSS hoặc chuẩn bị speaker WAV cho XTTS")

    print("\n".join(lines), flush=True)


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
    auth_h = {"Authorization": f"Bearer {token}"}
    while True:
        url = f"{base_url}/api/collections/{collection}/records?page={page}&perPage=200"
        if filter_str:
            url += f"&filter={filter_str}"
        req = Request(url, headers=auth_h)
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


def generate_tts_kss(text: str, model_path: str, config_path: str, out_path: str) -> bool:
    """KSS (VITS Korean) - giọng nữ."""
    import logging as _log
    _log.getLogger("TTS.tts.utils.text.tokenizer").setLevel(_log.ERROR)
    from TTS.api import TTS as TTSApi
    with open(config_path, encoding="utf-8") as f:
        cfg = json.load(f)
    ma = cfg.get("model_args") or cfg.get("model") or {}
    if isinstance(ma, dict):
        ma["inference_noise_scale"] = ma.get("inference_noise_scale", 0.667) * 0.6
        ma["inference_noise_scale_dp"] = ma.get("inference_noise_scale_dp", 1.0) * 0.8
    with tempfile.NamedTemporaryFile(mode="w", suffix=".json", delete=False, encoding="utf-8") as tmp:
        json.dump(cfg, tmp, ensure_ascii=False, indent=2)
        _cfg = tmp.name
    try:
        tts = TTSApi(model_path=model_path, config_path=_cfg, progress_bar=False)
        tts.tts_to_file(text=text.strip(), file_path=out_path)
        return True
    finally:
        Path(_cfg).unlink(missing_ok=True)


def generate_tts_xtts(text: str, speaker_wav: str, out_path: str) -> bool:
    """XTTS v2 - dùng speaker_wav làm reference giọng."""
    from TTS.api import TTS
    tts = TTS(model_name="tts_models/multilingual/multi-dataset/xtts_v2", progress_bar=False)
    tts.tts_to_file(text=text.strip(), file_path=out_path, language="ko", speaker_wav=speaker_wav)
    return True


def get_duration_sec(audio_path: str) -> float:
    """Support wav and mp3."""
    try:
        out = subprocess.run(
            ["ffprobe", "-v", "error", "-show_entries", "format=duration",
             "-of", "default=noprint_wrappers=1:nokey=1", audio_path],
            capture_output=True, text=True, timeout=5,
        )
        if out.returncode == 0 and out.stdout.strip():
            return float(out.stdout.strip())
    except (FileNotFoundError, subprocess.TimeoutExpired):
        pass
    return 0.0


def wav_to_mp3_if_needed(wav_path: str) -> str:
    """PocketBase accepts mp3. If wav, convert. Return path to use."""
    if wav_path.endswith(".mp3"):
        return wav_path
    # Try ffmpeg to convert wav -> mp3 for smaller upload
    mp3_path = wav_path.replace(".wav", ".mp3")
    try:
        subprocess.run(
            ["ffmpeg", "-y", "-i", wav_path, "-acodec", "libmp3lame", "-q:a", "2", mp3_path],
            capture_output=True, timeout=60,
        )
        if Path(mp3_path).exists():
            return mp3_path
    except (FileNotFoundError, subprocess.TimeoutExpired):
        pass
    return wav_path  # upload wav if no ffmpeg


def upload_audio(base_url: str, token: str, chapter_id: str, audio_path: str, duration: float) -> dict:
    upload_path = wav_to_mp3_if_needed(audio_path)
    args = [
        "curl", "-s", "-X", "POST",
        f"{base_url}/api/collections/chapter_audios/records",
        "-H", f"Authorization: Bearer {token}",
        "-F", f"chapter={chapter_id}",
        "-F", "narrator=여자",
        "-F", f"audio_file=@{upload_path}",
        "-F", f"audio_duration={duration}",
    ]
    result = subprocess.run(args, capture_output=True, text=True, timeout=120)
    if result.returncode != 0:
        raise RuntimeError(result.stderr or result.stdout)
    return json.loads(result.stdout)


def main():
    parser = argparse.ArgumentParser(description="Add 여자 voice to chapters (local TTS only)")
    parser.add_argument("--list-models", action="store_true", help="Check available local models")
    parser.add_argument("--model", help="KSS model path (best_model.pth)")
    parser.add_argument("--config", help="KSS config path (config.json)")
    parser.add_argument("--xtts", action="store_true", help="Use XTTS v2 instead of KSS")
    parser.add_argument("--speaker-wav", help="Reference WAV for XTTS (>3 sec)")
    parser.add_argument("--limit", type=int, default=0, help="Max chapters (0=all)")
    parser.add_argument("--base-url", default=PB_BASE_URL or "")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--max-chars", type=int, default=1500, help="Max chars per chapter (KSS limit)")
    args = parser.parse_args()

    if args.list_models:
        list_available_models()
        return

    # Validate TTS mode
    use_kss = bool(args.model and args.config)
    use_xtts = args.xtts
    if not use_kss and not use_xtts:
        # Auto: KSS trước, rồi XTTS
        model_path = MODELS_DIR / "best_model.pth"
        config_path = MODELS_DIR / "config.json"
        if model_path.exists() and config_path.exists():
            args.model = str(model_path)
            args.config = str(config_path)
            use_kss = True
        else:
            sp1 = Path(XTTS_SPEAKER_MODELS)
            sp2 = Path(XTTS_SPEAKER_DEFAULT)
            speaker = sp1 if sp1.exists() else (sp2 if sp2.exists() else None)
            if speaker:
                args.xtts = True
                args.speaker_wav = str(speaker)
                use_xtts = True
    if not use_kss and not use_xtts:
        print("Chọn 1 trong 2:", file=sys.stderr)
        print("  KSS:  --model tools/models/best_model.pth --config tools/models/config.json", file=sys.stderr)
        print("  XTTS: --xtts --speaker-wav /path/to/female_ko.wav", file=sys.stderr)
        print("\nChạy --list-models để xem model có sẵn", file=sys.stderr)
        sys.exit(1)
    if use_kss:
        if not Path(args.model).exists() or not Path(args.config).exists():
            print(f"KSS model/config không tồn tại", file=sys.stderr)
            sys.exit(1)
    if use_xtts:
        if not args.speaker_wav or not Path(args.speaker_wav).exists():
            print("XTTS cần --speaker-wav (file WAV tồn tại, >3 giây)", file=sys.stderr)
            sys.exit(1)

    require_pb_config()
    base_url = args.base_url or PB_BASE_URL

    os.environ["COQUI_TOS_AGREED"] = "1"

    print("Auth...")
    token = auth(base_url, PB_EMAIL, PB_PASSWORD)

    print("Fetch chapter_audios...")
    audios = fetch_all(base_url, token, "chapter_audios")
    ch_to_narrators = defaultdict(set)
    for r in audios:
        ch_to_narrators[r["chapter"]].add(r.get("narrator") or "")

    missing = [cid for cid, narrators in ch_to_narrators.items() if "여자" not in narrators]
    print(f"Chapters thiếu 여자: {len(missing)}")

    if args.limit:
        missing = missing[: args.limit]
        print(f"Chỉ xử lý {len(missing)} chapter đầu")

    # Prefetch chapters
    chapters_by_id = {}
    for ch_id in missing:
        try:
            req = Request(
                f"{base_url}/api/collections/chapters/records/{ch_id}",
                headers={"Authorization": f"Bearer {token}"},
            )
            with urlopen(req, timeout=30) as r:
                ch = json.loads(r.read())
                chapters_by_id[ch_id] = ch
        except HTTPError as e:
            if e.code != 404:
                raise

    ok = 0
    fail = 0
    for i, ch_id in enumerate(missing):
        ch = chapters_by_id.get(ch_id)
        if not ch:
            continue
        content = strip_content(ch.get("content", ""))
        if not content or len(content) < 10:
            continue
        text = content[: args.max_chars]
        title = (ch.get("title") or "?")[:30]

        if args.dry_run:
            print(f"  [{i+1}] {ch_id} ({title}): would add 여자 ({len(text)} chars)")
            ok += 1
            continue

        print(f"  [{i+1}/{len(missing)}] {ch_id} ({title})...", end=" ", flush=True)
        with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as tmp:
            wav_path = tmp.name
        try:
            if use_kss:
                if not generate_tts_kss(text, args.model, args.config, wav_path):
                    print("TTS fail")
                    fail += 1
                    continue
            else:
                if not generate_tts_xtts(text, args.speaker_wav, wav_path):
                    print("TTS fail")
                    fail += 1
                    continue
            dur = get_duration_sec(wav_path)
            rec = upload_audio(base_url, token, ch_id, wav_path, dur)
            # Cleanup converted mp3 if created
            mp3_path = wav_path.replace(".wav", ".mp3")
            Path(mp3_path).unlink(missing_ok=True)
            print(f"ok {rec.get('id')} ({dur:.0f}s)")
            ok += 1
        except Exception as e:
            print(f"err: {e}")
            fail += 1
        finally:
            Path(wav_path).unlink(missing_ok=True)
        time.sleep(0.3)

    print(f"\nDone. ok={ok} fail={fail}")


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
