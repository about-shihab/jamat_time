import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jamat_time/models/jamat_time_details.dart';
import 'package:jamat_time/config.dart';
import 'package:jamat_time/services/prayer_type_cache.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class JamatTimeService {
  static Future<Map<String, JamatTimeDetails>> fetchForMosque(int mosqueId) async {
    // Check if Supabase is configured
    if (AppConfig.supabaseUrl.isEmpty || AppConfig.supabaseAnonKey.isEmpty) {
      return {};
    }
    final client = Supabase.instance.client;
    // Ensure prayer types are available (cached on first run)
    await PrayerTypeCache.ensureLoaded();

    // Check if jamat times for this mosque are cached
    final prefs = await SharedPreferences.getInstance();
    final cachedJamatTimes = prefs.getString('jamat_times_mosque_$mosqueId');

    if (cachedJamatTimes != null) {
      // If cached, return the cached jamat times
      final decoded = json.decode(cachedJamatTimes);
      return Map<String, JamatTimeDetails>.from(
        decoded.map((key, value) => MapEntry(key, JamatTimeDetails(jamatTime: value['jamatTime']))),
      );
    }

    // Fetch jamat times from Supabase if not cached
    final List<dynamic> jtRows = await client
        .from('jamat_times')
        .select('id, mosque_id, prayer_type_id, jamat_time, start_date, end_date, updated_by, updated_at')
        .eq('mosque_id', mosqueId);

    if (jtRows.isEmpty) return {};

    // Map prayer type names using the cached names from PrayerTypeCache
    final idToName = <int, String>{};
    for (final r in jtRows) {
      final id = (r['prayer_type_id'] as num?)?.toInt();
      if (id != null) {
        idToName[id] = PrayerTypeCache.nameFor(id);
      }
    }

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final result = <String, JamatTimeDetails>{};
    for (final row in jtRows) {
      DateTime start = _toDate(row['start_date']);
      DateTime? end = row['end_date'] != null ? _toDate(row['end_date']) : null;
      final isActive = !todayDate.isBefore(start) && (end == null || !todayDate.isAfter(end));
      if (!isActive) continue;

      final ptId = (row['prayer_type_id'] as num?)?.toInt();
      if (ptId == null) continue;
      final rawName = idToName[ptId] ?? '';
      final key = _toCanonicalKey(rawName);
      if (key == null) continue; // only consider the five main prayers

      final jt = row['jamat_time']?.toString() ?? '';
      final hhmm = _onlyHHmm(jt);
      result[key] = JamatTimeDetails(jamatTime: hhmm);
    }

    // Cache the jamat times locally for the mosque
    await prefs.setString('jamat_times_mosque_$mosqueId', json.encode(result.map((key, value) => MapEntry(key, {'jamatTime': value.jamatTime}))));

    return result;
  }

  static String _onlyHHmm(String t) {
    if (t.isEmpty) return '--:--';
    final parts = t.split(':');
    if (parts.length < 2) return t;
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  static DateTime _toDate(dynamic v) {
    if (v is DateTime) return DateTime(v.year, v.month, v.day);
    if (v is String) {
      final d = DateTime.tryParse(v);
      if (d != null) return DateTime(d.year, d.month, d.day);
    }
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static String? _toCanonicalKey(String name) {
    final n = name.trim().toLowerCase();
    if (n.isEmpty) return null;
    if (n.contains('fajr')) return 'Fajr';
    if (n.contains('dhuhr') || n.contains('zuhr') || n.contains('zohor')) return 'Dhuhr';
    if (n.contains('asr') || n.contains('asar')) return 'Asr';
    if (n.contains('maghrib') || n.contains('magrib')) return 'Maghrib';
    if (n.contains('isha') || n.contains('esha')) return 'Isha';
    if (name.contains('ফজর')) return 'Fajr';
    if (name.contains('যোহর') || name.contains('জোহর') || name.contains('জোহার')) return 'Dhuhr';
    if (name.contains('আসর')) return 'Asr';
    if (name.contains('মাগরিব') || name.contains('মাগরীব')) return 'Maghrib';
    if (name.contains('এশা') || name.contains('ইশা')) return 'Isha';
    return null;
  }
}
