"""
JLPT 단어/문장 JSON에 영어 번역 추가하는 스크립트

사용법:
  python3 scripts/add_english.py words     # 단어 처리
  python3 scripts/add_english.py sentences # 문장 처리
  python3 scripts/add_english.py all       # 전체 처리

- 단어: Jisho API (JLPT 특화 영일사전, 무료)
- 문장: Google Translate 비공식 엔드포인트 (무료)
- 진행상황 자동 저장 → 중단 후 재시작 시 이어서 처리
"""

import json
import sys
import time
import requests
from pathlib import Path

BASE = Path(__file__).parent.parent / "assets" / "data"
WORDS_FILE = BASE / "words.json"
SENTENCES_FILE = BASE / "sentences.json"

SESSION = requests.Session()
SESSION.headers.update({"User-Agent": "Mozilla/5.0 JLPTStudyApp/1.0"})


# ─── Jisho API (단어용) ────────────────────────────────────────────────────────

def jisho_lookup(japanese: str) -> str:
    """Jisho API로 영어 의미 검색. 상위 3개 정의 반환."""
    try:
        r = SESSION.get(
            "https://jisho.org/api/v1/search/words",
            params={"keyword": japanese},
            timeout=10,
        )
        data = r.json().get("data", [])
        if not data:
            return ""

        # 완전 일치하는 항목 우선 찾기
        for entry in data[:3]:
            for form in entry.get("japanese", []):
                if form.get("word") == japanese or form.get("reading") == japanese:
                    senses = entry.get("senses", [])
                    if senses:
                        defs = senses[0].get("english_definitions", [])
                        return "; ".join(defs[:3])

        # 완전 일치 없으면 첫 결과 사용
        senses = data[0].get("senses", [])
        if senses:
            defs = senses[0].get("english_definitions", [])
            return "; ".join(defs[:3])

    except Exception as e:
        print(f"  [Jisho 오류] {japanese}: {e}")
    return ""


# ─── Google Translate 비공식 (문장용) ──────────────────────────────────────────

def google_translate(text: str, src: str = "ja", dest: str = "en") -> str:
    """Google Translate 비공식 엔드포인트 사용."""
    try:
        r = SESSION.get(
            "https://translate.googleapis.com/translate_a/single",
            params={"client": "gtx", "sl": src, "tl": dest, "dt": "t", "q": text},
            timeout=10,
        )
        result = r.json()
        return "".join(seg[0] for seg in result[0] if seg[0])
    except Exception as e:
        print(f"  [번역 오류] {text[:30]}...: {e}")
    return ""


# ─── 단어 처리 ────────────────────────────────────────────────────────────────

def process_words():
    words = json.loads(WORDS_FILE.read_text(encoding="utf-8"))
    total = len(words)
    todo = [w for w in words if not w.get("english")]
    done = total - len(todo)

    print(f"\n[단어] 전체 {total}개 | 완료 {done}개 | 남은 것 {len(todo)}개\n")
    if not todo:
        print("모두 완료됐습니다!")
        return

    for i, word in enumerate(todo, 1):
        jp = word.get("japanese", "")
        reading = word.get("reading", "")

        # 히라가나/가타카나는 reading으로 검색
        query = jp if jp != reading else reading
        english = jisho_lookup(query)

        # Jisho 실패 시 reading으로 재시도
        if not english and jp != reading:
            english = jisho_lookup(reading)

        word["english"] = english
        status = "✓" if english else "✗"
        print(f"  [{done+i}/{total}] {status} {jp} ({reading}) → {english or '(없음)'}")

        # 50개마다 저장
        if i % 50 == 0:
            WORDS_FILE.write_text(
                json.dumps(words, ensure_ascii=False, indent=2), encoding="utf-8"
            )
            print(f"  --- {done+i}개 저장 완료 ---")

        time.sleep(0.3)  # Jisho 부하 방지

    WORDS_FILE.write_text(
        json.dumps(words, ensure_ascii=False, indent=2), encoding="utf-8"
    )
    success = sum(1 for w in words if w.get("english"))
    print(f"\n완료! 영어 있음: {success}/{total}개")


# ─── 문장 처리 ────────────────────────────────────────────────────────────────

def process_sentences():
    sentences = json.loads(SENTENCES_FILE.read_text(encoding="utf-8"))
    total = len(sentences)
    todo = [s for s in sentences if not s.get("english")]
    done = total - len(todo)

    print(f"\n[문장] 전체 {total}개 | 완료 {done}개 | 남은 것 {len(todo)}개\n")
    if not todo:
        print("모두 완료됐습니다!")
        return

    for i, sentence in enumerate(todo, 1):
        jp = sentence.get("japanese", "")
        english = google_translate(jp)
        sentence["english"] = english

        status = "✓" if english else "✗"
        print(f"  [{done+i}/{total}] {status} {jp[:25]}... → {english[:40] if english else '(없음)'}")

        # 30개마다 저장
        if i % 30 == 0:
            SENTENCES_FILE.write_text(
                json.dumps(sentences, ensure_ascii=False, indent=2), encoding="utf-8"
            )
            print(f"  --- {done+i}개 저장 완료 ---")

        time.sleep(0.5)  # Google 부하 방지

    SENTENCES_FILE.write_text(
        json.dumps(sentences, ensure_ascii=False, indent=2), encoding="utf-8"
    )
    success = sum(1 for s in sentences if s.get("english"))
    print(f"\n완료! 영어 있음: {success}/{total}개")


# ─── 진입점 ───────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    mode = sys.argv[1] if len(sys.argv) > 1 else "all"

    if mode in ("words", "all"):
        process_words()

    if mode in ("sentences", "all"):
        process_sentences()

    if mode not in ("words", "sentences", "all"):
        print("사용법: python3 scripts/add_english.py [words|sentences|all]")
