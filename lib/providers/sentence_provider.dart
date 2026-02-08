import 'package:flutter/foundation.dart';
import '../models/sentence.dart';
import '../models/study_record.dart';
import '../services/sentence_service.dart';
import '../services/tts_service.dart';
import 'tts_settings_provider.dart';

class SentenceProvider extends ChangeNotifier {
  final SentenceService _sentenceService = SentenceService();
  final TtsService _ttsService = TtsService();
  TtsService get ttsService => _ttsService;

  void updateTtsSettings(TtsSettingsProvider settings) {
    _ttsService.applySettings(settings);
  }

  List<Sentence> _studySentences = [];
  int _currentIndex = 0;
  bool _showAnswer = false;
  bool _isLoading = false;
  bool _isCompleted = false;

  List<Sentence> get studySentences => _studySentences;
  int get currentIndex => _currentIndex;
  bool get showAnswer => _showAnswer;
  bool get isLoading => _isLoading;
  bool get isCompleted => _isCompleted;
  Sentence? get currentSentence =>
      _studySentences.isNotEmpty && _currentIndex < _studySentences.length
          ? _studySentences[_currentIndex]
          : null;
  int get totalCount => _studySentences.length;
  String get progressText => '${_currentIndex + 1} / $totalCount';

  Future<void> startTest() async {
    _isLoading = true;
    notifyListeners();

    await _sentenceService.loadSentences();
    _studySentences = _sentenceService.getRandomSentences(20);
    _currentIndex = 0;
    _showAnswer = false;
    _isCompleted = false;
    _isLoading = false;
    notifyListeners();

    if (_studySentences.isNotEmpty) {
      await _ttsService.speakJapanese(_studySentences[0].japanese);
    }
  }

  Future<void> revealAnswer() async {
    if (_showAnswer || _isCompleted) return;
    _showAnswer = true;
    notifyListeners();

    if (currentSentence != null) {
      await _ttsService.speakJapanese(currentSentence!.japanese);
    }
  }

  StudyRecord buildRecord() {
    return StudyRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      type: 'sentence',
      totalCount: _studySentences.length,
      items: _studySentences
          .map((s) => StudyItem(
                japanese: s.japanese,
                reading: s.reading,
                korean: s.korean,
              ))
          .toList(),
    );
  }

  Future<void> nextSentence() async {
    if (_currentIndex >= _studySentences.length - 1) {
      _isCompleted = true;
      notifyListeners();
      return;
    }

    _currentIndex++;
    _showAnswer = false;
    notifyListeners();

    await _ttsService
        .speakJapanese(_studySentences[_currentIndex].japanese);
  }

  Future<void> previousSentence() async {
    if (_currentIndex <= 0) return;

    _currentIndex--;
    _showAnswer = false;
    notifyListeners();

    await _ttsService
        .speakJapanese(_studySentences[_currentIndex].japanese);
  }

  Future<void> replayTts() async {
    if (currentSentence == null) return;
    await _ttsService.speakJapanese(currentSentence!.japanese);
  }

  void reset() {
    _studySentences = [];
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
