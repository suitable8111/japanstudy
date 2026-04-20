class Kana {
  final String id;
  final String japanese;
  final String reading;
  final String korean;
  final String type; // 'hiragana' or 'katakana'
  final String row;

  Kana({
    required this.id,
    required this.japanese,
    required this.reading,
    required this.korean,
    required this.type,
    required this.row,
  });

  factory Kana.fromJson(Map<String, dynamic> json) {
    return Kana(
      id: json['id'] as String,
      japanese: json['japanese'] as String,
      reading: json['reading'] as String,
      korean: json['korean'] as String,
      type: json['type'] as String,
      row: json['row'] as String,
    );
  }

  // 영어 모드에서는 로마자(reading) 표시
  String meaning(String lang) => lang == 'en' ? reading : korean;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'japanese': japanese,
      'reading': reading,
      'korean': korean,
      'type': type,
      'row': row,
    };
  }
}
