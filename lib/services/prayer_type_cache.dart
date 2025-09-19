import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jamat_time/config.dart';

class PrayerTypeCache {
  static const _prefsKey = 'cache_prayer_types_v1';
  static Map<int, Map<String, String>>? _cache; // id -> {en, bn}

  static Future<void> ensureLoaded() async {
    if (_cache != null) return;
    // Try local cache first
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      try {
        final decoded = json.decode(raw) as Map<String, dynamic>;
        _cache = decoded.map((k, v) =>
            MapEntry(int.parse(k), Map<String, String>.from(v as Map)));
        return;
      } catch (_) {}
    }
    // Fetch from Supabase if configured
    if (AppConfig.supabaseUrl.isEmpty || AppConfig.supabaseAnonKey.isEmpty) {
      _cache = {};
      return;
    }
    final client = Supabase.instance.client;
    final rows =
        await client.from('prayer_type').select('id, name_en, name_bn');
    final map = <int, Map<String, String>>{};
    for (final r in rows) {
      final id = (r['id'] as num).toInt();
      map[id] = {
        'en': (r['name_en'] as String?)?.trim() ?? '',
        'bn': (r['name_bn'] as String?)?.trim() ?? '',
      };
    }
    _cache = map;
    try {
      final encoded = json.encode(map.map((k, v) => MapEntry(k.toString(), v)));
      await prefs.setString(_prefsKey, encoded);
    } catch (_) {}
  }

  static String nameFor(int id, {String locale = 'en'}) {
    final entry = _cache?[id];
    if (entry == null) return '';
    final en = entry['en'] ?? '';
    final bn = entry['bn'] ?? '';
    if (locale.startsWith('bn')) return bn.isNotEmpty ? bn : en;
    return en.isNotEmpty ? en : bn;
  }
}
