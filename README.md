# JLPT 일기장 - 일본어 학습 앱

## 프로젝트 개요

일상 일본어를 효과적으로 학습할 수 있는 Flutter 기반 iOS/Android 앱입니다.
음절(히라가나/가타카나) 학습부터 단어 암기, 문장 해석, 4지선다 퀴즈, 라디오 청취까지
단계별 학습을 지원하며, 난이도별 퀴즈 시스템과 랭킹을 통해 학습 동기를 부여합니다.

## 기술 스택

| 구분 | 기술 |
|------|------|
| **프레임워크** | Flutter (Dart) |
| **플랫폼** | iOS / Android |
| **백엔드/DB** | Firebase (Firestore + Authentication) |
| **인증** | Email, Google, Apple 로그인 |
| **TTS** | flutter_tts |
| **상태관리** | Provider |

---

## 주요 기능

### 0단계: 음절 공부하기

- 히라가나 71자 (청음 46자 + 탁음 20자 + 반탁음 5자)
- 가타카나 71자 (청음 46자 + 탁음 20자 + 반탁음 5자)
- 플립카드 방식: 음절(80px 큰 글자) → 한글 발음 + 로마자
- 행(あ행, か행 등) 뱃지 표시
- TTS 발음 재생
- **써보기 모드**: 청음 46자를 순서대로 보며 캔버스에 손가락으로 따라 쓰기 연습

### 1단계: 단어 외우기

- 단어 5,000개+ (N5~N1 전 레벨)
- **레벨 선택**: 전체 랜덤 / N5 / N4 / N3 / N2 / N1
- 20개 선별 → 일본어 표시 + TTS 발음 → 터치 시 한국어 해석 + TTS 재생

### 2단계: 문장 외우기

- 문장 1,000개+ (N5~N1 전 레벨)
- **레벨 선택** → **카테고리 선택** (전체 / 일상 / 여행 / 식사 등)
- 20개 선별 → 일본어 문장 + TTS → 터치 시 한국어 해석 + TTS 재생

### 3단계: 퀴즈 풀기

- **히라가나/가타카나 퀴즈**: 음절 → 한글 발음 4지선다 (난이도 선택 없이 바로 시작)
- **단어/문장 퀴즈**: 난이도 선택 — 최상(N1) / 상상(N2) / 상(N3) / 중(N4) / 하(N5)
- 선택 난이도 80% + 나머지 레벨 20% 비중으로 20문제 출제
- 4지선다 객관식
- 오답 시 TTS로 정답 발음 재생
- 퀴즈 완료 시 Firestore에 통계 자동 저장

### 4단계: 라디오 듣기

- 단어/문장 자동 반복 재생 모드
- **레벨 선택**: 전체 랜덤 / N5 / N4 / N3 / N2 / N1
- TTS 속도, 반복 간격 설정 가능

### 레벨 테스트

- 적응형 15문제 4지선다 (단어 기반)
- N5부터 시작, 맞추면 난이도 상승 / 틀리면 하락
- 결과 화면: 추천 레벨 + 레벨별 정답률 그래프

### 오답 노트

- 퀴즈에서 틀린 문제를 전체/단어/문장 탭별로 모아서 확인
- 틀린 문제만 다시 퀴즈로 재도전 가능

### 프로필

- 유저 정보 (아바타, 이름, 이메일)
- 최근 30일 + 앞으로 10일 학습 캘린더 (파란점=단어, 보라점=문장, 주황점=퀴즈)
- 난이도별 퀴즈 통계 카드 (N3/N4/N5 각각 횟수 + 평균 정답률)

### 랭킹

- 난이도 탭 (상/중/하) 전환
- TOP 10 리스트: 순위, 이름, 퀴즈 횟수, 최고 점수 기준 정렬
- 1/2/3위 금/은/동 아이콘, 현재 유저 하이라이트

### 기타

- 학습 이력 조회 및 삭제
- TTS 설정 (속도, 피치, 엔진 선택, 음성 선택)
- 퀴즈 자동 음성 재생 ON/OFF (음성 없이 문장을 읽고 풀기 가능)
- 모든 학습 초기화 (학습 기록 + 퀴즈 결과 + 랭킹 통계 일괄 삭제)
- 이메일 / Google / Apple 로그인

---

## 화면 구성

```
[로그인 화면] ── Email / Google / Apple 로그인
      │
[홈 화면]
   ├── 0단계: 음절 공부하기 → [유형 선택(히라가나/가타카나)] → [모드 선택(공부하기/써보기)]
   │                        ├── 공부하기 → [음절 학습 화면]
   │                        └── 써보기 → [필기 연습 화면] (캔버스 드로잉)
   ├── 1단계: 단어 외우기 → [레벨 선택(전체/N5~N1)] → [단어 학습 화면]
   ├── 2단계: 문장 외우기 → [레벨 선택] → [카테고리 선택] → [문장 학습 화면]
   ├── 3단계: 퀴즈 풀기 → [유형 선택(히라가나/가타카나/단어/문장)]
   │                        ├── 히라가나/가타카나 → [퀴즈 화면] (바로 시작)
   │                        └── 단어/문장 → [난이도 선택(N5~N1)] → [퀴즈 화면]
   ├── 4단계: 라디오 듣기 → [모드 선택] → [레벨 선택] → [라디오 화면]
   │
   └── Drawer 메뉴
          ├── 내 프로필 → [프로필 화면] (캘린더 + 통계)
          ├── 오답 노트 → [오답 노트 화면] (전체/단어/문장 탭 + 재도전)
          ├── 레벨 테스트 → [레벨 테스트 화면] (적응형 15문제 → 추천 레벨)
          ├── 랭킹 → [랭킹 화면] (난이도별 TOP 10)
          ├── 공부한 내역 → [히스토리 화면] → [상세 화면]
          ├── 설정 → [설정 화면] (TTS 설정 / 퀴즈 자동 음성 / 학습 초기화)
          └── 로그아웃
```

---

## Firestore 구조

```
users/{uid}/
  displayName, email, createdAt
  study_records/{recordId}/
    date, type, totalCount, correctCount?, difficulty?, items[]

user_stats/{uid}/
  displayName, uid, updatedAt
  N5: { quizCount, totalCorrect, totalQuestions, bestRate }
  N4: { quizCount, totalCorrect, totalQuestions, bestRate }
  N3: { quizCount, totalCorrect, totalQuestions, bestRate }
  N2: { quizCount, totalCorrect, totalQuestions, bestRate }
  N1: { quizCount, totalCorrect, totalQuestions, bestRate }
```

---

## 프로젝트 구조

```
lib/
├── main.dart
├── firebase_options.dart
├── models/
│   ├── word.dart
│   ├── sentence.dart
│   ├── kana.dart
│   └── study_record.dart
├── services/
│   ├── firestore_service.dart
│   ├── word_service.dart
│   ├── sentence_service.dart
│   ├── kana_service.dart
│   ├── tts_service.dart
│   ├── google_cloud_tts_service.dart
│   └── history_service.dart
├── providers/
│   ├── auth_provider.dart
│   ├── word_provider.dart
│   ├── sentence_provider.dart
│   ├── kana_provider.dart
│   ├── quiz_provider.dart
│   ├── radio_provider.dart
│   ├── level_test_provider.dart
│   ├── history_provider.dart
│   ├── ranking_provider.dart
│   └── tts_settings_provider.dart
├── widgets/
│   ├── rolling_ticker.dart
│   └── drawing_canvas.dart
└── screens/
    ├── auth_screen.dart
    ├── home_screen.dart
    ├── word_study_screen.dart
    ├── sentence_study_screen.dart
    ├── kana_study_screen.dart
    ├── kana_writing_screen.dart
    ├── quiz_screen.dart
    ├── radio_screen.dart
    ├── level_test_screen.dart
    ├── profile_screen.dart
    ├── ranking_screen.dart
    ├── history_screen.dart
    ├── history_detail_screen.dart
    ├── wrong_answer_screen.dart
    ├── stats_screen.dart
    └── settings_screen.dart
```

---

## 개발 로드맵

### Phase 1 ~ 4 (완료)

- [x] Flutter 프로젝트 생성 및 Firebase 연동
- [x] 단어 500개 / 문장 200개 데이터 등록 (N5/N4/N3 레벨)
- [x] 단어 학습 + 문장 학습 화면 (20개 랜덤 + TTS)
- [x] 4지선다 퀴즈 (단어/문장)
- [x] 라디오 모드 (자동 반복 재생)
- [x] 학습 이력 저장/조회/삭제
- [x] Email / Google / Apple 로그인
- [x] 난이도 선택 시스템 (N3 상 / N4 중 / N5 하, 선택 난이도 80%)
- [x] 프로필 화면 (학습 캘린더 + 난이도별 퀴즈 통계)
- [x] 랭킹 시스템 (난이도별 TOP 10, 최고 점수 기준)
- [x] TTS 설정 (속도, 피치)

### Phase 5 (완료)

- [x] **오답 노트**: 퀴즈에서 틀린 문제만 모아서 복습 + 재도전
- [x] **음절 학습**: 히라가나/가타카나 71자씩 플립카드 학습 + TTS
- [x] **음절 퀴즈**: 히라가나/가타카나 4지선다 퀴즈

### Phase 6 - 콘텐츠 확장 + 레벨 시스템 (완료)

- [x] **단어 5,000개 이상 확장** (N2/N1 레벨 추가)
- [x] **문장 1,000개 이상 확장**
- [x] **카테고리별 학습**: 1단계(레벨 선택), 2단계(레벨+카테고리 선택) 필터링
- [x] **라디오 레벨별 필터**: 라디오 모드에서도 레벨 선택 가능
- [x] **레벨 테스트**: 적응형 15문제 (N5→N1) → 추천 레벨 + 레벨별 정답률

### Phase 7 - UX 개선 & 편의 기능 (완료)

- [x] **히라가나/가타카나 써보기**: 청음 46자 필기 연습 (CustomPainter 캔버스)
- [x] **퀴즈 자동 음성 ON/OFF**: 음성 없이 문장을 읽고 풀 수 있는 설정
- [x] **모든 학습 초기화**: 학습 기록 + 퀴즈 결과 + 랭킹 통계 일괄 삭제 (경고 다이얼로그 포함)
- [ ] **즐겨찾기**: 어려운 단어/문장을 북마크하여 따로 학습
- [ ] **학습 통계 차트**: 주간/월간 학습량 그래프 (fl_chart)

### Phase 8 - 게이미피케이션 & 리텐션 강화 (예정)

- [ ] **연속 학습 스트릭(Streak) 시스템**: 매일 학습 시 불꽃 아이콘 활성화, 스트릭 유지 동기 부여
- [ ] **업적 및 배지 시스템**: 'N3 단어 마스터', '일주일 연속 출석' 등 조건 달성 시 배지 수집
- [ ] **다크 모드 & 테마 커스텀**: 밤 학습을 위한 다크 모드, 레벨별 앱 테마 변경
- [ ] **스마트 푸시 알림**: 사용자 학습 패턴에 맞춘 맞춤형 학습 리마인더 발송

### Phase 9 - AI 기반 지능형 학습 (예정)

- [ ] **망각 곡선(SRS) 알고리즘**: 틀린 단어를 1일/3일/7일 주기로 재노출하는 지능형 복습
- [ ] **AI 작문 교정 (LLM 활용)**: 짧은 일본어 문장을 쓰면 문법 교정 + JLPT 수준 표현 추천
- [ ] **한자 필기 인식**: 화면에 한자를 써서 맞추는 퀴즈 (Google ML Kit 활용)
- [ ] **쉐도잉(Shadowing) 모드**: TTS를 듣고 따라 읽으면 발음 정확도 점수 환산

### Phase 10 - 소셜 에코시스템 & 플랫폼 확장 (예정)

- [ ] **실시간 퀴즈 배틀 (1vs1)**: 비슷한 레벨 유저와 10문제 대결 모드
- [ ] **공유 학습장 (Community Decks)**: 유저가 만든 예문/암기 팁 공유 + 좋아요 시스템
- [ ] **홈 위젯 지원**: '오늘의 단어' iOS/Android 위젯
- [ ] **태블릿 최적화**: iPad/Android 태블릿 분할 화면(Split View) 및 가로 모드 지원

---

## 기술 스택 로드맵

| 구분 | 현재 | 추천 (Phase 10 대비) | 이유 |
|------|------|---------------------|------|
| **상태 관리** | Provider | Riverpod | 더 안전한 의존성 주입과 비동기 데이터 처리(AsyncNotifier)에 유리 |
| **로컬 DB** | Firestore (Online) | Isar / Drift | 오프라인 모드(지하철 등)에서도 단어장을 볼 수 있도록 로컬 캐싱 강화 |
| **이미지** | 기본 Assets | CachedNetworkImage | 확장될 단어/문장의 이미지 데이터를 효율적으로 로딩 |

---

## 사용 패키지

| 패키지 | 용도 |
|--------|------|
| `firebase_core` | Firebase 초기화 |
| `cloud_firestore` | Firestore 데이터베이스 |
| `firebase_auth` | 사용자 인증 |
| `google_sign_in` | Google 로그인 |
| `sign_in_with_apple` | Apple 로그인 |
| `flutter_tts` | Text-to-Speech (일본어/한국어) |
| `provider` | 상태관리 |
| `crypto` | Apple 로그인 nonce 해싱 |

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
