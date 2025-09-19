import 'dart:convert';

import 'package:html_unescape/html_unescape.dart';
import 'package:http/http.dart' as http;

import '../models/quran_ayah.dart';
import '../models/quran_language_profile.dart';
import '../models/surah_summary.dart';
import 'quran_word_service.dart';

class QuranLibraryService {
  QuranLibraryService({http.Client? client})
      : _client = client ?? http.Client();

  static Map<String, _BanglaWordEntry>? _banglaWordCache;
  static Future<Map<String, _BanglaWordEntry>>? _banglaWordFuture;

  static const _baseHost = 'api.quran.com';
  final http.Client _client;
  final _surahCache = <String, List<SurahSummary>>{};
  final _contentCache = <String, SurahContent>{};
  final HtmlUnescape _unescape = HtmlUnescape();

  Future<List<SurahSummary>> fetchSurahList(
      {required String languageCode}) async {
    final cacheKey = 'list-' + languageCode;
    final cached = _surahCache[cacheKey];
    if (cached != null) return cached;

    final uri = Uri.https(
      _baseHost,
      '/api/v4/chapters',
      {'language': languageCode},
    );
    final response = await _client.get(uri, headers: _headers());
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Unable to load chapters (${response.statusCode})');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final chapters = data['chapters'] as List<dynamic>? ?? [];
    final results = chapters
        .map((item) => SurahSummary.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
    _surahCache[cacheKey] = results;
    return results;
  }

  Future<SurahContent> fetchSurahContent({
    required SurahSummary summary,
    required QuranLanguageProfile language,
  }) async {
    final cacheKey = '${summary.id}-${language.code}';
    final cached = _contentCache[cacheKey];
    if (cached != null) return cached;

    final versesFuture = _fetchVerses(summary.id, language.wordLanguageCode);
    final translationFuture =
        _fetchTranslations(summary.id, language.translationId);
    final tafsirFuture = _fetchTafsir(
        summary.id, language.tafsirId, language.tafsirLanguageCode);

    final results = await Future.wait([
      versesFuture,
      translationFuture,
      tafsirFuture,
    ]);

    final versesPayload = results[0] as List<_VersePayload>;
    final translations = results[1] as List<String>;
    final tafsirMap = results[2] as Map<String, String>;

    final verses = <QuranAyahDetail>[];
    for (var i = 0; i < versesPayload.length; i++) {
      final payload = versesPayload[i];
      final translation = i < translations.length ? translations[i] : '';
      final tafsir = tafsirMap[payload.verseKey] ?? '';
      verses.add(
        QuranAyahDetail(
          verseKey: payload.verseKey,
          verseNumber: payload.verseNumber,
          arabicText: payload.arabicText,
          translation: translation,
          words: payload.words,
          tafsir: tafsir,
        ),
      );
    }

    final content = SurahContent(summary: summary, verses: verses);
    if (language.wordLanguageCode.toLowerCase().startsWith('bn')) {
      final map = await _loadBanglaWordMap();
      if (map.isNotEmpty) {
        for (final verse in verses) {
          for (var i = 0; i < verse.words.length; i++) {
            final word = verse.words[i];
            final normalized = _normalizeArabic(word.arabic.trim());
            final candidate = map[normalized] ?? map[word.arabic.trim()];
            if (candidate != null) {
              verse.words[i] = QuranAyahWord(
                arabic: word.arabic,
                translation: candidate.translation,
                transliteration: candidate.transliteration?.isNotEmpty == true
                    ? candidate.transliteration
                    : word.transliteration,
              );
            }
          }
        }
      }
    }
    _contentCache[cacheKey] = content;
    return content;
  }

  Map<String, String> _headers() => const {
        'accept': 'application/json',
      };

  Future<List<_VersePayload>> _fetchVerses(
      int chapterNumber, String wordLanguageCode) async {
    final uri = Uri.https(
      _baseHost,
      '/api/v4/verses/by_chapter/$chapterNumber',
      {
        'per_page': '300',
        'page': '1',
        'language': 'ar',
        'fields': 'text_uthmani',
        'words': 'true',
        'word_translation_language': wordLanguageCode,
        'word_fields':
            'code_v1,transliteration,translation,char_type_name,text',
      },
    );
    final response = await _client.get(uri, headers: _headers());
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Unable to load verses (${response.statusCode})');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final verses = data['verses'] as List<dynamic>? ?? [];
    return verses
        .map((raw) => _VersePayload.fromJson(raw as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<List<String>> _fetchTranslations(
      int chapterNumber, int translationId) async {
    final uri = Uri.https(
      _baseHost,
      '/api/v4/quran/translations/$translationId',
      {
        'chapter_number': '$chapterNumber',
      },
    );
    final response = await _client.get(uri, headers: _headers());
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Unable to load translations (${response.statusCode})');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final items = data['translations'] as List<dynamic>? ?? [];
    return items
        .map((raw) =>
            ((raw as Map<String, dynamic>)['text'] as String?)?.trim() ?? '')
        .toList(growable: false);
  }

  Future<Map<String, String>> _fetchTafsir(
      int chapterNumber, int tafsirId, String languageCode) async {
    final uri = Uri.https(
      _baseHost,
      '/api/v4/tafsirs/$tafsirId/by_chapter/$chapterNumber',
      {
        'language': languageCode,
      },
    );
    final response = await _client.get(uri, headers: _headers());
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return const {};
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final tafsirs = data['tafsirs'] as List<dynamic>? ?? [];
    final map = <String, String>{};
    for (final item in tafsirs) {
      final json = item as Map<String, dynamic>;
      final verseKey = json['verse_key'] as String?;
      final raw = json['text'] as String?;
      if (verseKey == null || raw == null) continue;
      map[verseKey] = _cleanHtml(raw);
    }
    return map;
  }

  Future<Map<String, _BanglaWordEntry>> _loadBanglaWordMap() async {
    if (_banglaWordCache != null) return _banglaWordCache!;
    _banglaWordFuture ??= () async {
      try {
        final words = await QuranWordService.fetchWords(limit: 1200);
        final map = <String, _BanglaWordEntry>{};
        for (final item in words) {
          final value = item.bnTranslation?.trim();
          if (value == null || value.isEmpty) continue;
          final rawKey = item.word.trim();
          if (rawKey.isNotEmpty) {
            map.putIfAbsent(rawKey,
                () => _BanglaWordEntry(value, item.bnTransliteration?.trim()));
          }
          final normalizedKey = _normalizeArabic(rawKey);
          if (normalizedKey.isNotEmpty) {
            map.putIfAbsent(normalizedKey,
                () => _BanglaWordEntry(value, item.bnTransliteration?.trim()));
          }
        }
        return map;
      } catch (_) {
        return <String, _BanglaWordEntry>{};
      }
    }();
    _banglaWordCache = await _banglaWordFuture!;
    return _banglaWordCache!;
  }

  String _normalizeArabic(String input) {
    final buffer = StringBuffer();
    for (final codePoint in input.runes) {
      if (_harakat.contains(codePoint) ||
          codePoint == 0x0640 ||
          codePoint == 0x200D) {
        continue;
      }
      buffer.writeCharCode(codePoint);
    }
    return buffer.toString();
  }

  static const Set<int> _harakat = {
    0x0610,
    0x0611,
    0x0612,
    0x0613,
    0x0614,
    0x0615,
    0x0616,
    0x0617,
    0x0618,
    0x0619,
    0x061A,
    0x064B,
    0x064C,
    0x064D,
    0x064E,
    0x064F,
    0x0650,
    0x0651,
    0x0652,
    0x0653,
    0x0654,
    0x0655,
    0x0656,
    0x0657,
    0x0658,
    0x0659,
    0x065A,
    0x065B,
    0x065C,
    0x065D,
    0x065E,
    0x065F,
    0x0670,
  };

  String _cleanHtml(String html) {
    var text = html
        .replaceAll(RegExp(r'<\s*br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(
            RegExp(r'</?(p|h1|h2|h3|h4|div)[^>]*>', caseSensitive: false),
            '\n');
    text = text.replaceAll(RegExp(r'<[^>]+>'), '');
    text = text.replaceAll(RegExp(r'\r'), '\n');
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    return _unescape.convert(text).trim();
  }
}

class _VersePayload {
  _VersePayload({
    required this.verseKey,
    required this.verseNumber,
    required this.arabicText,
    required this.words,
  });

  final String verseKey;
  final int verseNumber;
  final String arabicText;
  final List<QuranAyahWord> words;

  factory _VersePayload.fromJson(Map<String, dynamic> json) {
    final wordsJson = json['words'] as List<dynamic>? ?? [];
    final words = <QuranAyahWord>[];
    for (final entry in wordsJson) {
      final word = entry as Map<String, dynamic>;
      final type = (word['char_type_name'] as String?) ?? '';
      if (type != 'word') continue;
      final arabic = (word['text'] as String?) ?? '';
      final translationJson = word['translation'] as Map<String, dynamic>?;
      final transliterationJson =
          word['transliteration'] as Map<String, dynamic>?;
      final translation = translationJson != null
          ? (translationJson['text'] as String? ?? '')
          : '';
      final transliteration = transliterationJson != null
          ? transliterationJson['text'] as String?
          : null;
      words.add(
        QuranAyahWord(
          arabic: arabic,
          translation: translation,
          transliteration: transliteration,
        ),
      );
    }
    return _VersePayload(
      verseKey: (json['verse_key'] as String?) ?? '',
      verseNumber: (json['verse_number'] as num?)?.toInt() ?? 0,
      arabicText: (json['text_uthmani'] as String?) ?? '',
      words: words,
    );
  }
}

class _BanglaWordEntry {
  const _BanglaWordEntry(this.translation, this.transliteration);

  final String translation;
  final String? transliteration;
}
