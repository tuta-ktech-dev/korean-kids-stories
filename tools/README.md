# Tools

Các công cụ Python phụ trợ cho Korean Kids Stories.

## TTS GUI

```bash
python tts_gui.py
```

Giao diện ttkbootstrap: nhập text, chọn model (KSS Korean / English / XTTS), chỉ định output, bấm "Tạo audio".

## TTS CLI (Text-to-Speech)

Chuyển text thành file audio WAV.

### Cài đặt

```bash
cd tools
pip install -r requirements.txt
```

### Sử dụng

```bash
# Tiếng Anh (mặc định)
python tts_cli.py "Hello, welcome to Korean Kids Tales!" -o hello.wav

# Đọc từ file
python tts_cli.py -i story.txt -o story.wav

# Tiếng Hàn (XTTS - cần -s reference audio)
COQUI_TOS_AGREED=1 python tts_cli.py '안녕' -m tts_models/multilingual/multi-dataset/xtts_v2 -l ko -s hello.wav -o ko.wav

# Tiếng Hàn (VITS KSS - dùng -M/-C với model local, không cần reference)
python tts_cli.py '안녕하세요 세상' -M /tmp/best_model.pth -C /tmp/config.json -o ko_kss.wav
```

### Models gợi ý

| Model | Ngôn ngữ | Chất lượng |
|-------|----------|------------|
| `tts_models/en/ljspeech/tacotron2-DDC` | EN | Tốt |
| `tts_models/multilingual/multi-dataset/xtts_v2` | 17 ngôn ngữ (ko, en, ja...) | Cần reference audio |
| `tts_models/ja/kokoro/tacotron2-DDC` | JA | Tốt |

**Lưu ý:** XTTS v2 tiếng Hàn có vấn đề phát âm. Cho Korean chất lượng tốt hơn, dùng [neurlang/coqui-vits-kss-korean](https://huggingface.co/neurlang/coqui-vits-kss-korean):

```bash
# 1. Cài coqui-tts-pygoruut (thay coqui-tts, có pygoruut cho Korean)
pip install coqui-tts-pygoruut

# 2. Tải model KSS (~950MB)
curl -L -o /tmp/best_model.pth https://huggingface.co/neurlang/coqui-vits-kss-korean/resolve/main/best_model.pth
curl -L -o /tmp/config.json https://huggingface.co/neurlang/coqui-vits-kss-korean/resolve/main/config.json

# 3. Chạy TTS tiếng Hàn (không cần speaker reference)
python tts_cli.py '안녕하세요 세상' -M /tmp/best_model.pth -C /tmp/config.json -o ko_kss.wav
```

**Giọng khàn:** Code đã giảm `inference_noise_scale` (~40%) để âm rõ hơn. Nếu vẫn khàn, thử `pip install pygoruut==0.6.3` (khớp phiên bản model train).

## Story → Audio → Upload

Tự động lấy truyện từ PocketBase, tạo TTS, upload lên `chapter_audios`:

```bash
# Cài coqui-tts-pygoruut + tải KSS model trước (xem trên)

# Chạy (mặc định: story đầu tiên)
python story_to_audio.py

# Chỉ định story
python story_to_audio.py --story-id 3ghmc2ea1ivakj4

# Dry run (chỉ fetch, không TTS/upload)
python story_to_audio.py --story-id 3ghmc2ea1ivakj4 --dry-run
```

Mặc định kết nối `http://trananhtu.vn:8090` với email/password trong script.
