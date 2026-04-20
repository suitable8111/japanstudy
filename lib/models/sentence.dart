class Sentence {
  final String id;
  final String japanese;
  final String reading;
  final String korean;
  final String english;
  final String category;
  final String level;

  Sentence({
    required this.id,
    required this.japanese,
    required this.reading,
    required this.korean,
    this.english = '',
    required this.category,
    required this.level,
  });

  // 언어 설정에 따라 번역 반환 (영어 없으면 한국어 fallback)
  String meaning(String lang) =>
      lang == 'en' && english.isNotEmpty ? english : korean;

  factory Sentence.fromJson(Map<String, dynamic> json) {
    return Sentence(
      id: json['id'] as String,
      japanese: json['japanese'] as String,
      reading: json['reading'] as String,
      korean: json['korean'] as String,
      english: json['english'] as String? ?? '',
      category: json['category'] as String? ?? '',
      level: json['level'] as String? ?? 'N5',
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
    };
  }
}
