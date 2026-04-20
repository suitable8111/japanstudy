class Word {
  final String id;
  final String japanese;
  final String reading;
  final String korean;
  final String english;
  final String category;
  final String level;
  final String type; // hiragana, katakana, kanji

  Word({
    required this.id,
    required this.japanese,
    required this.reading,
    required this.korean,
    this.english = '',
    required this.category,
    required this.level,
    required this.type,
  });

  // 언어 설정에 따라 번역 반환 (영어 없으면 한국어 fallback)
  String meaning(String lang) =>
      lang == 'en' && english.isNotEmpty ? english : korean;

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'] as String,
      japanese: json['japanese'] as String,
      reading: json['reading'] as String,
      korean: json['korean'] as String,
      english: json['english'] as String? ?? '',
      category: json['category'] as String? ?? '',
      level: json['level'] as String? ?? 'N5',
      type: json['type'] as String? ?? 'kanji',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'japanese': japanese,
      'reading': reading,
      'korean': korean,
      'english': english,
      'category': category,
      'level': level,
      'type': type,
    };
  }
}
