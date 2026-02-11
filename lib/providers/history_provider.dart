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

  /// 난이도별 퀴즈 통계
  /// key: 'N5'/'N4'/'N3', value: { quizCount, totalCorrect, totalQuestions, avgRate }
  Map<String, Map<String, dynamic>> get quizStatsByDifficulty {
    final stats = <String, Map<String, dynamic>>{};
    for (final level in ['N5', 'N4', 'N3']) {
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

    for (final level in ['N5', 'N4', 'N3']) {
      final total = stats[level]!['totalQuestions'] as int;
      final correct = stats[level]!['totalCorrect'] as int;
      stats[level]!['avgRate'] =
          total > 0 ? (correct / total * 100) : 0.0;
    }

    return stats;
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
}
