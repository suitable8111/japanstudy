import 'package:flutter/foundation.dart';
import '../models/study_record.dart';
import '../services/firestore_service.dart';

class HistoryProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<StudyRecord> _records = [];
  bool _isLoading = false;
  String? _uid;

  List<StudyRecord> get records => _records;
  bool get isLoading => _isLoading;

  int get totalStudySessions => _records.length;
  int get wordStudyCount =>
      _records.where((r) => r.type == 'word').length;
  int get sentenceStudyCount =>
      _records.where((r) => r.type == 'sentence').length;
  int get quizCount =>
      _records.where((r) => r.type.startsWith('quiz')).length;

  /// 날짜별 학습 활동 (최근 30일)
  /// key: 'yyyy-MM-dd', value: 학습 타입 목록
  Map<String, List<String>> get studyActivityByDate {
    final now = DateTime.now();
    final cutoff = now.subtract(const Duration(days: 30));
    final result = <String, List<String>>{};

    for (final record in _records) {
      if (record.date.isBefore(cutoff)) continue;
      final dateKey =
          '${record.date.year}-${record.date.month.toString().padLeft(2, '0')}-${record.date.day.toString().padLeft(2, '0')}';
      result.putIfAbsent(dateKey, () => []);
      result[dateKey]!.add(record.type);
    }
    return result;
  }

  /// 날짜별 학습 카운트 (차트용)
  /// key: 'yyyy-MM-dd', value: {word, sentence, quiz} 카운트
  Map<String, Map<String, int>> studyCountByDate(int days) {
    final now = DateTime.now();
    final cutoff = now.subtract(Duration(days: days));
    final result = <String, Map<String, int>>{};

    // 기간 내 모든 날짜를 0으로 초기화
    for (var i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: days - 1 - i));
      final key =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      result[key] = {'word': 0, 'sentence': 0, 'quiz': 0};
    }

    for (final record in _records) {
      if (record.date.isBefore(cutoff)) continue;
      final dateKey =
          '${record.date.year}-${record.date.month.toString().padLeft(2, '0')}-${record.date.day.toString().padLeft(2, '0')}';
      if (!result.containsKey(dateKey)) continue;

      if (record.type == 'word' ||
          record.type == 'kana_hiragana' ||
          record.type == 'kana_katakana') {
        result[dateKey]!['word'] = result[dateKey]!['word']! + 1;
      } else if (record.type == 'sentence') {
        result[dateKey]!['sentence'] = result[dateKey]!['sentence']! + 1;
      } else if (record.type.startsWith('quiz')) {
        result[dateKey]!['quiz'] = result[dateKey]!['quiz']! + 1;
      }
    }
    return result;
  }

  /// 퀴즈 정답률 추이 (차트용)
  /// 날짜+정답률 리스트 (시간순)
  List<Map<String, dynamic>> quizAccuracyTrend(int days) {
    final now = DateTime.now();
    final cutoff = now.subtract(Duration(days: days));
    final result = <Map<String, dynamic>>[];

    // 날짜별 퀴즈 합산
    final byDate = <String, Map<String, int>>{};
    for (final record in _records) {
      if (!record.type.startsWith('quiz')) continue;
      if (record.date.isBefore(cutoff)) continue;
      if (record.correctCount == null) continue;

      final dateKey =
          '${record.date.year}-${record.date.month.toString().padLeft(2, '0')}-${record.date.day.toString().padLeft(2, '0')}';
      byDate.putIfAbsent(dateKey, () => {'correct': 0, 'total': 0});
      byDate[dateKey]!['correct'] =
          byDate[dateKey]!['correct']! + record.correctCount!;
      byDate[dateKey]!['total'] =
          byDate[dateKey]!['total']! + record.totalCount;
    }

    final sortedKeys = byDate.keys.toList()..sort();
    for (final key in sortedKeys) {
      final total = byDate[key]!['total']!;
      final correct = byDate[key]!['correct']!;
      result.add({
        'date': key,
        'rate': total > 0 ? (correct / total * 100) : 0.0,
      });
    }
    return result;
  }

  /// 난이도별 퀴즈 통계
  /// key: 'N5'/'N4'/'N3', value: { quizCount, totalCorrect, totalQuestions, avgRate }
  Map<String, Map<String, dynamic>> get quizStatsByDifficulty {
    final stats = <String, Map<String, dynamic>>{};
    for (final level in ['N5', 'N4', 'N3', 'N2', 'N1']) {
      stats[level] = {
        'quizCount': 0,
        'totalCorrect': 0,
        'totalQuestions': 0,
        'avgRate': 0.0,
      };
    }

    for (final record in _records) {
      if (!record.type.startsWith('quiz') || record.difficulty == null) continue;
      final level = record.difficulty!;
      if (!stats.containsKey(level)) continue;

      stats[level]!['quizCount'] = (stats[level]!['quizCount'] as int) + 1;
      stats[level]!['totalCorrect'] =
          (stats[level]!['totalCorrect'] as int) + (record.correctCount ?? 0);
      stats[level]!['totalQuestions'] =
          (stats[level]!['totalQuestions'] as int) + record.totalCount;
    }

    for (final level in ['N5', 'N4', 'N3', 'N2', 'N1']) {
      final total = stats[level]!['totalQuestions'] as int;
      final correct = stats[level]!['totalCorrect'] as int;
      stats[level]!['avgRate'] =
          total > 0 ? (correct / total * 100) : 0.0;
    }

    return stats;
  }

  /// 전체 퀴즈에서 틀린 StudyItem 목록 (japanese 기준 중복 제거, 최신 결과 우선)
  List<StudyItem> get wrongAnswerItems {
    final seen = <String>{};
    final result = <StudyItem>[];
    for (final record in _records) {
      if (!record.type.startsWith('quiz')) continue;
      for (final item in record.items) {
        if (item.isCorrect == false && !seen.contains(item.japanese)) {
          seen.add(item.japanese);
          result.add(item);
        }
      }
    }
    return result;
  }

  /// 퀴즈 유형별 오답 목록 ('word' or 'sentence')
  List<StudyItem> wrongAnswersByType(String type) {
    final quizType = 'quiz_$type';
    final seen = <String>{};
    final result = <StudyItem>[];
    for (final record in _records) {
      if (record.type != quizType) continue;
      for (final item in record.items) {
        if (item.isCorrect == false && !seen.contains(item.japanese)) {
          seen.add(item.japanese);
          result.add(item);
        }
      }
    }
    return result;
  }

  /// 총 고유 오답 수
  int get wrongAnswerCount => wrongAnswerItems.length;

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool _isStudyType(String type) =>
      type == 'word' || type == 'sentence';

  static bool _isQuizType(String type) =>
      type == 'quiz_word' || type == 'quiz_sentence';

  /// 오늘 학습 횟수 (단어+문장, 음절 제외)
  int get todayStudyCount =>
      _records.where((r) => _isStudyType(r.type) && _isToday(r.date)).length;

  /// 오늘 퀴즈 횟수 (단어+문장 퀴즈, 음절 퀴즈 제외)
  int get todayQuizCount =>
      _records.where((r) => _isQuizType(r.type) && _isToday(r.date)).length;

  /// 누적 학습 횟수 (단어+문장, 음절 제외)
  int get coreStudyCount =>
      _records.where((r) => _isStudyType(r.type)).length;

  /// 누적 퀴즈 횟수 (단어+문장 퀴즈, 음절 퀴즈 제외)
  int get coreQuizCount =>
      _records.where((r) => _isQuizType(r.type)).length;

  /// 오늘부터 연속 학습일 계산
  int get currentStreak {
    if (_records.isEmpty) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 날짜별로 학습 여부 Set 만들기
    final studiedDates = <DateTime>{};
    for (final record in _records) {
      studiedDates.add(DateTime(record.date.year, record.date.month, record.date.day));
    }

    // 오늘 또는 어제부터 시작해서 연속일 계산
    var checkDate = today;
    if (!studiedDates.contains(checkDate)) {
      checkDate = today.subtract(const Duration(days: 1));
      if (!studiedDates.contains(checkDate)) return 0;
    }

    int streak = 0;
    while (studiedDates.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// 전체 퀴즈 정답률 (%)
  double get overallQuizAccuracy {
    int totalCorrect = 0;
    int totalQuestions = 0;
    for (final record in _records) {
      if (!record.type.startsWith('quiz')) continue;
      if (record.correctCount == null) continue;
      totalCorrect += record.correctCount!;
      totalQuestions += record.totalCount;
    }
    if (totalQuestions == 0) return 0.0;
    return totalCorrect / totalQuestions * 100;
  }

  void setUid(String? uid) {
    if (_uid != uid) {
      _uid = uid;
      if (uid != null) {
        loadHistory();
      } else {
        _records = [];
        notifyListeners();
      }
    }
  }

  Future<void> loadHistory() async {
    if (_uid == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _records = await _firestoreService.getStudyRecords(_uid!);
    } catch (e) {
      debugPrint('Failed to load history: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addRecord(StudyRecord record) async {
    if (_uid == null) return;

    try {
      await _firestoreService.saveStudyRecord(_uid!, record);
      _records.insert(0, record);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to save record: $e');
    }
  }

  Future<void> deleteRecord(String id) async {
    if (_uid == null) return;

    try {
      await _firestoreService.deleteStudyRecord(_uid!, id);
      _records.removeWhere((r) => r.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to delete record: $e');
    }
  }

  Future<void> clearHistory() async {
    if (_uid == null) return;

    try {
      await _firestoreService.clearStudyRecords(_uid!);
      _records.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to clear history: $e');
    }
  }

  Future<void> clearAllData() async {
    if (_uid == null) return;

    try {
      await _firestoreService.clearStudyRecords(_uid!);
      await _firestoreService.clearUserStats(_uid!);
      _records.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to clear all data: $e');
    }
  }
}
