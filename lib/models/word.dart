class Word {
  final String id;
  final String japanese;
  final String reading;
  final String korean;
  final String category;
  final String level;
  final String type; // hiragana, katakana, kanji

  Word({
    required this.id,
    required this.japanese,
    required this.reading,
    required this.korean,
    required this.category,
    required this.level,
    required this.type,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'] as String,
      japanese: json['japanese'] as String,
      reading: json['reading'] as String,
      korean: json['korean'] as String,
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
      'category': category,
      'level': level,
      'type': type,
    };
  }
}
