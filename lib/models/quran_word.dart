class QuranWord {
  final int id;
  final String word; // Arabic
  final String? transliteration;
  final String? bnTransliteration;
  final String? enTranslation;
  final String? bnTranslation;
  final num? occurrence;
  final String? exampleAr;
  final String? exampleArEn;
  final String? exampleArBn;
  final num? isActive;

  const QuranWord({
    required this.id,
    required this.word,
    this.transliteration,
    this.bnTransliteration,
    this.enTranslation,
    this.bnTranslation,
    this.occurrence,
    this.exampleAr,
    this.exampleArEn,
    this.exampleArBn,
    this.isActive,
  });

  factory QuranWord.fromMap(Map<String, dynamic> map) {
    return QuranWord(
      id: (map['id'] as num).toInt(),
      word: (map['word'] ?? '').toString(),
      transliteration: map['transliteration']?.toString(),
      bnTransliteration: map['bn_transliteration']?.toString(),
      enTranslation: map['en_translation']?.toString(),
      bnTranslation: map['bn_translation']?.toString(),
      occurrence: map['occurrence'] as num?,
      exampleAr: map['example_ar']?.toString(),
      exampleArEn: map['example_ar_en']?.toString(),
      exampleArBn: map['example_ar_bn']?.toString(),
      isActive: map['is_active'] as num?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'transliteration': transliteration,
      'bn_transliteration': bnTransliteration,
      'en_translation': enTranslation,
      'bn_translation': bnTranslation,
      'occurrence': occurrence,
      'example_ar': exampleAr,
      'example_ar_en': exampleArEn,
      'example_ar_bn': exampleArBn,
      'is_active': isActive,
    };
  }
}
