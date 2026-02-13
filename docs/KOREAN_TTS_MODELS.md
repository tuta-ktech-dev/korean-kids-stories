# Korean TTS Models – Tổng hợp từ papers, sách vở, benchmark

Tổng hợp từ các bài báo, benchmark và tài liệu (2023–2025).

---

## 1. Mô hình open-source cho tiếng Hàn

### VITS / KSS (đang dùng)

| Model | Source | Ghi chú |
|-------|--------|---------|
| **VITS KSS** (neurlang/coqui-vits-kss-korean) | HuggingFace | Giọng nữ, train trên KSS, ~950MB. Đang dùng cho 여자 |
| **MMS-TTS Korean** (facebook/mms-tts-kor) | HuggingFace, arxiv 2305.13516 | VITS, 36M params. Transformers 4.33+. **Lưu ý: cần Romanize input (uroman)** |
| **MMS-TTS KSS** (facebook/mms-tts-kss) | HuggingFace | VITS trên KSS – khác với mms-tts-kor |

### VALL-E Korean

| Model | Source | Ghi chú |
|-------|--------|---------|
| **VALL-E Korean** (LearnItAnyway) | HuggingFace | Zero-shot TTS, 2000h Korean (AI-Hub), AR+NAR, 12 layers |

### Multilingual (có Korean)

| Model | Source | Ghi chú |
|-------|--------|---------|
| **XTTS v2** (Coqui) | Coqui TTS | Multilingual, cần reference WAV. Có trong project |
| **Fish Speech** | fish.audio, arxiv 2411.01156 | ~720k giờ, LLM-based, multilingual, 2024 |
| **Kokoro 82M** | kokoro-tts | EN, FR, **KO**, JA, ZH. 82M params |

---

## 2. Benchmark & Báo cáo chất lượng

### Artificial Analysis (2025)

- So sánh **59 mô hình TTS** (quality ELO, giá, tốc độ)
- Có **XTTS v2** trong danh sách
- Không có benchmark riêng cho tiếng Hàn

### MDPI – Benchmarking Open-Source TTS Responsiveness (Sep 2025)

- Đo **latency, tail latency, intelligibility** cho **13 mô hình open-source**
- Không tập trung vào tiếng Hàn
- Hữu ích để đánh giá tốc độ và độ mượt

### OpenAI TTS cho tiếng Hàn (Podonos)

- Đánh giá trên KsponSpeech
- **Naturalness: 3.55/5** (tương đương “good–fair”)
- Phù hợp cho commercial / API

### Korea Science (2021)

- Real-time TTS tiếng Hàn
- Text2Mel: FastSpeech, FastSpeech 2, FastPitch
- Vocoder: Parallel WaveGAN, Multi-band MelGAN, WaveGlow
- Kích thước mô hình vài chục–vài trăm MB, có thể dùng trên thiết bị nhúng

---

## 3. Gợi ý cho project hiện tại

| Mục đích | Model | Ưu điểm | Nhược điểm |
|----------|--------|---------|-------------|
| **여자** (đang dùng) | VITS KSS | Local, chất lượng tốt, không cần API | Chỉ một giọng |
| **남자** (đang dùng) | OpenAI TTS | Giọng nam ổn định | Cần API key, có phí |
| **남자 – local** | MMS-TTS Korean | Meta, Transformers, local | Input phải Romanize (uroman) |
| **남자 – zero-shot** | VALL-E Korean | Clone giọng từ reference | Setup phức tạp, nhiều dependency |
| **Multilingual** | Kokoro 82M | Hỗ trợ KO, open, 82M params | Cần thử nghiệm chất lượng |
| **Mới nhất** | Fish Speech | LLM-based, 720k h, multilingual | Mới (Nov 2024), cần test |

---

## 4. KsponSpeech + Podonos – Danh sách giọng được chấm điểm

### Report Korean (KsponSpeech)

**Link:** https://workspace.podonos.com/Podonos/reports/f2e37d58-f7ba-488b-aa83-9a591a8544b4

- **Dataset:** KsponSpeech eval clean, 50 samples ngẫu nhiên
- **Model được đánh giá:** OpenAI TTS
- **Điểm tổng naturalness:** 3.55/5 (giữa good và fair)
- **Thang điểm:** 5=excellent, 4=good, 3=fair, 2=poor, 1=bad
- **Người đánh giá:** Người bản ngữ Hàn sống tại Hàn Quốc

Report không có breakdown theo từng giọng OpenAI (alloy, echo, shimmer, onyx, nova).

### Report US English (để tham khảo – có danh sách models)

**Link:** https://www.podonos.com/Podonos/report-en-us

| Model | Provider |
|-------|----------|
| Cartesia - sonic-3 | Cartesia |
| ElevenLabs - eleven_v3 | ElevenLabs |
| Google Cloud - Chirp3-HD | Google |
| ResembleAI - tts-v3 | Resemble AI |
| Respeecher - en-rt | Respeecher |
| Rime - arcana | Rime |
| Typecast - ssfm-v21 | Typecast |

Report này có điểm naturalness + quality theo từng model; không dùng KsponSpeech (dataset tiếng Anh).

### KsponSpeech dataset

- **HuggingFace:** https://huggingface.co/datasets/cheulyop/ksponspeech
- **AI Hub:** https://aihub.or.kr/aidata/105
- **Mô tả:** ~969h Korean spontaneous speech, ~2000 người nói

---

## 5. Tham khảo

- Podonos blog Korean TTS: https://podonos.com/blog/speech-synthesis-performance-openai-text-to-speech-for-korean
- Artificial Analysis TTS: https://artificialanalysis.ai/text-to-speech/models
- MDPI benchmark (Sep 2025): https://www.mdpi.com/2073-431X/14/10/406
- MMS-TTS Korean: https://huggingface.co/facebook/mms-tts-kor
- VALL-E Korean: https://huggingface.co/LearnItAnyway/vall-e_korean
- Fish Speech: https://fish.audio, https://github.com/fishaudio/fish-speech
- Kokoro: https://kokorotts.pro, https://pypi.org/project/kokoro-tts/
