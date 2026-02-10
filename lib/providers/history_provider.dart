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
