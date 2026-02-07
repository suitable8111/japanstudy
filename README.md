# JapanStudy - 일본어 학습 앱

## 프로젝트 개요

일상 일본어를 효과적으로 학습할 수 있는 Flutter 기반 Android 앱입니다.
단어 암기부터 문장 해석까지 단계별 학습을 지원하며, TTS(Text-to-Speech) 기능과 학습 이력 관리를 통해 체계적인 일본어 공부를 도와줍니다.

## 기술 스택

| 구분 | 기술 |
|------|------|
| **프레임워크** | Flutter (Dart) |
| **플랫폼** | Android |
| **백엔드/DB** | Firebase (Firestore + Authentication) |
| **TTS** | flutter_tts 패키지 |
| **상태관리** | Provider 또는 Riverpod |

## 주요 기능

### 1단계: 단어 외우기

- **데이터**: Firebase Firestore에 최소 **5,000개 이상**의 일본어 단어 저장
  - 히라가나 (ひらがな)
  - 가타카나 (カタカナ)
  - 일본식 한자어 (漢字)
- **출처**: 네이버 일어사전, 일상 일본어 기반
- **학습 흐름**:
  1. `테스트 시작!` 버튼 클릭
  2. 저장된 단어 중 **20개를 랜덤**으로 선별하여 표시
  3. 일본어 단어가 화면에 표시됨 + **TTS로 일본어 발음 재생**
  4. 화면을 터치하면 **한국어 해석이 표시** + **TTS로 한국어 발음 재생**
  5. 다음 단어로 넘어가며 반복

#### 단어 데이터 구조 (Firestore)

```
words (collection)
├── word_id (document)
│   ├── japanese: "食べる"        // 일본어 표기
│   ├── reading: "たべる"         // 히라가나 읽기
│   ├── korean: "먹다"           // 한국어 뜻
│   ├── category: "동사"         // 품사 분류
│   ├── level: "N5"             // JLPT 레벨
│   └── type: "kanji"           // hiragana / katakana / kanji
```

---

### 2단계: 문장 해석하기

- **데이터**: Firebase Firestore에 약 **1,000개 이상**의 일상 일본어 문장 저장
- **학습 흐름**:
  1. `문장공부 테스트 시작!` 버튼 클릭
  2. 저장된 문장 중 **20개를 랜덤**으로 선별하여 표시
  3. 일본어 문장이 화면에 표시됨 + **TTS로 일본어 문장 재생**
  4. 화면을 터치하면 **한국어 해석이 표시** + **TTS로 한국어 해석 재생**
  5. 다음 문장으로 넘어가며 반복

#### 문장 데이터 구조 (Firestore)

```
sentences (collection)
├── sentence_id (document)
│   ├── japanese: "今日はいい天気ですね。"   // 일본어 문장
│   ├── reading: "きょうはいいてんきですね。"  // 히라가나 읽기
│   ├── korean: "오늘은 좋은 날씨네요."      // 한국어 해석
│   ├── category: "일상회화"                // 카테고리
│   └── level: "N5"                        // JLPT 레벨
```

---

### 3단계: 공부한 내역 확인하기 (복습)

- **학습 이력 저장**:
  - 테스트를 수행할 때마다 날짜, 시간, 학습한 단어/문장 목록이 기록됨
  - 각 테스트의 정답률 및 결과 저장
- **복습 기능**:
  - 날짜별 학습 이력 조회
  - 특정 테스트를 선택하여 동일한 단어/문장으로 재시험
  - 틀린 문제만 모아서 반복 학습
  - 학습 통계 대시보드 (일별/주별/월별 학습량)

#### 학습 이력 데이터 구조 (Firestore)

```
users (collection)
├── user_id (document)
│   └── history (sub-collection)
│       ├── history_id (document)
│       │   ├── type: "word" | "sentence"     // 학습 유형
│       │   ├── date: Timestamp               // 수행 날짜/시간
│       │   ├── items: [word_id1, word_id2...] // 학습한 단어/문장 ID 목록
│       │   ├── results: [true, false, ...]    // 각 문제 정답 여부
│       │   └── score: 18                      // 맞은 개수 (20개 중)
```

---

## 화면 구성 (Screen Flow)

```
[홈 화면]
   ├── [1단계: 단어 외우기]
   │      ├── 테스트 시작! → [단어 학습 화면] (20개 랜덤)
   │      │                    ├── 일본어 표시 + TTS 재생
   │      │                    └── 터치 → 한국어 해석 + TTS 재생
   │      └── 카테고리/레벨 필터 (선택사항)
   │
   ├── [2단계: 문장 해석하기]
   │      ├── 문장공부 테스트 시작! → [문장 학습 화면] (20개 랜덤)
   │      │                           ├── 일본어 문장 표시 + TTS 재생
   │      │                           └── 터치 → 한국어 해석 + TTS 재생
   │      └── 카테고리/레벨 필터 (선택사항)
   │
   └── [3단계: 복습하기]
          ├── 날짜별 학습 이력 리스트
          ├── 테스트 상세보기 (정답률, 틀린 문제)
          ├── 다시 테스트하기
          └── 틀린 문제만 복습하기
```

---

## 프로젝트 구조

```
lib/
├── main.dart                    // 앱 진입점
├── app.dart                     // MaterialApp 설정
├── config/
│   └── firebase_config.dart     // Firebase 설정
├── models/
│   ├── word.dart                // 단어 모델
│   ├── sentence.dart            // 문장 모델
│   └── study_history.dart       // 학습 이력 모델
├── services/
│   ├── firestore_service.dart   // Firestore CRUD
│   ├── tts_service.dart         // TTS 서비스
│   └── auth_service.dart        // 인증 서비스
├── providers/
│   ├── word_provider.dart       // 단어 상태관리
│   ├── sentence_provider.dart   // 문장 상태관리
│   └── history_provider.dart    // 이력 상태관리
└── screens/
    ├── home_screen.dart         // 홈 화면
    ├── word_study_screen.dart   // 단어 학습 화면
    ├── sentence_study_screen.dart // 문장 학습 화면
    └── history_screen.dart      // 복습/이력 화면
```

---

## 사용 패키지

| 패키지 | 용도 |
|--------|------|
| `firebase_core` | Firebase 초기화 |
| `cloud_firestore` | Firestore 데이터베이스 |
| `firebase_auth` | 사용자 인증 |
| `flutter_tts` | Text-to-Speech (일본어/한국어) |
| `provider` / `flutter_riverpod` | 상태관리 |
| `intl` | 날짜/시간 포맷 |
| `fl_chart` | 학습 통계 차트 (선택) |

---

## 개발 로드맵

### Phase 1 - MVP (최소 기능 제품)
- [ ] Flutter 프로젝트 생성 및 Firebase 연동
- [ ] 단어 데이터 Firestore 등록 (초기 500개)
- [ ] 단어 학습 화면 구현 (20개 랜덤 + TTS)
- [ ] 기본 홈 화면 구현

### Phase 2 - 문장 학습
- [ ] 문장 데이터 Firestore 등록 (초기 200문장)
- [ ] 문장 학습 화면 구현 (20개 랜덤 + TTS)
- [ ] 카테고리/레벨 필터 기능

### Phase 3 - 복습 기능
- [ ] 학습 이력 저장 기능
- [ ] 복습 화면 구현 (날짜별 이력 조회)
- [ ] 다시 테스트하기 기능
- [ ] 틀린 문제만 복습하기

### Phase 4 - 데이터 확장 및 고도화
- [ ] 단어 5,000개 이상으로 확장
- [ ] 문장 1,000개 이상으로 확장
- [ ] 학습 통계 대시보드
- [ ] UI/UX 개선 및 최적화

---

## 실행 방법

```bash
# 프로젝트 클론
git clone https://github.com/<username>/japanstudy.git
cd japanstudy

# 의존성 설치
flutter pub get

# Firebase 설정 (flutterfire CLI 사용)
flutterfire configure

# 앱 실행
flutter run
```

---

## 라이선스

MIT License
