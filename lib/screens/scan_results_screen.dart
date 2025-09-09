import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event_model.dart';
import '../models/jamat_time_details.dart';
import '../models/mosque_model.dart';
import '../widgets/event_card.dart';
import 'package:jamat_time/l10n/app_localizations.dart';
import 'package:jamat_time/providers/location_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jamat_time/config.dart';

class ScanResultsScreen extends StatefulWidget {
  final ValueChanged<Mosque>? onMosqueSelected;
  const ScanResultsScreen({super.key, this.onMosqueSelected});

  @override
  State<ScanResultsScreen> createState() => _ScanResultsScreenState();
}

class _ScanResultsScreenState extends State<ScanResultsScreen> {
  List<_NearbyPlace> _places = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final loc = context.read<LocationProvider>();
    await loc.ensureLocation();
    if (!mounted) return;
    final pos = loc.position;
    if (pos == null) {
      setState(() {
        _loading = false;
        _error = context.read<LocationProvider>().error ?? 'Location unavailable';
      });
      return;
    }
    try {
      // Try cache within 2km first
      final cached = await _loadFromCache(pos.latitude, pos.longitude);
      if (cached.isNotEmpty) {
        setState(() {
          _places = cached;
          _loading = false;
        });
        return;
      }
      // Try Supabase table first if configured
      List<_NearbyPlace> list = [];
      if (AppConfig.supabaseUrl.isNotEmpty && AppConfig.supabaseAnonKey.isNotEmpty) {
        list = await _fetchSupabaseMosques(pos.latitude, pos.longitude);

      }
      if (list.isEmpty) {
        // Fallback to OpenStreetMap (Overpass)
        list = await _fetchOSMMosques(pos.latitude, pos.longitude);
      }
      list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
      setState(() {
        _places = list;
        _loading = false;
      });
      if (list.isNotEmpty) {
        await _saveCache(pos.latitude, pos.longitude, list);
      }
    } catch (e) {
      // fallback to any cache (ignore radius)
      final cachedAny = await _loadFromCache(pos.latitude, pos.longitude, ignoreRadius: true);
      setState(() {
        _error = cachedAny.isEmpty ? 'Network error while fetching nearby mosques. Please try again.' : null;
        _places = cachedAny;
        _loading = false;
      });
    }
  }

  Future<List<_NearbyPlace>> _fetchOSMMosques(double lat, double lon) async {
    final endpoints = <String>[
      'https://overpass-api.de/api/interpreter',
      'https://overpass.kumi.systems/api/interpreter',
      'https://overpass.osm.ch/api/interpreter',
      'https://overpass.nchc.org.tw/api/interpreter',
      'https://overpass.openstreetmap.ru/cgi/interpreter',
    ];
    for (final radius in <int>[3000, 5000, 8000]) {
      final query = _buildOverpassQuery(lat, lon, radius);
      for (final ep in endpoints) {
        try {
          final uri = Uri.parse(ep);
          http.Response res;
          try {
            res = await http
                .post(uri,
                    headers: {
                      'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
                    },
                    body: {'data': query})
                .timeout(const Duration(seconds: 8));
          } on TimeoutException {
            final getUri = Uri.parse('$ep?data=${Uri.encodeComponent(query)}');
            res = await http.get(getUri).timeout(const Duration(seconds: 8));
          }
          if (res.statusCode != 200) continue;
          final data = json.decode(res.body) as Map<String, dynamic>;
          final elements = (data['elements'] as List?) ?? [];
          if (elements.isEmpty) continue;
          final results = <_NearbyPlace>[];
          for (final raw in elements) {
            final e = raw as Map<String, dynamic>;
            final tagsRaw = e['tags'];
            final Map<String, String> tags = tagsRaw is Map
                ? tagsRaw.map((k, v) => MapEntry(k.toString(), v.toString()))
                : <String, String>{};
            final name = (tags['name'] ?? 'Mosque').toString();
            final center = e['center'];
            final latVal = e['lat'] ?? (center is Map ? center['lat'] : null);
            final lonVal = e['lon'] ?? (center is Map ? center['lon'] : null);
            final elLat = (latVal is num) ? latVal.toDouble() : null;
            final elLon = (lonVal is num) ? lonVal.toDouble() : null;
            if (elLat == null || elLon == null) continue;
            final distance = _distanceKm(lat, lon, elLat, elLon);
            final addr = [
              tags['addr:street'],
              tags['addr:suburb'],
              tags['addr:city']
            ].whereType<String>().where((p) => p.isNotEmpty).join(', ');
            results.add(_NearbyPlace(
              name: name,
              address: addr.isEmpty ? (tags['name:en'] ?? 'Nearby Mosque') : addr,
              lat: elLat,
              lon: elLon,
              distanceKm: distance,
            ));
          }
          if (results.isNotEmpty) return results;
        } catch (_) {
          continue;
        }
      }
    }
    return <_NearbyPlace>[];
  }

  Future<List<_NearbyPlace>> _fetchSupabaseMosques(double lat, double lon) async {
    try {
      // Bounding box ~5km
      const radiusMeters = 50000000.0;
      const metersPerDegLat = 111000.0;
      const dLat = radiusMeters / metersPerDegLat;
      final dLon = radiusMeters / (metersPerDegLat * math.cos(lat * math.pi / 180.0)).abs().clamp(1e-6, double.infinity);
      final minLat = lat - dLat;
      final maxLat = lat + dLat;
      final minLon = lon - dLon;
      final maxLon = lon + dLon;

      final client = Supabase.instance.client;
      final resp = await client
          .from('mosque_list')
          .select('mosque_name, latitude, longitude, city, district, has_jamat_time')
          .gte('latitude', minLat)
          .lte('latitude', maxLat)
          .gte('longitude', minLon)
          .lte('longitude', maxLon);

      final rows = (resp as List?) ?? [];
      final results = <_NearbyPlace>[];
      for (final row in rows) {
        if (row is! Map) continue;
        final name = (row['mosque_name'] ?? 'Mosque').toString();
        final rLat = (row['latitude'] as num?)?.toDouble();
        final rLon = (row['longitude'] as num?)?.toDouble();
        if (rLat == null || rLon == null) continue;
        final distance = _distanceKm(lat, lon, rLat, rLon);
        final city = (row['city'] ?? '').toString();
        final district = (row['district'] ?? '').toString();
        final addr = [city, district].where((e) => e.isNotEmpty).join(', ');
        results.add(_NearbyPlace(
          name: name,
          address: addr,
          lat: rLat,
          lon: rLon,
          distanceKm: distance,
        ));
      }
      results.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
      return results;
    } catch (_) {
      return [];
    }
  }

  String _buildOverpassQuery(double lat, double lon, int radiusMeters) {
    final r = radiusMeters;
    return '[out:json][timeout:25];('
        'node["amenity"="place_of_worship"]["religion"="muslim"](around:$r,$lat,$lon);'
        'way["amenity"="place_of_worship"]["religion"="muslim"](around:$r,$lat,$lon);'
        'relation["amenity"="place_of_worship"]["religion"="muslim"](around:$r,$lat,$lon);'
        'node["building"="mosque"](around:$r,$lat,$lon);'
        'way["building"="mosque"](around:$r,$lat,$lon);'
        'relation["building"="mosque"](around:$r,$lat,$lon);'
        'node["name"~"(?i)mosque|masjid"](around:$r,$lat,$lon);'
        'way["name"~"(?i)mosque|masjid"](around:$r,$lat,$lon);'
        'relation["name"~"(?i)mosque|masjid"](around:$r,$lat,$lon);'
        ');out center tags;';
  }

  double _distanceKm(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0; // km
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_deg2rad(lat1)) *
            math.cos(_deg2rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) => deg * math.pi / 180.0;


  Future<void> _saveCache(double centerLat, double centerLon, List<_NearbyPlace> places) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('osm_cache_center_lat', centerLat);
      await prefs.setDouble('osm_cache_center_lon', centerLon);
      final jsonList = places
          .map((p) => {
                'name': p.name,
                'address': p.address,
                'lat': p.lat,
                'lon': p.lon,
              })
          .toList();
      await prefs.setString('osm_cache_places', json.encode(jsonList));
    } catch (_) {}
  }

  Future<List<_NearbyPlace>> _loadFromCache(double lat, double lon, {bool ignoreRadius = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cLat = prefs.getDouble('osm_cache_center_lat');
      final cLon = prefs.getDouble('osm_cache_center_lon');
      final data = prefs.getString('osm_cache_places');
      if (cLat == null || cLon == null || data == null) return [];
      final distToCenter = _distanceKm(lat, lon, cLat, cLon);
      if (!ignoreRadius && distToCenter > 2.0) return [];
      final list = (json.decode(data) as List)
          .map((e) => _NearbyPlace(
                name: e['name'] as String,
                address: (e['address'] ?? '') as String,
                lat: (e['lat'] as num).toDouble(),
                lon: (e['lon'] as num).toDouble(),
                distanceKm: 0,
              ))
          .toList();
      for (var i = 0; i < list.length; i++) {
        final p = list[i];
        list[i] = _NearbyPlace(
          name: p.name,
          address: p.address,
          lat: p.lat,
          lon: p.lon,
          distanceKm: _distanceKm(lat, lon, p.lat, p.lon),
        );
      }
      list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
      return list;
    } catch (_) {
      return [];
    }
  }

  // FIX: Removed 'const' from the list declaration
  final List<EventModel> _nearbyEvents = [
    EventModel(title: "Weekly Tafsir Circle", location: "Baitul Falah Mosque Hall", eventTime: DateTime(2025, 9, 5, 19, 45), goingCount: 45),
    EventModel(title: "Youth Community Iftar", location: "Chittagong Club Ltd.", eventTime: DateTime(2025, 9, 7, 18, 0), goingCount: 112),
    EventModel(title: "Charity Drive for Orphans", location: "Nasirabad Community Center", eventTime: DateTime(2025, 9, 6, 11, 0), goingCount: 32),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.scanResults),
          bottom: TabBar(tabs: [Tab(text: l10n.nearbyMosques), Tab(text: l10n.nearbyEvents)]),
        ),
        body: TabBarView(
          children: [
            // Mosques Tab
            _buildMosquesTab(context),
            // Events Tab
            ListView.builder(
              itemCount: _nearbyEvents.length,
              itemBuilder: (context, index) {
                return EventCard(event: _nearbyEvents[index]);
              },
            ),
          ],
        ),
      ),
    );
  }
}

Widget _chip(BuildContext context, String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Theme.of(context).hintColor.withOpacity(0.4)),
    ),
    child: Text(text, style: Theme.of(context).textTheme.bodySmall),
  );
}

class _NearbyPlace {
  final String name;
  final String address;
  final double lat;
  final double lon;
  final double distanceKm;
  _NearbyPlace({
    required this.name,
    required this.address,
    required this.lat,
    required this.lon,
    required this.distanceKm,
  });
}

extension on _ScanResultsScreenState {
  Widget _buildMosquesTab(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Wrap(spacing: 12, children: [
              ElevatedButton.icon(
                onPressed: () async {
                  _load();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  await Geolocator.openLocationSettings();
                },
                icon: const Icon(Icons.location_on_outlined),
                label: const Text('Enable Location'),
              ),
            ]),
          ],
        ),
      );
    }
    if (_places.isEmpty) {
      return const Center(child: Text('No nearby mosques found'));
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      itemCount: _places.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final place = _places[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Theme.of(context).cardColor.withOpacity(0.8),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  foregroundColor: Theme.of(context).primaryColor,
                  child: const Icon(Icons.mosque_outlined),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(place.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
                      const SizedBox(height: 4),
                      if (place.address.isNotEmpty)
                        Text(place.address, style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 8),
                      _chip(context, "${place.distanceKm.toStringAsFixed(2)} km"),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    final mosque = Mosque(
                      name: place.name,
                      address: place.address.isEmpty ? '${place.lat.toStringAsFixed(4)}, ${place.lon.toStringAsFixed(4)}' : place.address,
                      lastUpdatedAt: DateTime.now(),
                      lastUpdatedBy: 'OSM',
                      jamatTimes: {
                        'Fajr': JamatTimeDetails(jamatTime: '--:--'),
                        'Dhuhr': JamatTimeDetails(jamatTime: '--:--'),
                        'Asr': JamatTimeDetails(jamatTime: '--:--'),
                        'Maghrib': JamatTimeDetails(jamatTime: '--:--'),
                        'Isha': JamatTimeDetails(jamatTime: '--:--'),
                      },
                    );
                    widget.onMosqueSelected?.call(mosque);
                    Navigator.pop(context, mosque);
                  },
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Select'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
