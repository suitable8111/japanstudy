import 'package:flutter/foundation.dart';
import '../models/kana.dart';
import '../models/study_record.dart';
import '../services/kana_service.dart';
import '../services/tts_service.dart';
import 'tts_settings_provider.dart';

class KanaProvider extends ChangeNotifier {
  final KanaService _kanaService = KanaService();
  final TtsService _ttsService = TtsService();
  TtsService get ttsService => _ttsService;

  void updateTtsSettings(TtsSettingsProvider settings) {
    _ttsService.applySettings(settings);
  }

  List<Kana> _studyKana = [];
  int _currentIndex = 0;
  bool _showAnswer = false;
  bool _isLoading = false;
  bool _isCompleted = false;
  String _kanaType = 'hiragana';

  List<Kana> get studyKana => _studyKana;
  int get currentIndex => _currentIndex;
  bool get showAnswer => _showAnswer;
  bool get isLoading => _isLoading;
  bool get isCompleted => _isCompleted;
  String get kanaType => _kanaType;
  Kana? get currentKana =>
      _studyKana.isNotEmpty && _currentIndex < _studyKana.length
          ? _studyKana[_currentIndex]
          : null;
  int get totalCount => _studyKana.length;
  String get progressText => '${_currentIndex + 1} / $totalCount';

  Future<void> startStudy(String type) async {
    _kanaType = type;
    _isLoading = true;
    notifyListeners();

    await _kanaService.loadKana();
    _studyKana = _kanaService.getKanaByType(type);
    _currentIndex = 0;
    _showAnswer = false;
    _isCompleted = false;
    _isLoading = false;
    notifyListeners();

    if (_studyKana.isNotEmpty) {
      await _ttsService.speakJapanese(_studyKana[0].japanese);
    }
  }

  Future<void> revealAnswer() async {
    if (_showAnswer || _isCompleted) return;
    _showAnswer = true;
    notifyListeners();

    if (currentKana != null) {
      await _ttsService.speakJapanese(currentKana!.japanese);
    }
  }

  StudyRecord buildRecord() {
    return StudyRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      type: 'kana_$_kanaType',
      totalCount: _studyKana.length,
      items: _studyKana
          .map((k) => StudyItem(
                japanese: k.japanese,
                reading: k.reading,
                korean: k.korean,
              ))
          .toList(),
    );
  }

  Future<void> nextKana() async {
    if (_currentIndex >= _studyKana.length - 1) {
      _isCompleted = true;
      notifyListeners();
      return;
    }

    _currentIndex++;
    _showAnswer = false;
    notifyListeners();

    await _ttsService.speakJapanese(_studyKana[_currentIndex].japanese);
  }

  Future<void> previousKana() async {
    if (_currentIndex <= 0) return;

    _currentIndex--;
    _showAnswer = false;
    notifyListeners();

    await _ttsService.speakJapanese(_studyKana[_currentIndex].japanese);
  }

  Future<void> replayTts() async {
    if (currentKana == null) return;
    await _ttsService.speakJapanese(currentKana!.japanese);
  }

  void reset() {
    _studyKana = [];
    _currentIndex = 0;
    _showAnswer = false;
    _isCompleted = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _ttsService.dispose();
    super.dispose();
  }
}
