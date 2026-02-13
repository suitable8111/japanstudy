import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/word.dart';
import '../models/sentence.dart';
import '../models/study_record.dart' show StudyRecord, StudyItem;
import '../services/word_service.dart';
import '../services/sentence_service.dart';
import '../services/tts_service.dart';
import 'tts_settings_provider.dart';

class QuizQuestion {
  final String japanese;
  final String reading;
  final String correctAnswer;
  final List<String> choices; // 4개 선택지 (정답 포함)
  int? selectedIndex;

  QuizQuestion({
    required this.japanese,
    required this.reading,
    required this.correctAnswer,
    required this.choices,
  });

  bool get isAnswered => selectedIndex != null;
  bool get isCorrect =>
      selectedIndex != null && choices[selectedIndex!] == correctAnswer;
  int get correctIndex => choices.indexOf(correctAnswer);
}

class QuizProvider extends ChangeNotifier {
  final WordService _wordService = WordService();
  final SentenceService _sentenceService = SentenceService();
  final TtsService _ttsService = TtsService();
  TtsService get ttsService => _ttsService;

  void updateTtsSettings(TtsSettingsProvider settings) {
    _ttsService.applySettings(settings);
  }

  String _quizType = 'word'; // 'word' or 'sentence'
  String? _difficulty; // 'N5', 'N4', 'N3'
  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  bool _isLoading = false;
  bool _isCompleted = false;

  String get quizType => _quizType;
  String? get difficulty => _difficulty;
  List<QuizQuestion> get questions => _questions;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  bool get isCompleted => _isCompleted;
  QuizQuestion? get currentQuestion =>
      _questions.isNotEmpty && _currentIndex < _questions.length
          ? _questions[_currentIndex]
          : null;
  int get totalCount => _questions.length;
  String get progressText => '${_currentIndex + 1} / $totalCount';
  int get correctCount => _questions.where((q) => q.isCorrect).length;

  Future<void> startQuiz(String type, {String? difficulty}) async {
    _quizType = type;
    _difficulty = difficulty;
    _isLoading = true;
    _isCompleted = false;
    _currentIndex = 0;
    _questions = [];
    notifyListeners();

    if (type == 'word') {
      if (difficulty != null) {
        await _generateWordQuizByLevel(difficulty);
      } else {
        await _generateWordQuiz();
      }
    } else {
      if (difficulty != null) {
        await _generateSentenceQuizByLevel(difficulty);
      } else {
        await _generateSentenceQuiz();
      }
    }

    _isLoading = false;
    notifyListeners();

    if (_questions.isNotEmpty) {
      await _ttsService.speakJapanese(
          type == 'word' ? _questions[0].reading : _questions[0].japanese);
    }
  }

  Future<void> _generateWordQuiz() async {
    await _wordService.loadWords();
    final allWords = _wordService.getRandomWords(1000); // 전체 가져오기
    if (allWords.length < 4) return;

    final random = Random();
    final selected = List<Word>.from(allWords)..shuffle(random);
    final quizWords = selected.take(20.clamp(0, selected.length)).toList();

    for (final word in quizWords) {
      final wrongAnswers = allWords
          .where((w) => w.korean != word.korean)
          .map((w) => w.korean)
          .toSet()
          .toList()
        ..shuffle(random);

      final choices = [word.korean, ...wrongAnswers.take(3)];
      choices.shuffle(random);

      _questions.add(QuizQuestion(
        japanese: word.japanese,
        reading: word.reading,
        correctAnswer: word.korean,
        choices: choices,
      ));
    }
  }

  Future<void> _generateSentenceQuiz() async {
    await _sentenceService.loadSentences();
    final allSentences =
        _sentenceService.getRandomSentences(1000); // 전체 가져오기
    if (allSentences.length < 4) return;

    final random = Random();
    final selected = List<Sentence>.from(allSentences)..shuffle(random);
    final quizSentences =
        selected.take(20.clamp(0, selected.length)).toList();

    for (final sentence in quizSentences) {
      final wrongAnswers = allSentences
          .where((s) => s.korean != sentence.korean)
          .map((s) => s.korean)
          .toSet()
          .toList()
        ..shuffle(random);

      final choices = [sentence.korean, ...wrongAnswers.take(3)];
      choices.shuffle(random);

      _questions.add(QuizQuestion(
        japanese: sentence.japanese,
        reading: sentence.reading,
        correctAnswer: sentence.korean,
        choices: choices,
      ));
    }
  }

  Future<void> _generateWordQuizByLevel(String level) async {
    await _wordService.loadWords();
    final allWords = _wordService.getRandomWords(1000);
    if (allWords.length < 4) return;

    final random = Random();
    final quizWords = _wordService.getRandomWordsByLevel(level);

    for (final word in quizWords) {
      final wrongAnswers = allWords
          .where((w) => w.korean != word.korean)
          .map((w) => w.korean)
          .toSet()
          .toList()
        ..shuffle(random);

      final choices = [word.korean, ...wrongAnswers.take(3)];
      choices.shuffle(random);

      _questions.add(QuizQuestion(
        japanese: word.japanese,
        reading: word.reading,
        correctAnswer: word.korean,
        choices: choices,
      ));
    }
  }

  Future<void> _generateSentenceQuizByLevel(String level) async {
    await _sentenceService.loadSentences();
    final allSentences = _sentenceService.getRandomSentences(1000);
    if (allSentences.length < 4) return;

    final random = Random();
    final quizSentences = _sentenceService.getRandomSentencesByLevel(level);

    for (final sentence in quizSentences) {
      final wrongAnswers = allSentences
          .where((s) => s.korean != sentence.korean)
          .map((s) => s.korean)
          .toSet()
          .toList()
        ..shuffle(random);

      final choices = [sentence.korean, ...wrongAnswers.take(3)];
      choices.shuffle(random);

      _questions.add(QuizQuestion(
        japanese: sentence.japanese,
        reading: sentence.reading,
        correctAnswer: sentence.korean,
        choices: choices,
      ));
    }
  }

  Future<void> startQuizFromItems(List<StudyItem> items, String type) async {
    _quizType = type;
    _difficulty = null;
    _isLoading = true;
    _isCompleted = false;
    _currentIndex = 0;
    _questions = [];
    notifyListeners();

    final random = Random();

    if (type == 'word') {
      await _wordService.loadWords();
      final allWords = _wordService.getRandomWords(1000);
      final allKoreans = allWords.map((w) => w.korean).toSet().toList();

      for (final item in items) {
        final wrongAnswers = allKoreans
            .where((k) => k != item.korean)
            .toList()
          ..shuffle(random);
        final choices = [item.korean, ...wrongAnswers.take(3)];
        choices.shuffle(random);
        _questions.add(QuizQuestion(
          japanese: item.japanese,
          reading: item.reading,
          correctAnswer: item.korean,
          choices: choices,
        ));
      }
    } else {
      await _sentenceService.loadSentences();
      final allSentences = _sentenceService.getRandomSentences(1000);
      final allKoreans = allSentences.map((s) => s.korean).toSet().toList();

      for (final item in items) {
        final wrongAnswers = allKoreans
            .where((k) => k != item.korean)
            .toList()
          ..shuffle(random);
        final choices = [item.korean, ...wrongAnswers.take(3)];
        choices.shuffle(random);
        _questions.add(QuizQuestion(
          japanese: item.japanese,
          reading: item.reading,
          correctAnswer: item.korean,
          choices: choices,
        ));
      }
    }

    _questions.shuffle(random);
    _isLoading = false;
    notifyListeners();

    if (_questions.isNotEmpty) {
      await _ttsService.speakJapanese(
          type == 'word' ? _questions[0].reading : _questions[0].japanese);
    }
  }

  Future<void> selectAnswer(int choiceIndex) async {
    if (currentQuestion == null || currentQuestion!.isAnswered) return;

    currentQuestion!.selectedIndex = choiceIndex;
    notifyListeners();

    // 오답일 때만 TTS 재생
    if (!currentQuestion!.isCorrect) {
      await _ttsService.speakJapanese(_quizType == 'word'
          ? currentQuestion!.reading
          : currentQuestion!.japanese);
    }
  }

  Future<void> nextQuestion() async {
    if (_currentIndex >= _questions.length - 1) {
      _isCompleted = true;
      notifyListeners();
      return;
    }

    _currentIndex++;
    notifyListeners();

    await _ttsService.speakJapanese(_quizType == 'word'
        ? _questions[_currentIndex].reading
        : _questions[_currentIndex].japanese);
  }

  StudyRecord buildRecord() {
    return StudyRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      type: 'quiz_$_quizType',
      totalCount: totalCount,
      correctCount: correctCount,
      difficulty: _difficulty,
      items: _questions
          .map((q) => StudyItem(
                japanese: q.japanese,
                reading: q.reading,
                korean: q.correctAnswer,
                isCorrect: q.isCorrect,
              ))
          .toList(),
    );
  }

  void reset() {
    _questions = [];
    _currentIndex = 0;
    _isCompleted = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _ttsService.dispose();
    super.dispose();
  }
}
