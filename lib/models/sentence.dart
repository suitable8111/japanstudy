class Sentence {
  final String id;
  final String japanese;
  final String reading;
  final String korean;
  final String category;
  final String level;

  Sentence({
    required this.id,
    required this.japanese,
    required this.reading,
    required this.korean,
    required this.category,
    required this.level,
  });

  factory Sentence.fromJson(Map<String, dynamic> json) {
    return Sentence(
      id: json['id'] as String,
      japanese: json['japanese'] as String,
      reading: json['reading'] as String,
      korean: json['korean'] as String,
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
      'category': category,
      'level': level,
    };
  }
}
