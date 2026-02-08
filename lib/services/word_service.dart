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

  int get totalWordCount => _allWords.length;
}
