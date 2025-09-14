import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jamat_time/models/jamat_time_details.dart';
import 'package:jamat_time/models/mosque_model.dart';
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
      final isActive = _isActiveByMonthDay(todayDate, start, end);
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

  // Fetch jamat times by Google Place ID first; if none, by provider_id
  static Future<Map<String, JamatTimeDetails>> fetchByPlaceOrProvider({
    String? googlePlaceId,
    String? providerId,
  }) async {
    if (AppConfig.supabaseUrl.isEmpty || AppConfig.supabaseAnonKey.isEmpty) {
      return {};
    }
    final gpid = googlePlaceId?.trim();
    final pid = providerId?.trim();
    if ((gpid == null || gpid.isEmpty) && (pid == null || pid.isEmpty)) {
      return {};
    }
    final client = Supabase.instance.client;
    await PrayerTypeCache.ensureLoaded();

    // Try cache first
    final prefs = await SharedPreferences.getInstance();
    String? cacheKey;
    if (gpid != null && gpid.isNotEmpty) {
      cacheKey = 'jamat_times_gpid_$gpid';
    } else if (pid != null && pid.isNotEmpty) {
      cacheKey = 'jamat_times_pid_$pid';
    }
    if (cacheKey != null) {
      final cached = prefs.getString(cacheKey);
      if (cached != null) {
        try {
          final decoded = json.decode(cached);
          return Map<String, JamatTimeDetails>.from(
            decoded.map((key, value) => MapEntry(key, JamatTimeDetails(jamatTime: value['jamatTime']))),
          );
        } catch (_) {}
      }
    }

    List<dynamic> jtRows = const [];
    try {
      if (gpid != null && gpid.isNotEmpty) {
        jtRows = await client
            .from('jamat_times')
            .select('id, mosque_id, prayer_type_id, jamat_time, start_date, end_date, updated_by, updated_at, "googlePlaceId", provider_id')
            .eq('googlePlaceId', gpid);
      }
      if ((jtRows.isEmpty) && (pid != null && pid.isNotEmpty)) {
        jtRows = await client
            .from('jamat_times')
            .select('id, mosque_id, prayer_type_id, jamat_time, start_date, end_date, updated_by, updated_at, "googlePlaceId", provider_id')
            .eq('provider_id', pid);
      }
    } catch (_) {
      jtRows = const [];
    }

    if (jtRows.isEmpty) return {};

    // Map prayer type id -> name (en)
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
      final isActive = _isActiveByMonthDay(todayDate, start, end);
      if (!isActive) continue;

      final ptId = (row['prayer_type_id'] as num?)?.toInt();
      if (ptId == null) continue;
      final rawName = idToName[ptId] ?? '';
      final key = _toCanonicalKey(rawName);
      if (key == null) continue;

      final jt = row['jamat_time']?.toString() ?? '';
      final hhmm = _onlyHHmm(jt);
      result[key] = JamatTimeDetails(jamatTime: hhmm);
    }

    // Cache by the key used
    if (cacheKey != null) {
      try {
        await prefs.setString(
          cacheKey,
          json.encode(result.map((key, value) => MapEntry(key, {'jamatTime': value.jamatTime}))),
        );
      } catch (_) {}
    }
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

  static bool _isActiveByMonthDay(DateTime today, DateTime start, DateTime? end) {
    int key(DateTime d) => d.month * 100 + d.day;
    final t = key(today);
    final s = key(start);
    final e = end == null ? null : key(end);
    if (e == null) {
      return t >= s;
    }
    if (s <= e) {
      return t >= s && t <= e;
    } else {
      return t >= s || t <= e;
    }
  }

  // Save mosque info to mosque_list and jamat times to jamat_times
  static Future<bool> saveMosqueAndTimes({
    required Mosque mosque,
    required Map<String, String> jamatTimesText,
    bool? isFemaleAccessible,
    bool? wheelchairFacility,
    String? phone,
    String? website,
    num? capacity,
    String? imamName,
    String? muezzinName,
  }) async {
    if (AppConfig.supabaseUrl.isEmpty || AppConfig.supabaseAnonKey.isEmpty) {
      return false;
    }
    final client = Supabase.instance.client;
    // Ensure prayer type mapping
    await PrayerTypeCache.ensureLoaded();

    // 1) Ensure mosque_list row exists and update info
    int? mosqueId = mosque.id;
    try {
      if (mosqueId == null) {
        final gpid = mosque.googlePlaceId;
        if (gpid != null && gpid.isNotEmpty) {
          final rows = await client
              .from('mosque_list')
              .select('id')
              .eq('googlePlaceId', gpid)
              .maybeSingle();
          mosqueId = (rows?['id'] as num?)?.toInt();
        }
      }
    } catch (_) {}

    // Insert if still missing
    if (mosqueId == null) {
      try {
        final inserted = await client
            .from('mosque_list')
            .upsert({
              'mosque_name': mosque.name,
              'latitude': mosque.latitude,
              'longitude': mosque.longitude,
              'address_desc': mosque.address,
              'city': mosque.city,
              'is_female_accessible': isFemaleAccessible ?? mosque.isFemaleAccessible,
              'wheelchair_facility': wheelchairFacility ?? mosque.wheelchairFacility ?? false,
              'phone': phone ?? mosque.phone,
              'website': website ?? mosque.website,
              'capacity': capacity ?? mosque.capacity,
              'imam_name': imamName ?? mosque.imamName,
              'muezzin_name': muezzinName ?? mosque.muezzinName,
              'provider': mosque.provider ?? 'masjidnear.me',
              'provider_id': mosque.providerId,
              'googlePlaceId': mosque.googlePlaceId,
            }, onConflict: 'googlePlaceId', ignoreDuplicates: false)
            .select('id')
            .maybeSingle();
        mosqueId = (inserted?['id'] as num?)?.toInt();
      } catch (_) {}
    } else {
      // Update info
      try {
        await client.from('mosque_list').update({
          'mosque_name': mosque.name,
          'latitude': mosque.latitude,
          'longitude': mosque.longitude,
          'address_desc': mosque.address,
          'city': mosque.city,
          'is_female_accessible': isFemaleAccessible ?? mosque.isFemaleAccessible,
          'wheelchair_facility': wheelchairFacility ?? mosque.wheelchairFacility ?? false,
          'phone': phone ?? mosque.phone,
          'website': website ?? mosque.website,
          'capacity': capacity ?? mosque.capacity,
          'imam_name': imamName ?? mosque.imamName,
          'muezzin_name': muezzinName ?? mosque.muezzinName,
          'provider': mosque.provider ?? 'masjidnear.me',
          'provider_id': mosque.providerId,
          'googlePlaceId': mosque.googlePlaceId,
        }).eq('id', mosqueId);
      } catch (_) {}
    }

    if (mosqueId == null) return false;

    // 2) Save jamat times for today
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final rows = <Map<String, dynamic>>[];
    int? idFor(String canonical) => _prayerTypeIdForName(canonical);
    String to24h(String t) {
      try {
        if (t.contains('AM') || t.contains('PM')) {
          final parts = t.split(' ');
          final time = parts[0];
          final ampm = parts.length > 1 ? parts[1].toUpperCase() : '';
          final p = time.split(':');
          int h = int.parse(p[0]);
          final m = int.parse(p[1]);
          if (ampm == 'PM' && h != 12) h += 12;
          if (ampm == 'AM' && h == 12) h = 0;
          return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
        }
        final p = t.split(':');
        final h = int.parse(p[0]);
        final m = int.parse(p[1]);
        return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
      } catch (_) {
        return t;
      }
    }

    const keys = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    for (final k in keys) {
      final v = jamatTimesText[k];
      if (v == null || v.trim().isEmpty) continue;
      final ptId = idFor(k);
      if (ptId == null) continue;
      // Close any previously active or open-ended rows for this prayer
      final yesterday = DateTime(todayDate.year, todayDate.month, todayDate.day - 1);
      try {
        await client
            .from('jamat_times')
            .update({
              'end_date': DateTime(yesterday.year, yesterday.month, yesterday.day).toIso8601String(),
            })
            .eq('mosque_id', mosqueId)
            .eq('prayer_type_id', ptId)
            .lte('start_date', DateTime(todayDate.year, todayDate.month, todayDate.day).toIso8601String())
            .filter('end_date', 'is', 'null');
      } catch (_) {}
      try {
        await client
            .from('jamat_times')
            .update({
              'end_date': DateTime(yesterday.year, yesterday.month, yesterday.day).toIso8601String(),
            })
            .eq('mosque_id', mosqueId)
            .eq('prayer_type_id', ptId)
            .gte('end_date', DateTime(todayDate.year, todayDate.month, todayDate.day).toIso8601String());
      } catch (_) {}

      rows.add({
        'mosque_id': mosqueId,
        'prayer_type_id': ptId,
        'jamat_time': to24h(v.trim()),
        'start_date': DateTime(todayDate.year, todayDate.month, todayDate.day).toIso8601String(),
        'end_date': null,
        'googlePlaceId': mosque.googlePlaceId,
        'provider_id': mosque.providerId,
      });
    }
    if (rows.isEmpty) return true;

    try {
      await client.from('jamat_times').insert(rows);
      return true;
    } catch (_) {
      return false;
    }
  }

  static int? _prayerTypeIdForName(String canonical) {
    final mapping = <String, String>{
      'Fajr': 'fajr',
      'Dhuhr': 'dhuhr',
      'Asr': 'asr',
      'Maghrib': 'maghrib',
      'Isha': 'isha',
    };
    final target = mapping[canonical]?.toLowerCase();
    if (target == null) return null;
    // PrayerTypeCache only exposes nameFor(id). We'll scan a few ids from cache.
    // As a simple approach, try ids 1..20 and match normalized names.
    for (int id = 1; id <= 20; id++) {
      final name = PrayerTypeCache.nameFor(id).toLowerCase();
      if (name.contains(target)) return id;
    }
    return null;
  }
}
