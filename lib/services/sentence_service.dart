import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/sentence.dart';

class SentenceService {
  List<Sentence> _allSentences = [];

  Future<void> loadSentences() async {
    if (_allSentences.isNotEmpty) return;
    final jsonString =
        await rootBundle.loadString('assets/data/sentences.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    _allSentences = jsonList.map((json) => Sentence.fromJson(json)).toList();
  }

  List<Sentence> getRandomSentences(int count) {
    if (_allSentences.isEmpty) return [];
    final shuffled = List<Sentence>.from(_allSentences)..shuffle(Random());
    return shuffled.take(count.clamp(0, _allSentences.length)).toList();
  }

  int get totalSentenceCount => _allSentences.length;
}
