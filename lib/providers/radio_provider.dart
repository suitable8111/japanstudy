import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/word_service.dart';
import '../services/sentence_service.dart';
import '../services/tts_service.dart';
import 'tts_settings_provider.dart';

class RadioProvider extends ChangeNotifier {
  final WordService _wordService = WordService();
  final SentenceService _sentenceService = SentenceService();
  final TtsService _ttsService = TtsService();

  void updateTtsSettings(TtsSettingsProvider settings) {
    _ttsService.applySettings(settings);
  }

  // 아이템: {japanese, reading, korean}
  List<Map<String, String>> _items = [];
  int _currentIndex = 0;
  bool _isPlaying = false;
  bool _isPaused = false;
  bool _isLoading = false;
  bool _isCompleted = false;
  int _currentStep = 0; // 0: JP1, 1: KR, 2: JP2, 3: JP3
  String _mode = 'word';

  Completer<void>? _pauseCompleter;
  bool _stopRequested = false;

  List<Map<String, String>> get items => _items;
  int get currentIndex => _currentIndex;
  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  bool get isLoading => _isLoading;
  bool get isCompleted => _isCompleted;
  int get currentStep => _currentStep;
  String get mode => _mode;
  int get totalCount => _items.length;
  String get progressText => '${_currentIndex + 1} / $totalCount';
  Map<String, String>? get currentItem =>
      _items.isNotEmpty && _currentIndex < _items.length
          ? _items[_currentIndex]
          : null;

  String? _level;
  String? get level => _level;

  Future<void> startRadio(String mode, {String? level}) async {
    _mode = mode;
    _level = level;
    _isLoading = true;
    _stopRequested = false;
    notifyListeners();

    if (mode == 'word') {
      await _wordService.loadWords();
      final words = level != null
          ? _wordService.getRandomWordsByLevelOnly(level, 20)
          : _wordService.getRandomWords(20);
      _items = words
          .map((w) => {
                'japanese': w.japanese,
                'reading': w.reading,
                'korean': w.korean,
              })
          .toList();
    } else {
      await _sentenceService.loadSentences();
      final sentences = level != null
          ? _sentenceService.getRandomSentencesByCategory(level, null, 20)
          : _sentenceService.getRandomSentences(20);
      _items = sentences
          .map((s) => {
                'japanese': s.japanese,
                'reading': s.reading,
                'korean': s.korean,
              })
          .toList();
    }

    _currentIndex = 0;
    _currentStep = 0;
    _isPlaying = true;
    _isPaused = false;
    _isCompleted = false;
    _isLoading = false;
    notifyListeners();

    _playSequence();
  }

  Future<void> _playSequence() async {
    while (_currentIndex < _items.length && !_stopRequested) {
      final item = _items[_currentIndex];
      final speakText =
          _mode == 'word' ? item['reading']! : item['japanese']!;

      // Step 0: 일본어 1번째
      _currentStep = 0;
      notifyListeners();
      await _checkPause();
      if (_stopRequested) return;
      await _ttsService.speakJapanese(speakText);
      await _delayWithCheck(2000);
      if (_stopRequested) return;

      // Step 1: 한국어
      _currentStep = 1;
      notifyListeners();
      await _checkPause();
      if (_stopRequested) return;
      await _ttsService.speakKorean(item['korean']!);
      await _delayWithCheck(2000);
      if (_stopRequested) return;

      // Step 2: 일본어 2번째
      _currentStep = 2;
      notifyListeners();
      await _checkPause();
      if (_stopRequested) return;
      await _ttsService.speakJapanese(speakText);
      await _delayWithCheck(2000);
      if (_stopRequested) return;

      // Step 3: 일본어 3번째
      _currentStep = 3;
      notifyListeners();
      await _checkPause();
      if (_stopRequested) return;
      await _ttsService.speakJapanese(speakText);
      await _delayWithCheck(2000);
      if (_stopRequested) return;

      // 다음 아이템
      if (_currentIndex < _items.length - 1) {
        _currentIndex++;
        notifyListeners();
      } else {
        break;
      }
    }

    if (!_stopRequested) {
      _isPlaying = false;
      _isCompleted = true;
      notifyListeners();
    }
  }

  Future<void> _delayWithCheck(int milliseconds) async {
    const step = 100;
    var elapsed = 0;
    while (elapsed < milliseconds) {
      if (_stopRequested) return;
      await _checkPause();
      await Future.delayed(const Duration(milliseconds: 100));
      elapsed += step;
    }
  }

  Future<void> _checkPause() async {
    if (_isPaused) {
      _pauseCompleter = Completer<void>();
      await _pauseCompleter!.future;
      _pauseCompleter = null;
    }
  }

  void togglePause() {
    if (!_isPlaying || _isCompleted) return;

    _isPaused = !_isPaused;
    notifyListeners();

    if (!_isPaused && _pauseCompleter != null && !_pauseCompleter!.isCompleted) {
      _pauseCompleter!.complete();
    }
  }

  void skipNext() {
    if (!_isPlaying || _isCompleted) return;
    if (_currentIndex >= _items.length - 1) return;

    _ttsService.stop();
    _stopRequested = true;

    // 일시정지 해제
    if (_isPaused && _pauseCompleter != null && !_pauseCompleter!.isCompleted) {
      _pauseCompleter!.complete();
    }
    _isPaused = false;

    // 다음 아이템으로 이동 후 재시작
    _currentIndex++;
    _currentStep = 0;
    _stopRequested = false;
    notifyListeners();

    _playSequence();
  }

  void stop() {
    _stopRequested = true;
    _ttsService.stop();

    // 일시정지 해제
    if (_isPaused && _pauseCompleter != null && !_pauseCompleter!.isCompleted) {
      _pauseCompleter!.complete();
    }

    _isPlaying = false;
    _isPaused = false;
    _items = [];
    _currentIndex = 0;
    _currentStep = 0;
    _isCompleted = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopRequested = true;
    _ttsService.dispose();
    super.dispose();
  }
}
