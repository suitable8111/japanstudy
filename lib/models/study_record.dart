import 'dart:convert';

class StudyItem {
  final String japanese;
  final String reading;
  final String korean;
  final bool? isCorrect; // 퀴즈용 (정답 여부)

  StudyItem({
    required this.japanese,
    required this.reading,
    required this.korean,
    this.isCorrect,
  });

  Map<String, dynamic> toJson() => {
        'japanese': japanese,
        'reading': reading,
        'korean': korean,
        if (isCorrect != null) 'isCorrect': isCorrect,
      };

  factory StudyItem.fromJson(Map<String, dynamic> json) => StudyItem(
        japanese: json['japanese'] as String,
        reading: json['reading'] as String,
        korean: json['korean'] as String,
        isCorrect: json['isCorrect'] as bool?,
      );
}

class StudyRecord {
  final String id;
  final DateTime date;
  final String type; // 'word', 'sentence', 'quiz_word', 'quiz_sentence'
  final int totalCount;
  final int? correctCount; // 퀴즈용
  final String? difficulty; // 'N5', 'N4', 'N3' (nullable for legacy records)
  final List<StudyItem> items;

  StudyRecord({
    required this.id,
    required this.date,
    required this.type,
    required this.totalCount,
    this.correctCount,
    this.difficulty,
    required this.items,
  });

  String get difficultyLabel {
    switch (difficulty) {
      case 'N5':
        return '하';
      case 'N4':
        return '중';
      case 'N3':
        return '상';
      case 'N2':
        return '상상';
      case 'N1':
        return '최상';
      default:
        return '';
    }
  }

  String get typeLabel {
    switch (type) {
      case 'word':
        return '단어 학습';
      case 'sentence':
        return '문장 학습';
      case 'quiz_word':
        return '단어 퀴즈';
      case 'quiz_sentence':
        return '문장 퀴즈';
      case 'kana_hiragana':
        return '히라가나 학습';
      case 'kana_katakana':
        return '가타카나 학습';
      case 'quiz_kana_hiragana':
        return '히라가나 퀴즈';
      case 'quiz_kana_katakana':
        return '가타카나 퀴즈';
      default:
        return type;
    }
  }

  String get resultText {
    if (correctCount != null) {
      return '$correctCount / $totalCount 정답';
    }
    return '$totalCount개 완료';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'type': type,
        'totalCount': totalCount,
        if (correctCount != null) 'correctCount': correctCount,
        if (difficulty != null) 'difficulty': difficulty,
        'items': items.map((e) => e.toJson()).toList(),
      };

  factory StudyRecord.fromJson(Map<String, dynamic> json) => StudyRecord(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        type: json['type'] as String,
        totalCount: json['totalCount'] as int,
        correctCount: json['correctCount'] as int?,
        difficulty: json['difficulty'] as String?,
        items: (json['items'] as List)
            .map((e) => StudyItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  static String encodeList(List<StudyRecord> records) =>
      jsonEncode(records.map((e) => e.toJson()).toList());

  static List<StudyRecord> decodeList(String jsonStr) {
    final list = jsonDecode(jsonStr) as List;
    return list
        .map((e) => StudyRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
