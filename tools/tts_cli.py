#!/usr/bin/env python3
"""
Simple TTS CLI - Convert text to speech.
Uses Coqui TTS. Supports English (default) and Korean (with KSS model).
"""
import argparse
import os
import sys
from pathlib import Path

# Fix PyTorch/Coqui TTS hang on macOS - force spawn for multiprocessing
if __name__ == "__main__":
    import multiprocessing
    try:
        multiprocessing.set_start_method("spawn", force=True)
    except RuntimeError:
        pass


def main():
    parser = argparse.ArgumentParser(description="Text-to-Speech: convert text to WAV")
    parser.add_argument("text", nargs="?", help="Text to speak (or use -i for file)")
    parser.add_argument("-o", "--output", default="output.wav", help="Output WAV path")
    parser.add_argument("-i", "--input", help="Input text file (one paragraph per line)")
    parser.add_argument(
        "-m",
        "--model",
        default="tts_models/en/ljspeech/tacotron2-DDC",
        help="TTS model name (default: English LJSpeech)",
    )
    parser.add_argument(
        "-M",
        "--model_path",
        help="Local model path (use with -C for KSS Korean etc.)",
    )
    parser.add_argument(
        "-C",
        "--config_path",
        help="Local config path (required with -M)",
    )
    parser.add_argument("-l", "--language", default="en", help="Language code for XTTS (en, ko, ja, ...)")
    parser.add_argument(
        "-s",
        "--speaker_wav",
        help="Reference audio for XTTS voice cloning (required for XTTS, >3 sec)",
    )
    args = parser.parse_args()

    text = args.text
    if args.input:
        path = Path(args.input)
        if not path.exists():
            print(f"Error: file not found: {path}", file=sys.stderr)
            sys.exit(1)
        text = path.read_text(encoding="utf-8").strip()
    elif not text:
        parser.print_help()
        print("\nExamples:")
        print('  python tts_cli.py "Hello world" -o hello.wav')
        print("  python tts_cli.py -i story.txt -o story.wav")
        sys.exit(1)

    try:
        from TTS.api import TTS
    except ImportError:
        print("Error: Coqui TTS not installed. Run: pip install coqui-tts[codec]", file=sys.stderr)
        sys.exit(1)

    # Reduce "Character X not found in vocabulary" spam (KSS + pygoruut outputs IPA diacritics)
    import logging
    logging.getLogger("TTS.tts.utils.text.tokenizer").setLevel(logging.ERROR)

    if args.model_path:
        if not args.config_path:
            print("Error: -M/--model_path requires -C/--config_path", file=sys.stderr)
            sys.exit(1)
        # Patch KSS config: lower inference_noise_scale for cleaner voice (less hoarse)
        import json
        cfg_path = Path(args.config_path)
        with open(cfg_path, encoding="utf-8") as f:
            cfg = json.load(f)
        ma = cfg.get("model_args") or cfg.get("model") or {}
        if isinstance(ma, dict):
            ma["inference_noise_scale"] = ma.get("inference_noise_scale", 0.667) * 0.6
            ma["inference_noise_scale_dp"] = ma.get("inference_noise_scale_dp", 1.0) * 0.8
        import tempfile
        with tempfile.NamedTemporaryFile(mode="w", suffix=".json", delete=False, encoding="utf-8") as tmp:
            json.dump(cfg, tmp, ensure_ascii=False, indent=2)
            config_path = tmp.name
        try:
            print(f"Loading model: {args.model_path}")
            tts = TTS(model_path=args.model_path, config_path=config_path, progress_bar=True)
        finally:
            Path(config_path).unlink(missing_ok=True)
    else:
        print(f"Loading model: {args.model}")
        tts = TTS(model_name=args.model, progress_bar=True)

    out_path = Path(args.output)
    out_path.parent.mkdir(parents=True, exist_ok=True)

    # XTTS models need speaker_wav for voice cloning
    if "xtts" in args.model.lower():
        if not args.speaker_wav:
            print("Error: XTTS requires -s/--speaker_wav (reference audio, >3 sec)", file=sys.stderr)
            print("Example: use hello.wav from English TTS first:", file=sys.stderr)
            print('  python tts_cli.py "Hello" -o hello.wav', file=sys.stderr)
            print("  COQUI_TOS_AGREED=1 python tts_cli.py '안녕' -m ... -l ko -s hello.wav -o ko.wav", file=sys.stderr)
            sys.exit(1)
        tts.tts_to_file(text=text, file_path=str(out_path), language=args.language, speaker_wav=args.speaker_wav)
    else:
        tts.tts_to_file(text=text, file_path=str(out_path))

    print(f"Done: {out_path}")


if __name__ == "__main__":
    main()
    os._exit(0)  # Force exit - PyTorch/TTS threads often block normal shutdown on macOS
