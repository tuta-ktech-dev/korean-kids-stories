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

# 2. Tải model KSS (~950MB) vào tools/models/ (gitignored)
mkdir -p tools/models
curl -L -o tools/models/best_model.pth https://huggingface.co/neurlang/coqui-vits-kss-korean/resolve/main/best_model.pth
curl -L -o tools/models/config.json https://huggingface.co/neurlang/coqui-vits-kss-korean/resolve/main/config.json

# 3. Chạy TTS tiếng Hàn (không cần speaker reference)
python tts_cli.py '안녕하세요 세상' -M tools/models/best_model.pth -C tools/models/config.json -o ko_kss.wav
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

Credentials lấy từ `.env` (PB_BASE_URL, PB_EMAIL, PB_PASSWORD). Xem `tools/.env.example`.

## Kiểm tra và thêm giọng (2 giọng mặc định: 남자 + 여자)

Mỗi chapter cần có 2 giọng đọc (남자 nam, 여자 nữ). Script `check_voices.py` kiểm tra:

```bash
python check_voices.py
```

Thêm giọng thiếu:

```bash
# Thêm 여자 (KSS local - cần TTS model)
python add_yeoja_voice.py --limit 97

# Thêm 남자 (OpenAI TTS - cần OPENAI_API_KEY)
OPENAI_API_KEY=sk-xxx python add_namja_voice.py --limit 20
```
