import 'package:flutter/foundation.dart';
import '../models/word.dart';
import '../models/study_record.dart';
import '../services/word_service.dart';
import '../services/tts_service.dart';
import 'tts_settings_provider.dart';

class WordProvider extends ChangeNotifier {
  final WordService _wordService = WordService();
  final TtsService _ttsService = TtsService();
  TtsService get ttsService => _ttsService;

  void updateTtsSettings(TtsSettingsProvider settings) {
    _ttsService.applySettings(settings);
  }

  List<Word> _studyWords = [];
  int _currentIndex = 0;
  bool _showAnswer = false;
  bool _isLoading = false;
  bool _isCompleted = false;

  List<Word> get studyWords => _studyWords;
  int get currentIndex => _currentIndex;
  bool get showAnswer => _showAnswer;
  bool get isLoading => _isLoading;
  bool get isCompleted => _isCompleted;
  Word? get currentWord =>
      _studyWords.isNotEmpty && _currentIndex < _studyWords.length
          ? _studyWords[_currentIndex]
          : null;
  int get totalCount => _studyWords.length;
  String get progressText => '${_currentIndex + 1} / $totalCount';

  Future<void> startTest({String? level}) async {
    _isLoading = true;
    notifyListeners();

    await _wordService.loadWords();
    if (level != null) {
      _studyWords = _wordService.getRandomWordsByLevelOnly(level, 20);
    } else {
      _studyWords = _wordService.getRandomWords(20);
    }
    _currentIndex = 0;
    _showAnswer = false;
    _isCompleted = false;
    _isLoading = false;
    notifyListeners();

    if (_studyWords.isNotEmpty) {
      await _ttsService.speakJapanese(_studyWords[0].reading);
    }
  }

  Future<void> revealAnswer() async {
    if (_showAnswer || _isCompleted) return;
    _showAnswer = true;
    notifyListeners();

    if (currentWord != null) {
      await _ttsService.speakJapanese(currentWord!.reading);
    }
  }

  StudyRecord buildRecord() {
    return StudyRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      type: 'word',
      totalCount: _studyWords.length,
      items: _studyWords
          .map((w) => StudyItem(
                japanese: w.japanese,
                reading: w.reading,
                korean: w.korean,
              ))
          .toList(),
    );
  }

  Future<void> nextWord() async {
    if (_currentIndex >= _studyWords.length - 1) {
      _isCompleted = true;
      notifyListeners();
      return;
    }

    _currentIndex++;
    _showAnswer = false;
    notifyListeners();

    await _ttsService.speakJapanese(_studyWords[_currentIndex].reading);
  }

  Future<void> previousWord() async {
    if (_currentIndex <= 0) return;

    _currentIndex--;
    _showAnswer = false;
    notifyListeners();

    await _ttsService.speakJapanese(_studyWords[_currentIndex].reading);
  }

  Future<void> replayTts() async {
    if (currentWord == null) return;
    await _ttsService.speakJapanese(currentWord!.reading);
  }

  void reset() {
    _studyWords = [];
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
