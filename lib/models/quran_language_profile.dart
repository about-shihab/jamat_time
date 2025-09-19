class QuranLanguageProfile {
  const QuranLanguageProfile({
    required this.code,
    required this.displayName,
    required this.translationId,
    required this.wordLanguageCode,
    required this.tafsirId,
    required this.tafsirLanguageCode,
  });

  final String code;
  final String displayName;
  final int translationId;
  final String wordLanguageCode;
  final int tafsirId;
  final String tafsirLanguageCode;

  static const english = QuranLanguageProfile(
    code: 'en',
    displayName: 'English',
    translationId: 85,
    wordLanguageCode: 'en',
    tafsirId: 169,
    tafsirLanguageCode: 'en',
  );

  static const bangla = QuranLanguageProfile(
    code: 'bn',
    displayName: 'Bangla',
    translationId: 161,
    wordLanguageCode: 'bn',
    tafsirId: 381,
    tafsirLanguageCode: 'bn',
  );

  static const values = [english, bangla];

  static QuranLanguageProfile preferredFor(String languageCode) {
    final code = languageCode.toLowerCase();
    if (code.startsWith('bn')) return bangla;
    return english;
  }
}
