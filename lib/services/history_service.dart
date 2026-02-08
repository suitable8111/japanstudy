import 'package:shared_preferences/shared_preferences.dart';
import '../models/study_record.dart';

class HistoryService {
  static const String _key = 'study_history';

  Future<List<StudyRecord>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    return StudyRecord.decodeList(jsonStr);
  }

  Future<void> saveRecord(StudyRecord record) async {
    final records = await loadHistory();
    records.insert(0, record); // 최신순
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, StudyRecord.encodeList(records));
  }

  Future<void> deleteRecord(String id) async {
    final records = await loadHistory();
    records.removeWhere((r) => r.id == id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, StudyRecord.encodeList(records));
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
