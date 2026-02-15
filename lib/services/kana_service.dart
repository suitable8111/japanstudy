import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/kana.dart';

class KanaService {
  List<Kana> _allKana = [];

  Future<void> loadKana() async {
    if (_allKana.isNotEmpty) return;
    final jsonString = await rootBundle.loadString('assets/data/kana.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    _allKana = jsonList.map((json) => Kana.fromJson(json)).toList();
  }

  List<Kana> getKanaByType(String type) {
    return _allKana.where((k) => k.type == type).toList();
  }

  List<Kana> getRandomKana(String type, int count) {
    final filtered = getKanaByType(type);
    if (filtered.isEmpty) return [];
    final shuffled = List<Kana>.from(filtered)..shuffle(Random());
    return shuffled.take(count.clamp(0, filtered.length)).toList();
  }

  int get totalKanaCount => _allKana.length;
}
