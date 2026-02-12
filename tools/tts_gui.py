#!/usr/bin/env python3
"""
TTS GUI - Text-to-Speech with ttkbootstrap interface.
"""
import logging
import os
import threading
from pathlib import Path

import ttkbootstrap as tb
from ttkbootstrap.constants import *
from ttkbootstrap.dialogs import Messagebox
from ttkbootstrap.widgets.scrolled import ScrolledText


def _play_wav(path: str) -> None:
    """Play WAV file (non-blocking in thread)."""
    try:
        import sounddevice as sd
        import soundfile as sf
        data, sr = sf.read(path)
        sd.play(data, sr)
        sd.wait()
    except Exception:
        pass


def run_tts(
    text: str,
    output_path: str,
    model_name: str | None = None,
    model_path: str | None = None,
    config_path: str | None = None,
    language: str = "en",
    speaker_wav: str | None = None,
    on_progress: callable = None,
) -> tuple[bool, str]:
    """Run TTS and return (success, file_path or error_message)."""
    if not text.strip():
        return False, "Nhập text để tổng hợp"
    out = Path(output_path)
    if not out.suffix:
        out = out.with_suffix(".wav")
    out.parent.mkdir(parents=True, exist_ok=True)

    try:
        from TTS.api import TTS
    except ImportError:
        return False, "Chưa cài Coqui TTS. Chạy: pip install coqui-tts[codec]"

    logging.getLogger("TTS.tts.utils.text.tokenizer").setLevel(logging.ERROR)

    if model_path:
        if not config_path:
            return False, "Chọn cả config khi dùng model local"
        # Patch config: lower inference_noise_scale for cleaner voice (less hoarse)
        import json
        with open(config_path, encoding="utf-8") as f:
            cfg = json.load(f)
        ma = cfg.get("model_args") or cfg.get("model") or {}
        if isinstance(ma, dict):
            ma["inference_noise_scale"] = ma.get("inference_noise_scale", 0.667) * 0.6
            ma["inference_noise_scale_dp"] = ma.get("inference_noise_scale_dp", 1.0) * 0.8
        import tempfile
        with tempfile.NamedTemporaryFile(mode="w", suffix=".json", delete=False, encoding="utf-8") as tmp:
            json.dump(cfg, tmp, ensure_ascii=False, indent=2)
            _cfg_path = tmp.name
        try:
            if on_progress:
                on_progress("Đang load model...")
            tts = TTS(model_path=model_path, config_path=_cfg_path, progress_bar=False)
        finally:
            Path(_cfg_path).unlink(missing_ok=True)
    else:
        model_name = model_name or "tts_models/en/ljspeech/tacotron2-DDC"
        if "xtts" in model_name.lower() and not speaker_wav:
            return False, "XTTS cần file audio mẫu (speaker wav)"
        if on_progress:
            on_progress("Đang load model...")
        tts = TTS(model_name=model_name, progress_bar=False)

    if on_progress:
        on_progress("Đang tạo audio...")
    try:
        if "xtts" in (model_name or "").lower():
            tts.tts_to_file(
                text=text.strip(),
                file_path=str(out),
                language=language,
                speaker_wav=speaker_wav,
            )
        else:
            tts.tts_to_file(text=text.strip(), file_path=str(out))
    except Exception as e:
        return False, str(e)
    return True, str(out)


class TTSApp:
    def __init__(self):
        self.root = tb.Window(
            title="TTS - Korean Kids Stories",
            themename="cosmo",
            size=(600, 560),
            resizable=(True, True),
        )
        self.root.place_window_center()
        self.setup_ui()
        self._tts_thread = None
        self._current_audio_path: str | None = None

    def setup_ui(self):
        main = tb.Frame(self.root, padding=10)
        main.pack(fill=BOTH, expand=YES)

        # Text input
        tb.Label(main, text="Text:", bootstyle="primary").pack(anchor=W, pady=(0, 2))
        self.text_in = ScrolledText(main, height=6, autohide=True)
        self.text_in.pack(fill=X, pady=(0, 8))
        self.text_in.insert(END, "안녕하세요 세상")

        # Model
        f_model = tb.Labelframe(main, text="Model", padding=8)
        f_model.pack(fill=X, pady=4)

        self.model_var = tb.StringVar(value="kss")
        tb.Radiobutton(
            f_model,
            text="KSS Korean (local)",
            variable=self.model_var,
            value="kss",
            bootstyle="info",
            command=self._on_model_change,
        ).pack(anchor=W)
        tb.Radiobutton(
            f_model,
            text="English (LJSpeech)",
            variable=self.model_var,
            value="en",
            bootstyle="info",
            command=self._on_model_change,
        ).pack(anchor=W)
        tb.Radiobutton(
            f_model,
            text="XTTS (multi-language)",
            variable=self.model_var,
            value="xtts",
            bootstyle="info",
            command=self._on_model_change,
        ).pack(anchor=W)

        # KSS paths
        self.f_kss = tb.Frame(f_model)
        self.f_kss.pack(fill=X, pady=2)
        tb.Label(self.f_kss, text="Model:", width=8).grid(row=0, column=0, sticky=W, pady=2)
        self.ent_model = tb.Entry(self.f_kss, width=50)
        self.ent_model.grid(row=0, column=1, sticky=EW, padx=4, pady=2)
        self.ent_model.insert(0, "/tmp/best_model.pth")
        tb.Label(self.f_kss, text="Config:", width=8).grid(row=1, column=0, sticky=W, pady=2)
        self.ent_config = tb.Entry(self.f_kss, width=50)
        self.ent_config.grid(row=1, column=1, sticky=EW, padx=4, pady=2)
        self.ent_config.insert(0, "/tmp/config.json")
        self.f_kss.columnconfigure(1, weight=1)

        # XTTS options
        self.f_xtts = tb.Frame(f_model)
        self.f_xtts.pack(fill=X, pady=2)
        tb.Label(self.f_xtts, text="Lang:", width=8).grid(row=0, column=0, sticky=W, pady=2)
        self.ent_lang = tb.Entry(self.f_xtts, width=8)
        self.ent_lang.grid(row=0, column=1, sticky=W, padx=4, pady=2)
        self.ent_lang.insert(0, "ko")
        tb.Label(self.f_xtts, text="Speaker WAV:", width=12).grid(row=1, column=0, sticky=W, pady=2)
        self.ent_speaker = tb.Entry(self.f_xtts, width=40)
        self.ent_speaker.grid(row=1, column=1, sticky=EW, padx=4, pady=2)
        self.ent_speaker.insert(0, "hello.wav")
        self.f_xtts.columnconfigure(1, weight=1)
        self.f_xtts.pack_forget()

        # Output
        f_out = tb.Frame(main)
        f_out.pack(fill=X, pady=4)
        tb.Label(f_out, text="Output:", width=8).pack(side=LEFT, padx=(0, 4))
        self.ent_out = tb.Entry(f_out)
        self.ent_out.pack(side=LEFT, fill=X, expand=YES, padx=4)
        self.ent_out.insert(0, str(Path.cwd() / "output.wav"))

        # Progress
        self.lbl_status = tb.Label(main, text="Sẵn sàng", bootstyle="secondary")
        self.lbl_status.pack(anchor=W, pady=4)

        # Buttons
        btn_frame = tb.Frame(main)
        btn_frame.pack(fill=X, pady=8)
        self.btn_go = tb.Button(
            btn_frame,
            text="Tạo audio",
            command=self._on_generate,
            bootstyle="success",
        )
        self.btn_go.pack(side=LEFT, padx=(0, 8))
        self.btn_export = tb.Button(
            btn_frame,
            text="Xuất audio",
            command=self._on_export,
            bootstyle="info",
            state=DISABLED,
        )
        self.btn_export.pack(side=LEFT, padx=(0, 8))

    def _on_model_change(self):
        if self.model_var.get() == "kss":
            self.f_kss.pack(fill=X, pady=2)
            self.f_xtts.pack_forget()
        elif self.model_var.get() == "xtts":
            self.f_kss.pack_forget()
            self.f_xtts.pack(fill=X, pady=2)
        else:
            self.f_kss.pack_forget()
            self.f_xtts.pack_forget()

    def _on_generate(self):
        if self._tts_thread and self._tts_thread.is_alive():
            self.lbl_status.configure(text="Đang xử lý...")
            return
        self.btn_go.configure(state=DISABLED)
        self.btn_export.configure(state=DISABLED)
        self._current_audio_path = None
        self.lbl_status.configure(text="Đang xử lý...")

        def work():
            model_name = None
            model_path = None
            config_path = None
            language = "en"
            speaker_wav = None

            if self.model_var.get() == "kss":
                model_path = self.ent_model.get().strip()
                config_path = self.ent_config.get().strip()
            elif self.model_var.get() == "xtts":
                model_name = "tts_models/multilingual/multi-dataset/xtts_v2"
                language = self.ent_lang.get().strip() or "ko"
                speaker_wav = self.ent_speaker.get().strip()
            else:
                model_name = "tts_models/en/ljspeech/tacotron2-DDC"

            os.environ["COQUI_TOS_AGREED"] = "1"
            text = self.text_in.get(1.0, END)
            import tempfile
            tmp_out = tempfile.NamedTemporaryFile(suffix=".wav", delete=False).name

            def prog(msg):
                self.root.after(0, lambda: self.lbl_status.configure(text=msg))

            ok, msg = run_tts(
                text=text,
                output_path=tmp_out,
                model_name=model_name,
                model_path=model_path or None,
                config_path=config_path or None,
                language=language,
                speaker_wav=speaker_wav or None,
                on_progress=prog,
            )

            def done():
                self.btn_go.configure(state=NORMAL)
                if ok:
                    self._current_audio_path = msg
                    self.lbl_status.configure(text="Đang phát...")
                    self.btn_export.configure(state=NORMAL)
                    threading.Thread(target=_play_wav, args=(msg,), daemon=True).start()
                    self.root.after(100, lambda: self.lbl_status.configure(text="Đã tạo. Bấm Xuất audio để lưu file."))
                else:
                    self._current_audio_path = None
                    self.btn_export.configure(state=DISABLED)
                    self.lbl_status.configure(text=msg)
                    Messagebox.show_error(msg, title="Lỗi")

            self.root.after(0, done)

        self._tts_thread = threading.Thread(target=work, daemon=True)
        self._tts_thread.start()

    def _on_export(self):
        if not self._current_audio_path or not Path(self._current_audio_path).exists():
            Messagebox.show_warning("Chưa có audio để xuất. Hãy tạo audio trước.", title="Xuất audio")
            return
        out = Path(self.ent_out.get().strip())
        if not out.suffix:
            out = out.with_suffix(".wav")
        out.parent.mkdir(parents=True, exist_ok=True)
        try:
            import shutil
            shutil.copy2(self._current_audio_path, out)
            self.lbl_status.configure(text=f"Đã lưu: {out}")
            Messagebox.ok(f"Đã lưu: {out}", title="Xuất audio")
        except Exception as e:
            Messagebox.show_error(str(e), title="Lỗi xuất")

    def run(self):
        self.root.mainloop()


if __name__ == "__main__":
    import multiprocessing
    try:
        multiprocessing.set_start_method("spawn", force=True)
    except RuntimeError:
        pass
    TTSApp().run()
