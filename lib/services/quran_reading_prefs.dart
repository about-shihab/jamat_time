import 'package:shared_preferences/shared_preferences.dart';

class QuranReadingPrefs {
  static const _lastSurahIdKey = 'quran_last_surah_id';
  static const _lastSurahLangKey = 'quran_last_surah_lang';
  static const _favoriteSurahKey = 'quran_favorite_surah_ids';

  static Future<void> setLastSurah({
    required int surahId,
    required String languageCode,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastSurahIdKey, surahId);
    await prefs.setString(_lastSurahLangKey, languageCode);
  }

  static Future<int?> lastSurahId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lastSurahIdKey);
  }

  static Future<String?> lastSurahLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastSurahLangKey);
  }

  static Future<Set<int>> favoriteSurahIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_favoriteSurahKey) ?? <String>[];
    return list.map(int.parse).toSet();
  }

  static Future<bool> toggleFavorite(int surahId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_favoriteSurahKey) ?? <String>[];
    final set = list.map(int.parse).toSet();
    final added = set.contains(surahId) ? false : true;
    if (added) {
      set.add(surahId);
    } else {
      set.remove(surahId);
    }
    await prefs.setStringList(
      _favoriteSurahKey,
      set.map((e) => e.toString()).toList(),
    );
    return added;
  }

  static Future<bool> isFavorite(int surahId) async {
    final set = await favoriteSurahIds();
    return set.contains(surahId);
  }
}
