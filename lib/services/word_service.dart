import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/word.dart';

class WordService {
  List<Word> _allWords = [];

  Future<void> loadWords() async {
    if (_allWords.isNotEmpty) return;
    final jsonString = await rootBundle.loadString('assets/data/words.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    _allWords = jsonList.map((json) => Word.fromJson(json)).toList();
  }

  List<Word> getRandomWords(int count) {
    if (_allWords.isEmpty) return [];
    final shuffled = List<Word>.from(_allWords)..shuffle(Random());
    return shuffled.take(count.clamp(0, _allWords.length)).toList();
  }

  List<Word> getRandomWordsByLevel(String level,
      {int primaryCount = 16, int otherCount = 4}) {
    if (_allWords.isEmpty) return [];

    final random = Random();
    final primaryWords = _allWords.where((w) => w.level == level).toList()
      ..shuffle(random);
    final otherWords = _allWords.where((w) => w.level != level).toList()
      ..shuffle(random);

    final result = <Word>[
      ...primaryWords.take(primaryCount.clamp(0, primaryWords.length)),
      ...otherWords.take(otherCount.clamp(0, otherWords.length)),
    ]..shuffle(random);

    return result;
  }

  List<Word> getRandomWordsByLevelOnly(String level, int count) {
    if (_allWords.isEmpty) return [];
    final levelWords = _allWords.where((w) => w.level == level).toList()
      ..shuffle(Random());
    return levelWords.take(count.clamp(0, levelWords.length)).toList();
  }

  List<Word> getAllWords() {
    return List<Word>.from(_allWords);
  }

  int get totalWordCount => _allWords.length;
}
