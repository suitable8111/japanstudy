# JapanStudy - 일본어 학습 앱

## 프로젝트 개요

일상 일본어를 효과적으로 학습할 수 있는 Flutter 기반 iOS/Android 앱입니다.
단어 암기, 문장 해석, 4지선다 퀴즈, 라디오 청취까지 단계별 학습을 지원하며,
난이도별 퀴즈 시스템과 랭킹을 통해 학습 동기를 부여합니다.

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

### 1단계: 단어 외우기

- 단어 500개 (N5: 200, N4: 150, N3: 150)
- 20개 랜덤 선별 → 일본어 표시 + TTS 발음 → 터치 시 한국어 해석 + TTS 재생

### 2단계: 문장 해석하기

- 문장 200개 (N5: 98, N4: 72, N3: 30)
- 20개 랜덤 선별 → 일본어 문장 + TTS → 터치 시 한국어 해석 + TTS 재생

### 3단계: 퀴즈 풀기

- **난이도 선택**: 상(N3) / 중(N4) / 하(N5)
- 선택 난이도 80% + 나머지 레벨 20% 비중으로 20문제 출제
- 4지선다 객관식 (단어 퀴즈 / 문장 퀴즈)
- 오답 시 TTS로 정답 발음 재생
- 퀴즈 완료 시 Firestore에 통계 자동 저장

### 4단계: 라디오 듣기

- 단어/문장 자동 반복 재생 모드
- TTS 속도, 반복 간격 설정 가능

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
- TTS 설정 (속도, 피치 조절)
- 이메일 / Google / Apple 로그인

---

## 화면 구성

```
[로그인 화면] ── Email / Google / Apple 로그인
      │
[홈 화면]
   ├── 1단계: 단어 외우기 → [단어 학습 화면] (20개 랜덤 + TTS)
   ├── 2단계: 문장 해석하기 → [문장 학습 화면] (20개 랜덤 + TTS)
   ├── 3단계: 퀴즈 풀기 → [유형 선택] → [난이도 선택(상/중/하)] → [퀴즈 화면]
   ├── 4단계: 라디오 듣기 → [모드 선택] → [라디오 화면]
   │
   └── Drawer 메뉴
          ├── 내 프로필 → [프로필 화면] (캘린더 + 통계)
          ├── 랭킹 → [랭킹 화면] (난이도별 TOP 10)
          ├── 공부한 내역 → [히스토리 화면] → [상세 화면]
          ├── 설정 → [설정 화면] (TTS 속도/피치)
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
│   └── study_record.dart
├── services/
│   ├── firestore_service.dart
│   ├── word_service.dart
│   ├── sentence_service.dart
│   ├── tts_service.dart
│   ├── google_cloud_tts_service.dart
│   └── history_service.dart
├── providers/
│   ├── auth_provider.dart
│   ├── word_provider.dart
│   ├── sentence_provider.dart
│   ├── quiz_provider.dart
│   ├── radio_provider.dart
│   ├── history_provider.dart
│   ├── ranking_provider.dart
│   └── tts_settings_provider.dart
└── screens/
    ├── auth_screen.dart
    ├── home_screen.dart
    ├── word_study_screen.dart
    ├── sentence_study_screen.dart
    ├── quiz_screen.dart
    ├── radio_screen.dart
    ├── profile_screen.dart
    ├── ranking_screen.dart
    ├── history_screen.dart
    ├── history_detail_screen.dart
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

### Phase 5 - 학습 강화 (예정)

- [ ] **오답 노트**: 퀴즈에서 틀린 문제만 모아서 복습 + 재도전
- [ ] **즐겨찾기**: 어려운 단어/문장을 북마크하여 따로 학습
- [ ] **스트릭 시스템**: 연속 학습일수 트래킹 + 홈 화면에 불꽃 아이콘 표시
- [ ] **일일 학습 목표**: 하루 목표 설정 (예: 단어 20개 + 퀴즈 1회) + 달성률 표시

### Phase 6 - 콘텐츠 확장 (예정)

- [ ] **단어 5,000개 이상 확장** (N2/N1 레벨 추가)
- [ ] **문장 1,000개 이상 확장**
- [ ] **카테고리별 학습**: 음식, 여행, 비즈니스 등 상황별 필터
- [ ] **레벨 테스트**: 사전 테스트로 유저 실력 자동 판별 → 맞춤 난이도 추천

### Phase 7 - 소셜 & 편의 기능 (예정)

- [ ] **푸시 알림**: 매일 학습 리마인더 (오전 9시 등 설정 가능)
- [ ] **홈 위젯**: 오늘의 단어 위젯 (iOS/Android)
- [ ] **친구 추가 & 대결 모드**: 실시간 퀴즈 대결
- [ ] **학습 통계 차트**: 주간/월간 학습량 그래프 (fl_chart)

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
