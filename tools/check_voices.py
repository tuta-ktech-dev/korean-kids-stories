#!/usr/bin/env python3
"""
Kiểm tra chapter nào thiếu giọng 남자 hoặc 여자 (mặc định mỗi chapter cần 2 giọng).
"""
import json
import sys
from collections import defaultdict
from pathlib import Path
from urllib.request import Request, urlopen

sys.path.insert(0, str(Path(__file__).resolve().parent))
from pb_config import PB_BASE_URL, PB_EMAIL, PB_PASSWORD, require_pb_config

def main():
    require_pb_config()
    base = (PB_BASE_URL or "").rstrip("/")
    if not base:
        print("PB_BASE_URL required", file=sys.stderr)
        sys.exit(1)

    # Auth
    auth_res = urlopen(
        Request(
            f"{base}/api/collections/_superusers/auth-with-password",
            data=json.dumps({"identity": PB_EMAIL, "password": PB_PASSWORD}).encode(),
            headers={"Content-Type": "application/json"},
            method="POST",
        ),
        timeout=30,
    )
    token = json.loads(auth_res.read())["token"]

    # Fetch all chapter_audios
    records = []
    page = 1
    while True:
        req = Request(
            f"{base}/api/collections/chapter_audios/records?page={page}&perPage=200",
            headers={"Authorization": f"Bearer {token}"},
        )
        with urlopen(req, timeout=60) as r:
            data = json.loads(r.read())
        items = data.get("items", [])
        records.extend(items)
        if len(items) < 200:
            break
        page += 1

    ch_to_narrators = defaultdict(set)
    for r in records:
        ch = r.get("chapter", "")
        n = (r.get("narrator") or "").strip()
        if ch and n:
            ch_to_narrators[ch].add(n)

    # Normalize: 남자/여자 (chấp nhận biến thể: 새 목소리 = OpenAI female -> coi như 여자)
    def has_voice(narrators, name):
        vals = {x.strip() for x in narrators if x}
        s = {x.lower().strip() for x in narrators if x}
        if name == "남자":
            return "남자" in vals or "male" in s or "nam" in s
        if name == "여자":
            return "여자" in vals or "female" in s or "nu" in s or "nữ" in s or "새 목소리" in vals
        return name in vals

    missing_yeoja = []
    missing_namja = []
    ok_both = []
    for ch_id, narrators in ch_to_narrators.items():
        has_n = has_voice(narrators, "남자")
        has_y = has_voice(narrators, "여자")
        if has_n and has_y:
            ok_both.append(ch_id)
        elif not has_y:
            missing_yeoja.append((ch_id, list(narrators)))
        elif not has_n:
            missing_namja.append((ch_id, list(narrators)))

    total = len(ch_to_narrators)
    print(f"\n=== Tổng {total} chapter có audio ===\n")
    print(f"  OK (có cả 남자 + 여자): {len(ok_both)}")
    print(f"  Thiếu 여자: {len(missing_yeoja)}")
    print(f"  Thiếu 남자: {len(missing_namja)}")

    if missing_yeoja:
        print(f"\n--- Chapters thiếu 여자 ({len(missing_yeoja)}) ---")
        for ch_id, narrs in missing_yeoja[:20]:
            print(f"  {ch_id}  narrators={narrs}")
        if len(missing_yeoja) > 20:
            print(f"  ... và {len(missing_yeoja)-20} chapter nữa")

    if missing_namja:
        print(f"\n--- Chapters thiếu 남자 ({len(missing_namja)}) ---")
        for ch_id, narrs in missing_namja[:20]:
            print(f"  {ch_id}  narrators={narrs}")
        if len(missing_namja) > 20:
            print(f"  ... và {len(missing_namja)-20} chapter nữa")

    print(f"\n>> Thêm 여자:  python add_yeoja_voice.py --limit {len(missing_yeoja)}  # KSS local")
    if missing_namja:
        print(f">> Thêm 남자:  OPENAI_API_KEY=sk-xxx python add_namja_voice.py --limit {len(missing_namja)}  # OpenAI TTS")


if __name__ == "__main__":
    main()
