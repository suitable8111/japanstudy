import 'package:flutter/foundation.dart';
import '../models/study_record.dart';
import '../services/history_service.dart';

class HistoryProvider extends ChangeNotifier {
  final HistoryService _historyService = HistoryService();
  List<StudyRecord> _records = [];
  bool _isLoading = false;

  List<StudyRecord> get records => _records;
  bool get isLoading => _isLoading;

  int get totalStudySessions => _records.length;
  int get wordStudyCount =>
      _records.where((r) => r.type == 'word').length;
  int get sentenceStudyCount =>
      _records.where((r) => r.type == 'sentence').length;
  int get quizCount =>
      _records.where((r) => r.type.startsWith('quiz')).length;

  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();

    _records = await _historyService.loadHistory();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addRecord(StudyRecord record) async {
    await _historyService.saveRecord(record);
    _records.insert(0, record);
    notifyListeners();
  }

  Future<void> deleteRecord(String id) async {
    await _historyService.deleteRecord(id);
    _records.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await _historyService.clearHistory();
    _records.clear();
    notifyListeners();
  }
}
