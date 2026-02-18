import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/word.dart';
import '../services/word_service.dart';
import '../services/tts_service.dart';
import 'tts_settings_provider.dart';

class LevelTestQuestion {
  final String japanese;
  final String reading;
  final String correctAnswer;
  final List<String> choices;
  final String level;
  int? selectedIndex;

  LevelTestQuestion({
    required this.japanese,
    required this.reading,
    required this.correctAnswer,
    required this.choices,
    required this.level,
  });

  bool get isAnswered => selectedIndex != null;
  bool get isCorrect =>
      selectedIndex != null && choices[selectedIndex!] == correctAnswer;
}

class LevelTestProvider extends ChangeNotifier {
  final WordService _wordService = WordService();
  final TtsService _ttsService = TtsService();
  TtsService get ttsService => _ttsService;

  void updateTtsSettings(TtsSettingsProvider settings) {
    _ttsService.applySettings(settings);
  }

  static const List<String> _levels = ['N5', 'N4', 'N3', 'N2', 'N1'];
  static const int totalQuestions = 15;

  List<LevelTestQuestion> _questions = [];
  int _currentIndex = 0;
  bool _isLoading = false;
  bool _isCompleted = false;
  String _currentLevel = 'N5';
  List<Word> _allWords = [];

  List<LevelTestQuestion> get questions => _questions;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  bool get isCompleted => _isCompleted;
  String get currentLevel => _currentLevel;
  LevelTestQuestion? get currentQuestion =>
      _questions.isNotEmpty && _currentIndex < _questions.length
          ? _questions[_currentIndex]
          : null;
  int get totalCount => totalQuestions;
  String get progressText => '${_currentIndex + 1} / $totalCount';
  int get correctCount => _questions.where((q) => q.isCorrect).length;

  int _levelToIndex(String level) => _levels.indexOf(level);
  String _indexToLevel(int index) => _levels[index.clamp(0, _levels.length - 1)];

  Future<void> startLevelTest() async {
    _isLoading = true;
    _isCompleted = false;
    _currentIndex = 0;
    _currentLevel = 'N5';
    _questions = [];
    notifyListeners();

    await _wordService.loadWords();
    _allWords = _wordService.getAllWords();

    if (_allWords.length < 4) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _generateNextQuestion();

    _isLoading = false;
    notifyListeners();

    if (_questions.isNotEmpty) {
      await _ttsService.speakJapanese(_questions[0].reading);
    }
  }

  void _generateNextQuestion() {
    final random = Random();
    final levelWords =
        _allWords.where((w) => w.level == _currentLevel).toList();

    if (levelWords.isEmpty) return;

    levelWords.shuffle(random);
    final word = levelWords.first;

    final wrongAnswers = _allWords
        .where((w) => w.korean != word.korean)
        .map((w) => w.korean)
        .toSet()
        .toList()
      ..shuffle(random);

    final choices = [word.korean, ...wrongAnswers.take(3)];
    choices.shuffle(random);

    _questions.add(LevelTestQuestion(
      japanese: word.japanese,
      reading: word.reading,
      correctAnswer: word.korean,
      choices: choices,
      level: _currentLevel,
    ));
  }

  Future<void> selectAnswer(int choiceIndex) async {
    if (currentQuestion == null || currentQuestion!.isAnswered) return;

    currentQuestion!.selectedIndex = choiceIndex;
    notifyListeners();

    if (!currentQuestion!.isCorrect) {
      await _ttsService.speakJapanese(currentQuestion!.reading);
    }
  }

  Future<void> nextQuestion() async {
    if (_currentIndex >= totalQuestions - 1) {
      _isCompleted = true;
      notifyListeners();
      return;
    }

    // Adaptive logic: correct -> harder, wrong -> easier
    final currentLevelIndex = _levelToIndex(_currentLevel);
    if (currentQuestion != null && currentQuestion!.isCorrect) {
      _currentLevel = _indexToLevel(currentLevelIndex + 1);
    } else {
      _currentLevel = _indexToLevel(currentLevelIndex - 1);
    }

    _currentIndex++;
    _generateNextQuestion();
    notifyListeners();

    if (currentQuestion != null) {
      await _ttsService.speakJapanese(currentQuestion!.reading);
    }
  }

  String get recommendedLevel {
    if (_questions.isEmpty) return 'N5';

    // Find the highest level where user got at least one correct
    final correctByLevel = <String, int>{};
    final totalByLevel = <String, int>{};

    for (final q in _questions) {
      totalByLevel[q.level] = (totalByLevel[q.level] ?? 0) + 1;
      if (q.isCorrect) {
        correctByLevel[q.level] = (correctByLevel[q.level] ?? 0) + 1;
      }
    }

    // From hardest to easiest, find the highest level with >= 50% accuracy
    String recommended = 'N5';
    for (final level in _levels.reversed) {
      final total = totalByLevel[level] ?? 0;
      final correct = correctByLevel[level] ?? 0;
      if (total > 0 && correct / total >= 0.5) {
        recommended = level;
        break;
      }
    }

    return recommended;
  }

  Map<String, Map<String, int>> get levelStats {
    final stats = <String, Map<String, int>>{};
    for (final level in _levels) {
      stats[level] = {'correct': 0, 'total': 0};
    }
    for (final q in _questions) {
      stats[q.level]!['total'] = stats[q.level]!['total']! + 1;
      if (q.isCorrect) {
        stats[q.level]!['correct'] = stats[q.level]!['correct']! + 1;
      }
    }
    return stats;
  }

  void reset() {
    _questions = [];
    _currentIndex = 0;
    _isCompleted = false;
    _currentLevel = 'N5';
    notifyListeners();
  }

  @override
  void dispose() {
    _ttsService.dispose();
    super.dispose();
  }
}
