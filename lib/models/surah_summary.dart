class SurahSummary {
  const SurahSummary({
    required this.id,
    required this.simpleName,
    required this.arabicName,
    required this.translatedName,
    required this.versesCount,
    required this.revelationPlace,
  });

  final int id;
  final String simpleName;
  final String arabicName;
  final String translatedName;
  final int versesCount;
  final String revelationPlace;

  factory SurahSummary.fromJson(Map<String, dynamic> json) {
    final translated = json['translated_name'] as Map<String, dynamic>?;
    return SurahSummary(
      id: (json['id'] as num).toInt(),
      simpleName: (json['name_simple'] as String?) ?? '',
      arabicName: (json['name_arabic'] as String?) ?? '',
      translatedName:
          translated != null ? (translated['name'] as String? ?? '') : '',
      versesCount: (json['verses_count'] as num?)?.toInt() ?? 0,
      revelationPlace: (json['revelation_place'] as String?) ?? '',
    );
  }
}
