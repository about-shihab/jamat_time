import 'surah_summary.dart';

class QuranAyahWord {
  const QuranAyahWord({
    required this.arabic,
    required this.translation,
    required this.transliteration,
  });

  final String arabic;
  final String translation;
  final String? transliteration;
}

class QuranAyahDetail {
  const QuranAyahDetail({
    required this.verseKey,
    required this.verseNumber,
    required this.arabicText,
    required this.translation,
    required this.words,
    required this.tafsir,
  });

  final String verseKey;
  final int verseNumber;
  final String arabicText;
  final String translation;
  final List<QuranAyahWord> words;
  final String tafsir;
}

class SurahContent {
  const SurahContent({
    required this.summary,
    required this.verses,
  });

  final SurahSummary summary;
  final List<QuranAyahDetail> verses;
}
