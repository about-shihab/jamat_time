import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jamat_time/config.dart';

class MasjidNearPlace {
  final String name;
  final String address;
  final double lat;
  final double lon;
  final String? googlePlaceId;
  final String? providerId; // _id from API
  final String? city;
  final String? phone;
  bool? femaleAllowed;
  int? supabaseId; // set after upsert

  MasjidNearPlace({
    required this.name,
    required this.address,
    required this.lat,
    required this.lon,
    this.googlePlaceId,
    this.providerId,
    this.city,
    this.phone,
    this.femaleAllowed,
    this.supabaseId,
  });

  Map<String, dynamic> toCacheJson() => {
        'id': supabaseId,
        'name': name,
        'address': address,
        'lat': lat,
        'lon': lon,
        'gpid': googlePlaceId,
        'pid': providerId,
        'city': city,
        'phone': phone,
        'fa': femaleAllowed,
      };

  static MasjidNearPlace fromCacheJson(Map<String, dynamic> e) => MasjidNearPlace(
        supabaseId: (e['id'] as num?)?.toInt(),
        name: (e['name'] ?? 'Mosque').toString(),
        address: (e['address'] ?? '').toString(),
        lat: (e['lat'] as num).toDouble(),
        lon: (e['lon'] as num).toDouble(),
        googlePlaceId: (e['gpid'] as String?)?.toString(),
        providerId: (e['pid'] as String?)?.toString(),
        city: (e['city'] as String?)?.toString(),
        phone: (e['phone'] as String?)?.toString(),
        femaleAllowed: (e['fa'] as bool?) ?? false,
      );
}

class MasjidNearService {
  static Future<List<MasjidNearPlace>> search({
    required double lat,
    required double lng,
    int radius = 2000,
  }) async {
    final base = AppConfig.masjidNearApiBase;
    final uri = Uri.parse('$base?lat=$lat&lng=$lng&radius=$radius');
    final res = await http.get(uri).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) return [];
    Map<String, dynamic> decoded;
    try {
      decoded = json.decode(res.body) as Map<String, dynamic>;
    } catch (_) {
      return [];
    }
    final data = decoded['data'];
    if (data is! Map) return [];
    final masjids = data['masjids'];
    if (masjids is! List) return [];
    final results = <MasjidNearPlace>[];
    for (final raw in masjids) {
      if (raw is! Map) continue;
      final name = (raw['masjidName'] ?? 'Mosque').toString();
      final addr = raw['masjidAddress'];
      String address = '';
      String? city;
      String? phone;
      String? gpid;
      if (addr is Map) {
        address = (addr['description'] ?? '').toString();
        city = (addr['city'] as String?)?.toString();
        phone = (addr['phone'] as String?)?.toString();
        gpid = (addr['googlePlaceId'] as String?)?.toString();
      }
      final loc = raw['masjidLocation'];
      double? latVal;
      double? lonVal;
      if (loc is Map) {
        final coords = loc['coordinates'];
        if (coords is List && coords.length >= 2) {
          // coordinates: [lng, lat]
          lonVal = (coords[0] as num?)?.toDouble();
          latVal = (coords[1] as num?)?.toDouble();
        }
      }
      if (latVal == null || lonVal == null) continue;
      results.add(MasjidNearPlace(
        name: name,
        address: address,
        lat: latVal,
        lon: lonVal,
        googlePlaceId: gpid,
        providerId: (raw['_id'] as String?)?.toString(),
        city: city,
        phone: phone,
        femaleAllowed: false,
      ));
    }
    return results;
  }

  // Holds ID mappings fetched/created in Supabase for later linking
  static Future<({Map<String, int> byGpid, Map<String, int> byProviderId, Map<String, bool> femaleByGpid, Map<String, bool> femaleByProviderId})>
      syncToSupabaseNoUpdate(List<MasjidNearPlace> places) async {
    // If Supabase not configured, skip
    if (AppConfig.supabaseUrl.isEmpty || AppConfig.supabaseAnonKey.isEmpty) {
      return (byGpid: <String, int>{}, byProviderId: <String, int>{}, femaleByGpid: <String, bool>{}, femaleByProviderId: <String, bool>{});
    }
    if (places.isEmpty) {
      return (byGpid: <String, int>{}, byProviderId: <String, int>{}, femaleByGpid: <String, bool>{}, femaleByProviderId: <String, bool>{});
    }
    final client = Supabase.instance.client;

    // Collect keys
    final gpids = places
        .map((p) => p.googlePlaceId)
        .whereType<String>()
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    final providerIdCandidates = places
        .where((p) => (p.googlePlaceId == null || p.googlePlaceId!.isEmpty))
        .map((p) => p.providerId)
        .whereType<String>()
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();

    // Lookup existing by googlePlaceId
    final byGpid = <String, int>{};
    final femaleByGpid = <String, bool>{};
    if (gpids.isNotEmpty) {
      try {
        final existing = await client
            .from('mosque_list')
            .select('id, "googlePlaceId", is_female_accessible')
            .filter('googlePlaceId', 'in', _inList(gpids));
        if (existing is List) {
          for (final r in existing) {
            if (r is! Map) continue;
            final id = (r['id'] as num?)?.toInt();
            final gpid = (r['googlePlaceId'] as String?)?.toString();
            final fa = (r['is_female_accessible'] as bool?) ?? false;
            if (id != null && gpid != null && gpid.isNotEmpty) {
              byGpid[gpid] = id;
              femaleByGpid[gpid] = fa;
            }
          }
        }
      } catch (_) {}
    }

    // Lookup existing by provider_id for those without gpid
    final byProviderId = <String, int>{};
    final femaleByProviderId = <String, bool>{};
    if (providerIdCandidates.isNotEmpty) {
      try {
        final existing = await client
            .from('mosque_list')
            .select('id, provider_id, is_female_accessible')
            .eq('provider', 'masjidnear.me')
            .filter('provider_id', 'in', _inList(providerIdCandidates));
        if (existing is List) {
          for (final r in existing) {
            if (r is! Map) continue;
            final id = (r['id'] as num?)?.toInt();
            final pid = (r['provider_id'] as String?)?.toString();
            final fa = (r['is_female_accessible'] as bool?) ?? false;
            if (id != null && pid != null && pid.isNotEmpty) {
              byProviderId[pid] = id;
              femaleByProviderId[pid] = fa;
            }
          }
        }
      } catch (_) {}
    }

    // Build rows for those not found yet (no updates)
    final toInsert = <Map<String, dynamic>>[];
    for (final p in places) {
      final gpid = p.googlePlaceId?.trim();
      final pid = p.providerId?.trim();
      final hasG = gpid != null && gpid.isNotEmpty;
      final hasP = pid != null && pid.isNotEmpty;
      final existsByG = hasG && byGpid.containsKey(gpid);
      final existsByP = !hasG && hasP && byProviderId.containsKey(pid);
      if (existsByG || existsByP) continue;
      toInsert.add({
        'mosque_name': p.name,
        'latitude': p.lat,
        'longitude': p.lon,
        'address_desc': p.address,
        'city': p.city,
        'is_female_accessible': p.femaleAllowed ?? false,
        'created_by': 'scan',
        'provider': 'masjidnear.me',
        'provider_id': p.providerId,
        'googlePlaceId': p.googlePlaceId,
        'phone': p.phone,
      });
    }

    if (toInsert.isNotEmpty) {
      try {
        final inserted = await client
            .from('mosque_list')
            .upsert(
              toInsert,
              onConflict: 'googlePlaceId',
              ignoreDuplicates: true,
            )
            .select('id, "googlePlaceId", provider_id, is_female_accessible');
        if (inserted is List) {
          for (final r in inserted) {
            if (r is! Map) continue;
            final id = (r['id'] as num?)?.toInt();
            final gpid = (r['googlePlaceId'] as String?)?.toString();
            final pid = (r['provider_id'] as String?)?.toString();
            final fa = (r['is_female_accessible'] as bool?) ?? false;
            if (id != null) {
              if (gpid != null && gpid.isNotEmpty) {
                byGpid[gpid] = id;
                femaleByGpid[gpid] = fa;
              } else if (pid != null && pid.isNotEmpty) {
                byProviderId[pid] = id;
                femaleByProviderId[pid] = fa;
              }
            }
          }
        }
      } catch (_) {}
    }

    return (byGpid: byGpid, byProviderId: byProviderId, femaleByGpid: femaleByGpid, femaleByProviderId: femaleByProviderId);
  }
}

String _inList(List<String> values) {
  // Build PostgREST in-list value, quoting strings safely
  final quoted = values.map((v) => '"${v.replaceAll('"', '""')}"').join(',');
  return '($quoted)';
}
