import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tts_settings_provider.dart';

class AppStrings {
  final String appSubtitle;

  // Streak
  final String streakStart;
  String streakDays(int n) => _streakDays(n);
  final String Function(int) _streakDays;

  // Streak milestone dialog
  final String streakCongrats;
  final String Function(int) streakAchieved;
  final Map<int, String> streakMessages;
  final String streakConfirm;

  // Rolling ticker
  final String tickerTodayStudy;
  final String tickerTotalStudy;
  final String tickerTodayQuiz;
  final String tickerTotalQuiz;
  final String tickerAccuracy;
  final String tickerWrongNote;

  // Main menu buttons
  final String menu0Title;
  final String menu0Subtitle;
  final String menu1Title;
  final String menu1Subtitle;
  final String menu2Title;
  final String menu2Subtitle;
  final String menu3Title;
  final String menu3Subtitle;
  final String menu4Title;
  final String menu4Subtitle;

  // Kana dialogs
  final String kanaSelectType;
  final String kanaHiragana;
  final String kanaHiraganaDesc;
  final String kanaKatakana;
  final String kanaKatakanaDesc;
  final String kanaBoth;
  final String kanaBothDesc;
  final String kanaModeTitle;
  final String kanaModeStudy;
  final String kanaModeStudyDesc;
  final String kanaModeWrite;
  final String kanaModeWriteDesc;
  final String kanaModeWriteBlind;
  final String kanaModeWriteBlindDesc;
  final String kanaOrderTitle;
  final String kanaOrderSequential;
  final String kanaOrderRandom;
  final String kanaCountLabel;
  final String kanaBothCountLabel;

  // Word dialogs
  final String wordModeTitle;
  final String wordModeStudy;
  final String wordModeStudyDesc;
  final String wordModeWrite;
  final String wordModeWriteDesc;
  final String wordLevelTitle;

  // Sentence dialogs
  final String sentenceLevelTitle;
  final String sentenceCategoryAll;
  final String Function(String level) sentenceCategoryAllDesc;
  final String Function(String level, String cat) sentenceCategoryDesc;

  // Level labels
  final String levelRandom;
  final String levelRandomDesc;
  final String Function(String n, String label) levelDesc;
  final String n5Label;
  final String n4Label;
  final String n3Label;
  final String n2Label;
  final String n1Label;

  // Quiz dialogs
  final String quizSelectType;
  final String quizHiragana;
  final String quizHiraganaDesc;
  final String quizKatakana;
  final String quizKatakanaDesc;
  final String quizWord;
  final String quizWordDesc;
  final String quizSentence;
  final String quizSentenceDesc;
  final String Function(String type) quizDifficultyTitle;

  // Radio dialogs
  final String radioSelectMode;
  final String radioWord;
  final String radioWordDesc;
  final String radioSentence;
  final String radioSentenceDesc;
  final String Function(String mode) radioLevelTitle;

  // Drawer
  final String drawerLevelTest;
  final String drawerLevelTestSub;
  final String drawerProfile;
  final String drawerStats;
  final String drawerRanking;
  final String drawerWrongNote;
  final String drawerHistory;
  final String drawerSettings;
  final String drawerLogout;

  // Logout dialog
  final String logoutTitle;
  final String logoutContent;
  final String logoutCancel;
  final String logoutConfirm;

  // Settings screen
  final String settingsTitle;
  final String settingsLangSection;
  final String settingsLangDesc;
  final String settingsThemeSection;
  final String settingsThemeDesc;
  final List<String> settingsThemeNames;
  final String settingsQuizCountSection;
  final String settingsQuizCountDesc;
  final String settingsQuizCountUnit;
  final String settingsAutoTtsSection;
  final String settingsAutoTtsDesc;
  final String settingsAutoTtsOn;
  final String settingsAutoTtsOff;
  final String settingsAutoTtsOnDesc;
  final String settingsAutoTtsOffDesc;
  final String settingsTtsEngineSection;
  final String settingsEngineDevice;
  final String settingsEngineDeviceSub;
  final String settingsEngineCloudSub;
  final String settingsSpeechRateSection;
  final String settingsPitchSection;
  final List<String> settingsSpeedLabels;
  final List<String> settingsPitchLabels;
  final String settingsSliderSlow;
  final String settingsSliderNormal;
  final String settingsSliderFast;
  final String settingsSliderLow;
  final String settingsSliderHigh;
  final String settingsTtsTest;
  final String settingsDataSection;
  final String settingsResetBtn;
  final String settingsResetWarning;
  final String settingsResetDialogTitle;
  final String settingsResetDialogContent;
  final String settingsResetCancel;
  final String settingsResetConfirm;
  final String settingsResetSuccess;
  final String settingsVoiceGender;
  final String settingsGenderFemale;
  final String settingsGenderMale;
  final String settingsDeviceVoiceSelect;
  final String settingsDeviceVoiceDesc;
  final String settingsDeviceVoiceNone;
  final String settingsCloudApiKey;
  final String settingsCloudApiHint;
  final String settingsCloudApiSaved;
  final String settingsCloudApiInfo;
  final String settingsCloudVoiceSelect;
  final String settingsCloudVoiceQualityDesc;

  // Level test screen
  final String levelTestTitle;
  final String levelTestPreparing;
  final String Function(String level) levelTestCurrentLevel;
  final String levelTestNext;
  final String levelTestResult;
  final String levelTestComplete;
  final String levelTestRecommended;
  final String Function(int pct, int correct, int total) levelTestAccuracy;
  final String levelTestLevelAccuracy;
  final String levelTestRetry;
  final String levelTestHome;

  // Profile screen
  final String profileTitle;
  final String profileLearner;
  final String profileSummary;
  final String profileTodayStudy;
  final String profileTotalStudy;
  final String profileTodayQuiz;
  final String profileTotalQuiz;
  final String profileAccuracy;
  final String profileStreak;
  final String profileWrongNote;
  final String profileTotalSessions;
  final String profileBadges;
  final String profileActivityChart;
  final String profileNoActivity;
  final String profileQuizStats;
  final String profileAvgAccuracy;
  final String profileWord;
  final String profileSentence;
  final String profileQuiz;
  final String profileTimesUnit;
  final String profileDaysUnit;
  final String profileItemsUnit;
  final List<String> profileBadgeNames;
  final List<String> profileBadgeDescs;

  // Stats screen
  final String statsTitle;
  final String statsWeekly;
  final String statsMonthly;
  final String statsDailyChart;
  final String statsNoStudy;
  final String statsAccuracyChart;
  final String statsNoQuiz;
  final String statsLevelStats;
  final List<String> weekdays;

  // Ranking screen
  final String rankingTitle;
  final String rankingNoData;
  final String Function(int n) rankingQuizCount;
  final String rankingBestScore;

  // Wrong answer screen
  final String wrongTitle;
  final String wrongAll;
  final String wrongWord;
  final String wrongSentence;
  final String wrongEmpty;
  final String wrongEmptyDesc;
  final String Function(int n) wrongCount;
  final String wrongRetry;

  // History screen
  final String historyTitle;
  final String historyEmpty;
  final String historyEmptyDesc;
  final String historyDelete;
  final String historyDeleteConfirm;
  final String historyCancel;
  final String historyConfirmDelete;

  // History detail screen
  final String historyDetailTitle;
  final String Function(int pct) historyDetailAccuracy;
  final String historyDetailStudyAgain;

  const AppStrings({
    required this.appSubtitle,
    required this.streakStart,
    required String Function(int) streakDays,
    required this.streakCongrats,
    required this.streakAchieved,
    required this.streakMessages,
    required this.streakConfirm,
    required this.tickerTodayStudy,
    required this.tickerTotalStudy,
    required this.tickerTodayQuiz,
    required this.tickerTotalQuiz,
    required this.tickerAccuracy,
    required this.tickerWrongNote,
    required this.menu0Title,
    required this.menu0Subtitle,
    required this.menu1Title,
    required this.menu1Subtitle,
    required this.menu2Title,
    required this.menu2Subtitle,
    required this.menu3Title,
    required this.menu3Subtitle,
    required this.menu4Title,
    required this.menu4Subtitle,
    required this.kanaSelectType,
    required this.kanaHiragana,
    required this.kanaHiraganaDesc,
    required this.kanaKatakana,
    required this.kanaKatakanaDesc,
    required this.kanaBoth,
    required this.kanaBothDesc,
    required this.kanaModeTitle,
    required this.kanaModeStudy,
    required this.kanaModeStudyDesc,
    required this.kanaModeWrite,
    required this.kanaModeWriteDesc,
    required this.kanaModeWriteBlind,
    required this.kanaModeWriteBlindDesc,
    required this.kanaOrderTitle,
    required this.kanaOrderSequential,
    required this.kanaOrderRandom,
    required this.kanaCountLabel,
    required this.kanaBothCountLabel,
    required this.wordModeTitle,
    required this.wordModeStudy,
    required this.wordModeStudyDesc,
    required this.wordModeWrite,
    required this.wordModeWriteDesc,
    required this.wordLevelTitle,
    required this.sentenceLevelTitle,
    required this.sentenceCategoryAll,
    required this.sentenceCategoryAllDesc,
    required this.sentenceCategoryDesc,
    required this.levelRandom,
    required this.levelRandomDesc,
    required this.levelDesc,
    required this.n5Label,
    required this.n4Label,
    required this.n3Label,
    required this.n2Label,
    required this.n1Label,
    required this.quizSelectType,
    required this.quizHiragana,
    required this.quizHiraganaDesc,
    required this.quizKatakana,
    required this.quizKatakanaDesc,
    required this.quizWord,
    required this.quizWordDesc,
    required this.quizSentence,
    required this.quizSentenceDesc,
    required this.quizDifficultyTitle,
    required this.radioSelectMode,
    required this.radioWord,
    required this.radioWordDesc,
    required this.radioSentence,
    required this.radioSentenceDesc,
    required this.radioLevelTitle,
    required this.drawerLevelTest,
    required this.drawerLevelTestSub,
    required this.drawerProfile,
    required this.drawerStats,
    required this.drawerRanking,
    required this.drawerWrongNote,
    required this.drawerHistory,
    required this.drawerSettings,
    required this.drawerLogout,
    required this.logoutTitle,
    required this.logoutContent,
    required this.logoutCancel,
    required this.logoutConfirm,
    required this.settingsTitle,
    required this.settingsLangSection,
    required this.settingsLangDesc,
    required this.settingsThemeSection,
    required this.settingsThemeDesc,
    required this.settingsThemeNames,
    required this.settingsQuizCountSection,
    required this.settingsQuizCountDesc,
    required this.settingsQuizCountUnit,
    required this.settingsAutoTtsSection,
    required this.settingsAutoTtsDesc,
    required this.settingsAutoTtsOn,
    required this.settingsAutoTtsOff,
    required this.settingsAutoTtsOnDesc,
    required this.settingsAutoTtsOffDesc,
    required this.settingsTtsEngineSection,
    required this.settingsEngineDevice,
    required this.settingsEngineDeviceSub,
    required this.settingsEngineCloudSub,
    required this.settingsSpeechRateSection,
    required this.settingsPitchSection,
    required this.settingsSpeedLabels,
    required this.settingsPitchLabels,
    required this.settingsSliderSlow,
    required this.settingsSliderNormal,
    required this.settingsSliderFast,
    required this.settingsSliderLow,
    required this.settingsSliderHigh,
    required this.settingsTtsTest,
    required this.settingsDataSection,
    required this.settingsResetBtn,
    required this.settingsResetWarning,
    required this.settingsResetDialogTitle,
    required this.settingsResetDialogContent,
    required this.settingsResetCancel,
    required this.settingsResetConfirm,
    required this.settingsResetSuccess,
    required this.settingsVoiceGender,
    required this.settingsGenderFemale,
    required this.settingsGenderMale,
    required this.settingsDeviceVoiceSelect,
    required this.settingsDeviceVoiceDesc,
    required this.settingsDeviceVoiceNone,
    required this.settingsCloudApiKey,
    required this.settingsCloudApiHint,
    required this.settingsCloudApiSaved,
    required this.settingsCloudApiInfo,
    required this.settingsCloudVoiceSelect,
    required this.settingsCloudVoiceQualityDesc,
    required this.levelTestTitle,
    required this.levelTestPreparing,
    required this.levelTestCurrentLevel,
    required this.levelTestNext,
    required this.levelTestResult,
    required this.levelTestComplete,
    required this.levelTestRecommended,
    required this.levelTestAccuracy,
    required this.levelTestLevelAccuracy,
    required this.levelTestRetry,
    required this.levelTestHome,
    required this.profileTitle,
    required this.profileLearner,
    required this.profileSummary,
    required this.profileTodayStudy,
    required this.profileTotalStudy,
    required this.profileTodayQuiz,
    required this.profileTotalQuiz,
    required this.profileAccuracy,
    required this.profileStreak,
    required this.profileWrongNote,
    required this.profileTotalSessions,
    required this.profileBadges,
    required this.profileActivityChart,
    required this.profileNoActivity,
    required this.profileQuizStats,
    required this.profileAvgAccuracy,
    required this.profileWord,
    required this.profileSentence,
    required this.profileQuiz,
    required this.profileTimesUnit,
    required this.profileDaysUnit,
    required this.profileItemsUnit,
    required this.profileBadgeNames,
    required this.profileBadgeDescs,
    required this.statsTitle,
    required this.statsWeekly,
    required this.statsMonthly,
    required this.statsDailyChart,
    required this.statsNoStudy,
    required this.statsAccuracyChart,
    required this.statsNoQuiz,
    required this.statsLevelStats,
    required this.weekdays,
    required this.rankingTitle,
    required this.rankingNoData,
    required this.rankingQuizCount,
    required this.rankingBestScore,
    required this.wrongTitle,
    required this.wrongAll,
    required this.wrongWord,
    required this.wrongSentence,
    required this.wrongEmpty,
    required this.wrongEmptyDesc,
    required this.wrongCount,
    required this.wrongRetry,
    required this.historyTitle,
    required this.historyEmpty,
    required this.historyEmptyDesc,
    required this.historyDelete,
    required this.historyDeleteConfirm,
    required this.historyCancel,
    required this.historyConfirmDelete,
    required this.historyDetailTitle,
    required this.historyDetailAccuracy,
    required this.historyDetailStudyAgain,
  }) : _streakDays = streakDays;

  static AppStrings of(BuildContext context) {
    final lang = context.watch<TtsSettingsProvider>().displayLanguage;
    return lang == 'en' ? _en : _ko;
  }

  static AppStrings get(String lang) => lang == 'en' ? _en : _ko;

  static final _ko = AppStrings(
    appSubtitle: '일본어 학습',
    streakStart: '오늘 첫 학습을 시작해보세요!',
    streakDays: (n) => '$n일 연속 학습!',
    streakCongrats: '축하합니다!',
    streakAchieved: (n) => '$n일 연속 학습 달성!',
    streakMessages: {
      3: '좋은 시작이에요! 꾸준히 해봐요!',
      7: '일주일 연속! 대단해요!',
      14: '2주 연속 학습! 습관이 되어가고 있어요!',
      30: '한 달 연속! 정말 대단합니다!',
      50: '50일 돌파! 일본어 마스터에 가까워지고 있어요!',
      100: '100일 달성! 당신은 진정한 학습왕입니다!',
    },
    streakConfirm: '확인',
    tickerTodayStudy: '오늘 학습',
    tickerTotalStudy: '누적 학습',
    tickerTodayQuiz: '오늘 퀴즈',
    tickerTotalQuiz: '누적 퀴즈',
    tickerAccuracy: '퀴즈 정답률',
    tickerWrongNote: '오답 노트',
    menu0Title: '0단계: 음절 공부하기',
    menu0Subtitle: '히라가나 / 가타카나 학습',
    menu1Title: '1단계: 단어 외우기',
    menu1Subtitle: '레벨별 단어 학습 (20개)',
    menu2Title: '2단계: 문장 외우기',
    menu2Subtitle: '레벨/카테고리별 문장 학습 (20개)',
    menu3Title: '3단계: 단어/문장 퀴즈',
    menu3Subtitle: '4지선다 (단어/문장)',
    menu4Title: '4단계: 라디오 듣기',
    menu4Subtitle: '자동 반복 재생 (단어/문장)',
    kanaSelectType: '음절 유형 선택',
    kanaHiragana: '히라가나 (ひらがな)',
    kanaHiraganaDesc: '기본 일본어 음절 46자 + 탁음/반탁음',
    kanaKatakana: '가타카나 (カタカナ)',
    kanaKatakanaDesc: '외래어 표기 음절 46자 + 탁음/반탁음',
    kanaBoth: '함께 공부하기',
    kanaBothDesc: '같은 음절 별 히라가나+가타카나 나란히 써보기',
    kanaModeTitle: '학습 모드',
    kanaModeStudy: '공부하기',
    kanaModeStudyDesc: '음절표를 보면서 발음 익히기',
    kanaModeWrite: '써보기',
    kanaModeWriteDesc: '청음 46자를 손가락으로 따라 써보기',
    kanaModeWriteBlind: '써보기 (발음만)',
    kanaModeWriteBlindDesc: '글자를 가리고 소리만 듣고 써보기',
    kanaOrderTitle: '연습 순서',
    kanaOrderSequential: '순서대로 써보기',
    kanaOrderRandom: '랜덤으로 써보기',
    kanaCountLabel: '청음 46자',
    kanaBothCountLabel: '46음절 (히라가나+가타카나 함께)',
    wordModeTitle: '1단계: 단어 외우기',
    wordModeStudy: '단어 공부하기',
    wordModeStudyDesc: '단어 카드를 넘기며 암기',
    wordModeWrite: '단어 써보기',
    wordModeWriteDesc: 'ML Kit으로 필기 인식 (한자 포함)',
    wordLevelTitle: '단어 레벨 선택',
    sentenceLevelTitle: '문장 레벨 선택',
    sentenceCategoryAll: '전체 카테고리',
    sentenceCategoryAllDesc: (level) => '$level 레벨 전체에서 랜덤 20개',
    sentenceCategoryDesc: (level, cat) => '$level / $cat 문장 학습',
    levelRandom: '전체 랜덤',
    levelRandomDesc: '모든 레벨에서 랜덤 20개',
    levelDesc: (n, label) => '$n 레벨 단어 20개',
    n5Label: 'N5 (초급)',
    n4Label: 'N4 (중급)',
    n3Label: 'N3 (상급)',
    n2Label: 'N2 (상상급)',
    n1Label: 'N1 (최상급)',
    quizSelectType: '퀴즈 유형 선택',
    quizHiragana: '히라가나 퀴즈',
    quizHiraganaDesc: '히라가나 → 한글 발음 맞추기',
    quizKatakana: '가타카나 퀴즈',
    quizKatakanaDesc: '가타카나 → 한글 발음 맞추기',
    quizWord: '단어 퀴즈',
    quizWordDesc: '일본어 단어 → 한국어 뜻 맞추기',
    quizSentence: '문장 퀴즈',
    quizSentenceDesc: '일본어 문장 → 한국어 해석 맞추기',
    quizDifficultyTitle: (type) => '${type == 'word' ? '단어' : '문장'} 퀴즈 — 난이도 선택',
    radioSelectMode: '라디오 모드 선택',
    radioWord: '단어 라디오',
    radioWordDesc: '단어를 자동으로 반복 재생',
    radioSentence: '문장 라디오',
    radioSentenceDesc: '문장을 자동으로 반복 재생',
    radioLevelTitle: (mode) => '${mode == 'word' ? '단어' : '문장'} 라디오 — 레벨 선택',
    drawerLevelTest: '레벨 테스트',
    drawerLevelTestSub: '내 JLPT 레벨 측정하기',
    drawerProfile: '내 프로필',
    drawerStats: '학습 통계',
    drawerRanking: '랭킹',
    drawerWrongNote: '오답 노트',
    drawerHistory: '공부한 내역 확인하기',
    drawerSettings: '설정',
    drawerLogout: '로그아웃',
    logoutTitle: '로그아웃',
    logoutContent: '로그아웃 하시겠습니까?',
    logoutCancel: '취소',
    logoutConfirm: '로그아웃',
    settingsTitle: '설정',
    settingsLangSection: '번역 언어',
    settingsLangDesc: '단어/문장 의미 표시 언어 (영어 데이터 없으면 한국어로 표시)',
    settingsThemeSection: '앱 테마',
    settingsThemeDesc: '홈 화면 색상 테마를 선택하세요',
    settingsThemeNames: ['보라', '파랑', '청록', '장미', '주황'],
    settingsQuizCountSection: '퀴즈 문항 수',
    settingsQuizCountDesc: '퀴즈 한 회차에 출제되는 문제 수',
    settingsQuizCountUnit: '개',
    settingsAutoTtsSection: '퀴즈 자동 음성',
    settingsAutoTtsDesc: '퀴즈 문제가 나올 때 자동으로 음성을 재생합니다',
    settingsAutoTtsOn: '자동 재생 켜짐',
    settingsAutoTtsOff: '자동 재생 꺼짐',
    settingsAutoTtsOnDesc: '문제마다 음성이 먼저 나옵니다',
    settingsAutoTtsOffDesc: '음성 없이 문장을 읽고 풀 수 있습니다',
    settingsTtsEngineSection: 'TTS 엔진',
    settingsEngineDevice: '기기 TTS',
    settingsEngineDeviceSub: '무료 / 오프라인',
    settingsEngineCloudSub: '고품질 / API 키',
    settingsSpeechRateSection: '말하기 속도',
    settingsPitchSection: '음높이 (피치)',
    settingsSpeedLabels: ['매우 느리게', '느리게', '보통', '빠르게', '매우 빠르게'],
    settingsPitchLabels: ['매우 낮게', '낮게', '보통', '높게', '매우 높게'],
    settingsSliderSlow: '느리게',
    settingsSliderNormal: '보통',
    settingsSliderFast: '빠르게',
    settingsSliderLow: '낮게',
    settingsSliderHigh: '높게',
    settingsTtsTest: '음성 테스트',
    settingsDataSection: '데이터 관리',
    settingsResetBtn: '모든 학습 초기화',
    settingsResetWarning: '학습 기록, 퀴즈 결과, 랭킹 통계가 모두 삭제됩니다.',
    settingsResetDialogTitle: '모든 학습 초기화',
    settingsResetDialogContent: '학습 기록, 퀴즈 결과, 랭킹 통계가 모두 삭제됩니다.\n\n이 작업은 되돌릴 수 없습니다. 정말 초기화하시겠습니까?',
    settingsResetCancel: '취소',
    settingsResetConfirm: '초기화',
    settingsResetSuccess: '모든 학습 기록이 초기화되었습니다.',
    settingsVoiceGender: '음성 성별',
    settingsGenderFemale: '여성',
    settingsGenderMale: '남성',
    settingsDeviceVoiceSelect: '음성 직접 선택',
    settingsDeviceVoiceDesc: '기기에 설치된 일본어 음성',
    settingsDeviceVoiceNone: '일본어 음성이 없습니다.\n폰 설정 → 일반 관리 → TTS → Google TTS 설정\n→ 일본어 음성 데이터 다운로드',
    settingsCloudApiKey: 'Google Cloud API 키',
    settingsCloudApiHint: 'API 키를 입력하세요',
    settingsCloudApiSaved: 'API 키가 저장되었습니다',
    settingsCloudApiInfo: 'Google Cloud Console → API 및 서비스 → 사용자 인증 정보\n→ API 키 생성 → Cloud Text-to-Speech API 활성화',
    settingsCloudVoiceSelect: '음성 선택',
    settingsCloudVoiceQualityDesc: 'Neural2 > WaveNet > Standard 순으로 고품질',
    levelTestTitle: '레벨 테스트',
    levelTestPreparing: '문제를 준비하는 중...',
    levelTestCurrentLevel: (level) => '현재 레벨: $level',
    levelTestNext: '다음 문제',
    levelTestResult: '결과 보기',
    levelTestComplete: '레벨 테스트 완료!',
    levelTestRecommended: '추천 레벨',
    levelTestAccuracy: (pct, correct, total) => '총 정답률: $pct% ($correct/$total)',
    levelTestLevelAccuracy: '레벨별 정답률',
    levelTestRetry: '다시 테스트하기',
    levelTestHome: '홈으로 돌아가기',
    profileTitle: '내 프로필',
    profileLearner: '학습자',
    profileSummary: '학습 요약',
    profileTodayStudy: '오늘 학습',
    profileTotalStudy: '누적 학습',
    profileTodayQuiz: '오늘 퀴즈',
    profileTotalQuiz: '누적 퀴즈',
    profileAccuracy: '퀴즈 정답률',
    profileStreak: '연속 학습',
    profileWrongNote: '오답 노트',
    profileTotalSessions: '총 세션',
    profileBadges: '획득한 배지',
    profileActivityChart: '학습 활동 (30일 전 ~ 10일 후)',
    profileNoActivity: '활동 없음',
    profileQuizStats: '난이도별 퀴즈 통계',
    profileAvgAccuracy: '평균 정답률',
    profileWord: '단어',
    profileSentence: '문장',
    profileQuiz: '퀴즈',
    profileTimesUnit: '회',
    profileDaysUnit: '일',
    profileItemsUnit: '개',
    profileBadgeNames: [
      '첫 불꽃', '3일 연속', '일주일 전사', '한 달 챔피언',
      '첫 발걸음', '단어 탐험가', '문장 탐구자', '학습 고수',
      '첫 퀴즈', '퀴즈 달인', '정확도 우수', '퀴즈 마스터',
      '10회 달성', '50회 달성', '100회 달성', '학습왕',
    ],
    profileBadgeDescs: [
      '연속 1일 학습', '3일 연속 학습', '7일 연속 학습', '30일 연속 학습',
      '학습 1회 완료', '단어 학습 10회', '문장 학습 10회', '총 50세션 달성',
      '퀴즈 1회 도전', '퀴즈 20회 도전', '정답률 80%+ (5회↑)', '정답률 90%+ (10회↑)',
      '총 10세션 완료', '총 50세션 완료', '총 100세션 완료', '총 200세션 완료',
    ],
    statsTitle: '학습 통계',
    statsWeekly: '주간',
    statsMonthly: '월간',
    statsDailyChart: '일별 학습량',
    statsNoStudy: '학습 기록이 없습니다',
    statsAccuracyChart: '퀴즈 정답률 추이',
    statsNoQuiz: '퀴즈 기록이 없습니다',
    statsLevelStats: '난이도별 퀴즈 성적',
    weekdays: ['월', '화', '수', '목', '금', '토', '일'],
    rankingTitle: '랭킹',
    rankingNoData: '아직 퀴즈 기록이 없습니다.',
    rankingQuizCount: (n) => '퀴즈 $n회',
    rankingBestScore: '최고점수',
    wrongTitle: '오답 노트',
    wrongAll: '전체',
    wrongWord: '단어',
    wrongSentence: '문장',
    wrongEmpty: '오답이 없습니다!',
    wrongEmptyDesc: '퀴즈를 풀면 틀린 문제가 여기에 표시됩니다',
    wrongCount: (n) => '총 $n개의 오답',
    wrongRetry: '오답 재도전',
    historyTitle: '공부한 내역',
    historyEmpty: '아직 공부한 내역이 없습니다',
    historyEmptyDesc: '학습이나 퀴즈를 완료하면 여기에 기록됩니다',
    historyDelete: '내역 삭제',
    historyDeleteConfirm: '모든 공부 내역을 삭제하시겠습니까?',
    historyCancel: '취소',
    historyConfirmDelete: '삭제',
    historyDetailTitle: '학습 내용',
    historyDetailAccuracy: (pct) => '정답률: $pct%',
    historyDetailStudyAgain: '다시 공부하기',
  );

  static final _en = AppStrings(
    appSubtitle: 'Japanese Learning',
    streakStart: 'Start your first study today!',
    streakDays: (n) => '$n day streak!',
    streakCongrats: 'Congratulations!',
    streakAchieved: (n) => '$n day streak achieved!',
    streakMessages: {
      3: 'Great start! Keep it up!',
      7: 'One week streak! Amazing!',
      14: '2 weeks straight! It\'s becoming a habit!',
      30: 'One month streak! Incredible!',
      50: '50 days! You\'re getting close to mastering Japanese!',
      100: '100 days! You are a true study champion!',
    },
    streakConfirm: 'OK',
    tickerTodayStudy: 'Today\'s study',
    tickerTotalStudy: 'Total study',
    tickerTodayQuiz: 'Today\'s quiz',
    tickerTotalQuiz: 'Total quiz',
    tickerAccuracy: 'Quiz accuracy',
    tickerWrongNote: 'Wrong answers',
    menu0Title: 'Step 0: Syllables',
    menu0Subtitle: 'Hiragana / Katakana study',
    menu1Title: 'Step 1: Vocabulary',
    menu1Subtitle: 'Level-based word study (20 words)',
    menu2Title: 'Step 2: Sentences',
    menu2Subtitle: 'Level/category sentence study (20)',
    menu3Title: 'Step 3: Quiz',
    menu3Subtitle: '4-choice quiz (words/sentences)',
    menu4Title: 'Step 4: Radio',
    menu4Subtitle: 'Auto repeat playback (words/sentences)',
    kanaSelectType: 'Select Syllable Type',
    kanaHiragana: 'Hiragana (ひらがな)',
    kanaHiraganaDesc: 'Basic Japanese syllabary 46 + dakuten/handakuten',
    kanaKatakana: 'Katakana (カタカナ)',
    kanaKatakanaDesc: 'Foreign word syllabary 46 + dakuten/handakuten',
    kanaBoth: 'Study Together',
    kanaBothDesc: 'Hiragana + Katakana side by side',
    kanaModeTitle: 'Study Mode',
    kanaModeStudy: 'Study',
    kanaModeStudyDesc: 'Learn pronunciation with syllable chart',
    kanaModeWrite: 'Write',
    kanaModeWriteDesc: 'Practice writing 46 basic characters',
    kanaModeWriteBlind: 'Write (sound only)',
    kanaModeWriteBlindDesc: 'Write by listening without seeing the character',
    kanaOrderTitle: 'Practice Order',
    kanaOrderSequential: 'Sequential',
    kanaOrderRandom: 'Random',
    kanaCountLabel: '46 basic characters',
    kanaBothCountLabel: '46 syllables (Hiragana + Katakana)',
    wordModeTitle: 'Step 1: Vocabulary',
    wordModeStudy: 'Study Words',
    wordModeStudyDesc: 'Memorize with flashcards',
    wordModeWrite: 'Write Words',
    wordModeWriteDesc: 'Handwriting recognition with ML Kit',
    wordLevelTitle: 'Select Word Level',
    sentenceLevelTitle: 'Select Sentence Level',
    sentenceCategoryAll: 'All Categories',
    sentenceCategoryAllDesc: (level) => 'Random 20 from all $level sentences',
    sentenceCategoryDesc: (level, cat) => '$level / $cat sentence study',
    levelRandom: 'All Random',
    levelRandomDesc: 'Random 20 from all levels',
    levelDesc: (n, label) => '$n level — 20 words',
    n5Label: 'N5 (Beginner)',
    n4Label: 'N4 (Elementary)',
    n3Label: 'N3 (Intermediate)',
    n2Label: 'N2 (Advanced)',
    n1Label: 'N1 (Expert)',
    quizSelectType: 'Select Quiz Type',
    quizHiragana: 'Hiragana Quiz',
    quizHiraganaDesc: 'Hiragana → match the reading',
    quizKatakana: 'Katakana Quiz',
    quizKatakanaDesc: 'Katakana → match the reading',
    quizWord: 'Word Quiz',
    quizWordDesc: 'Japanese word → match the meaning',
    quizSentence: 'Sentence Quiz',
    quizSentenceDesc: 'Japanese sentence → match the translation',
    quizDifficultyTitle: (type) => '${type == 'word' ? 'Word' : 'Sentence'} Quiz — Select Difficulty',
    radioSelectMode: 'Select Radio Mode',
    radioWord: 'Word Radio',
    radioWordDesc: 'Auto repeat word playback',
    radioSentence: 'Sentence Radio',
    radioSentenceDesc: 'Auto repeat sentence playback',
    radioLevelTitle: (mode) => '${mode == 'word' ? 'Word' : 'Sentence'} Radio — Select Level',
    drawerLevelTest: 'Level Test',
    drawerLevelTestSub: 'Measure my JLPT level',
    drawerProfile: 'My Profile',
    drawerStats: 'Study Stats',
    drawerRanking: 'Ranking',
    drawerWrongNote: 'Wrong Answers',
    drawerHistory: 'Study History',
    drawerSettings: 'Settings',
    drawerLogout: 'Log out',
    logoutTitle: 'Log out',
    logoutContent: 'Are you sure you want to log out?',
    logoutCancel: 'Cancel',
    logoutConfirm: 'Log out',
    settingsTitle: 'Settings',
    settingsLangSection: 'Display Language',
    settingsLangDesc: 'Language for word/sentence meanings (falls back to Korean if no English data)',
    levelTestTitle: 'Level Test',
    levelTestPreparing: 'Preparing questions...',
    levelTestCurrentLevel: (level) => 'Current Level: $level',
    levelTestNext: 'Next',
    levelTestResult: 'See Results',
    levelTestComplete: 'Level Test Complete!',
    levelTestRecommended: 'Recommended Level',
    levelTestAccuracy: (pct, correct, total) => 'Total Accuracy: $pct% ($correct/$total)',
    levelTestLevelAccuracy: 'Accuracy by Level',
    levelTestRetry: 'Retry Test',
    levelTestHome: 'Back to Home',
    profileTitle: 'My Profile',
    profileLearner: 'Learner',
    profileSummary: 'Study Summary',
    profileTodayStudy: 'Today\'s Study',
    profileTotalStudy: 'Total Study',
    profileTodayQuiz: 'Today\'s Quiz',
    profileTotalQuiz: 'Total Quiz',
    profileAccuracy: 'Quiz Accuracy',
    profileStreak: 'Streak',
    profileWrongNote: 'Wrong Answers',
    profileTotalSessions: 'Total Sessions',
    profileBadges: 'Earned Badges',
    profileActivityChart: 'Activity (30 days ago ~ 10 days ahead)',
    profileNoActivity: 'No activity',
    profileQuizStats: 'Quiz Stats by Level',
    profileAvgAccuracy: 'Avg Accuracy',
    profileWord: 'Word',
    profileSentence: 'Sentence',
    profileQuiz: 'Quiz',
    profileTimesUnit: 'x',
    profileDaysUnit: 'd',
    profileItemsUnit: '',
    profileBadgeNames: [
      'First Flame', '3-Day Streak', 'Week Warrior', 'Month Champion',
      'First Step', 'Word Explorer', 'Sentence Seeker', 'Study Master',
      'First Quiz', 'Quiz Ace', 'High Accuracy', 'Quiz Master',
      '10 Sessions', '50 Sessions', '100 Sessions', 'Learning King',
    ],
    profileBadgeDescs: [
      '1-day streak', '3-day streak', '7-day streak', '30-day streak',
      'Complete 1 session', 'Word study 10 times', 'Sentence study 10 times', '50 total sessions',
      'Take 1 quiz', 'Take 20 quizzes', '80%+ accuracy (5+ quizzes)', '90%+ accuracy (10+ quizzes)',
      'Complete 10 sessions', 'Complete 50 sessions', 'Complete 100 sessions', 'Complete 200 sessions',
    ],
    statsTitle: 'Study Stats',
    statsWeekly: 'Weekly',
    statsMonthly: 'Monthly',
    statsDailyChart: 'Daily Study',
    statsNoStudy: 'No study records yet',
    statsAccuracyChart: 'Quiz Accuracy Trend',
    statsNoQuiz: 'No quiz records yet',
    statsLevelStats: 'Quiz Stats by Level',
    weekdays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    rankingTitle: 'Ranking',
    rankingNoData: 'No quiz records yet.',
    rankingQuizCount: (n) => '$n quizzes',
    rankingBestScore: 'Best Score',
    wrongTitle: 'Wrong Answers',
    wrongAll: 'All',
    wrongWord: 'Word',
    wrongSentence: 'Sentence',
    wrongEmpty: 'No wrong answers!',
    wrongEmptyDesc: 'Wrong answers from quizzes will appear here',
    wrongCount: (n) => '$n wrong answers',
    wrongRetry: 'Retry Wrong Answers',
    historyTitle: 'Study History',
    historyEmpty: 'No study history yet',
    historyEmptyDesc: 'Completed studies and quizzes will be recorded here',
    historyDelete: 'Delete History',
    historyDeleteConfirm: 'Delete all study history?',
    historyCancel: 'Cancel',
    historyConfirmDelete: 'Delete',
    historyDetailTitle: 'Study Details',
    historyDetailAccuracy: (pct) => 'Accuracy: $pct%',
    historyDetailStudyAgain: 'Study Again',
  );
}
