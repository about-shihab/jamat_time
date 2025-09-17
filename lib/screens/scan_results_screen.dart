import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/jamat_time_details.dart';
import '../models/mosque_model.dart';
import 'package:jamat_time/services/jamat_time_service.dart';
import 'package:jamat_time/l10n/app_localizations.dart';
import 'package:jamat_time/providers/location_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jamat_time/config.dart';
import 'package:jamat_time/services/masjid_near_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jamat_time/widgets/aurora_background_painter.dart';

class ScanResultsScreen extends StatefulWidget {
  final ValueChanged<Mosque>? onMosqueSelected;
  const ScanResultsScreen({super.key, this.onMosqueSelected});

  @override
  State<ScanResultsScreen> createState() => _ScanResultsScreenState();
}

class _ScanResultsScreenState extends State<ScanResultsScreen>
    with SingleTickerProviderStateMixin {
  List<_NearbyPlace> _places = [];
  bool _loading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 40))
          ..repeat();
    _searchController.addListener(() {
      final q = _searchController.text.trim();
      if (q != _query) setState(() => _query = q);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
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
        _error =
            context.read<LocationProvider>().error ?? 'Location unavailable';
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
      // Fetch from MasjidNear API (2km, then fallback to 15km)
      final list = await _fetchMasjidNearMosques(pos.latitude, pos.longitude);
      list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
      setState(() {
        _places = list;
        _loading = false;
      });
      if (list.isNotEmpty) {
        await _saveCache(pos.latitude, pos.longitude, list);
        // Save to Supabase in background and attach ids if available
        unawaited(_backgroundUpsertAndUpdate(list));
      }
    } catch (e) {
      // fallback to any cache (ignore radius)
      final cachedAny =
          await _loadFromCache(pos.latitude, pos.longitude, ignoreRadius: true);
      setState(() {
        _error = cachedAny.isEmpty
            ? 'Network error while fetching nearby mosques. Please try again.'
            : null;
        _places = cachedAny;
        _loading = false;
      });
    }
  }

  Future<List<_NearbyPlace>> _fetchMasjidNearMosques(
      double lat, double lon) async {
    final results = <_NearbyPlace>[];
    Future<void> fetchWith(int radius) async {
      final list =
          await MasjidNearService.search(lat: lat, lng: lon, radius: radius);
      for (final p in list) {
        final d = _distanceKm(lat, lon, p.lat, p.lon);
        results.add(_NearbyPlace(
          id: p.supabaseId,
          name: p.name,
          address: p.address,
          lat: p.lat,
          lon: p.lon,
          distanceKm: d,
          femaleAllowed: p.femaleAllowed,
          googlePlaceId: p.googlePlaceId,
          providerId: p.providerId,
        ));
      }
    }

    await fetchWith(2000);
    if (results.isEmpty) {
      await fetchWith(15000);
    }
    return results;
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

  Future<void> _saveCache(
      double centerLat, double centerLon, List<_NearbyPlace> places) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('mnm_cache_center_lat', centerLat);
      await prefs.setDouble('mnm_cache_center_lon', centerLon);
      final jsonList = places
          .map((p) => {
                'id': p.id,
                'name': p.name,
                'address': p.address,
                'lat': p.lat,
                'lon': p.lon,
                'gpid': p.googlePlaceId,
                'pid': p.providerId,
                'fa': p.femaleAllowed,
              })
          .toList();
      await prefs.setString('mnm_cache_places', json.encode(jsonList));
    } catch (_) {}
  }

  Future<Map<String, dynamic>?> _findNearestSupabaseMosque(
      double lat, double lon,
      {String? nameHint}) async {
    try {
      final client = Supabase.instance.client;
      // Small bounding box around the selected point (~250m)
      const metersPerDegLat = 111000.0;
      const radiusMeters = 250.0;
      final dLat = radiusMeters / metersPerDegLat;
      final dLon = radiusMeters /
          (metersPerDegLat * math.cos(lat * math.pi / 180.0))
              .abs()
              .clamp(1e-6, double.infinity);
      final minLat = lat - dLat;
      final maxLat = lat + dLat;
      final minLon = lon - dLon;
      final maxLon = lon + dLon;

      final resp = await client
          .from('mosque_list')
          .select(
              'id, mosque_name, latitude, longitude, city, address_desc, is_female_accessible, "googlePlaceId"')
          .gte('latitude', minLat)
          .lte('latitude', maxLat)
          .gte('longitude', minLon)
          .lte('longitude', maxLon);

      final rows =
          (resp as List?)?.whereType<Map<String, dynamic>>().toList() ??
              const [];
      if (rows.isEmpty) return null;
      // Find nearest by haversine distance
      Map<String, dynamic>? best;
      double bestDist = double.infinity;
      for (final r in rows) {
        final rLat = (r['latitude'] as num?)?.toDouble();
        final rLon = (r['longitude'] as num?)?.toDouble();
        if (rLat == null || rLon == null) continue;
        final d = _distanceKm(lat, lon, rLat, rLon);
        if (d < bestDist) {
          bestDist = d;
          best = r;
        }
      }
      return best;
    } catch (_) {
      return null;
    }
  }

  Future<List<_NearbyPlace>> _loadFromCache(double lat, double lon,
      {bool ignoreRadius = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cLat = prefs.getDouble('mnm_cache_center_lat');
      final cLon = prefs.getDouble('mnm_cache_center_lon');
      final data = prefs.getString('mnm_cache_places');
      if (cLat == null || cLon == null || data == null) return [];
      final distToCenter = _distanceKm(lat, lon, cLat, cLon);
      if (!ignoreRadius && distToCenter > 2.0) return [];
      final list = (json.decode(data) as List)
          .map((e) => _NearbyPlace(
                id: (e['id'] as num?)?.toInt(),
                name: e['name'] as String,
                address: (e['address'] ?? '') as String,
                lat: (e['lat'] as num).toDouble(),
                lon: (e['lon'] as num).toDouble(),
                distanceKm: 0,
                googlePlaceId: (e['gpid'] as String?)?.toString(),
                providerId: (e['pid'] as String?)?.toString(),
                femaleAllowed: (e['fa'] as bool?) ?? false,
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
          id: p.id,
          googlePlaceId: p.googlePlaceId,
          providerId: p.providerId,
          femaleAllowed: p.femaleAllowed,
        );
      }
      list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<void> _backgroundUpsertAndUpdate(List<_NearbyPlace> places) async {
    try {
      // Prepare conversion to service model
      final svcPlaces = places
          .map((p) => MasjidNearPlace(
                name: p.name,
                address: p.address,
                lat: p.lat,
                lon: p.lon,
                googlePlaceId: p.googlePlaceId,
                providerId: p.providerId,
                femaleAllowed: p.femaleAllowed,
              ))
          .toList();
      final maps = await MasjidNearService.syncToSupabaseNoUpdate(svcPlaces);
      if (maps.byGpid.isEmpty && maps.byProviderId.isEmpty) {
        return;
      }
      // Attach ids to matching places by googlePlaceId, then providerId
      bool changed = false;
      for (var i = 0; i < places.length; i++) {
        final gp = places[i].googlePlaceId;
        final pid = places[i].providerId;
        int? id;
        if (gp != null && gp.isNotEmpty) {
          id = maps.byGpid[gp];
        }
        id ??= (pid != null && pid.isNotEmpty) ? maps.byProviderId[pid] : null;
        final fa = (gp != null && gp.isNotEmpty)
            ? maps.femaleByGpid[gp]
            : ((pid != null && pid.isNotEmpty)
                ? maps.femaleByProviderId[pid]
                : null);
        if ((id != null && places[i].id != id) ||
            (fa != null && places[i].femaleAllowed != fa)) {
          places[i] = _NearbyPlace(
            id: id,
            name: places[i].name,
            address: places[i].address,
            lat: places[i].lat,
            lon: places[i].lon,
            distanceKm: places[i].distanceKm,
            femaleAllowed: fa ?? places[i].femaleAllowed,
            googlePlaceId: places[i].googlePlaceId,
            providerId: places[i].providerId,
          );
          changed = true;
        }
      }
      if (changed) {
        if (mounted) setState(() {});
        final loc = context.read<LocationProvider>();
        final pos = loc.position;
        if (pos != null) {
          await _saveCache(pos.latitude, pos.longitude, places);
        }
      }
    } catch (_) {}
  }

  // Events removed per UX

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final color1 = theme.primaryColor.withOpacity(0.3);
    final color2 = theme.scaffoldBackgroundColor;
    final color3 = theme.cardColor.withOpacity(0.3);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.scanResults),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          IgnorePointer(
            child: CustomPaint(
              size: Size.infinite,
              painter: AuroraBackgroundPainter(
                animation: _animationController,
                color1: color1,
                color2: color2,
                color3: color3,
              ),
            ),
          ),
          _buildMosquesTab(context),
        ],
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
  final int? id;
  final String name;
  final String address;
  final double lat;
  final double lon;
  final double distanceKm;
  final bool? femaleAllowed;
  final String? googlePlaceId;
  final String? providerId;
  _NearbyPlace({
    this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lon,
    required this.distanceKm,
    this.femaleAllowed,
    this.googlePlaceId,
    this.providerId,
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
    final filtered = _query.isEmpty
        ? _places
        : _places
            .where((p) =>
                p.name.toLowerCase().contains(_query.toLowerCase()) ||
                p.address.toLowerCase().contains(_query.toLowerCase()))
            .toList();
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      itemCount: filtered.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchHint,
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).cardColor.withOpacity(0.6),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          );
        }
        final place = filtered[index - 1];
        return InkWell(
          onTap: () {
            final address = place.address.isEmpty
                ? '${place.lat.toStringAsFixed(4)}, ${place.lon.toStringAsFixed(4)}'
                : place.address;
            final fallbackTimes = <String, JamatTimeDetails>{
              'Fajr': JamatTimeDetails(jamatTime: '--:--'),
              'Dhuhr': JamatTimeDetails(jamatTime: '--:--'),
              'Asr': JamatTimeDetails(jamatTime: '--:--'),
              'Maghrib': JamatTimeDetails(jamatTime: '--:--'),
              'Isha': JamatTimeDetails(jamatTime: '--:--'),
            };
            final mosque = Mosque(
              id: place.id,
              name: place.name,
              address: address,
              latitude: place.lat,
              longitude: place.lon,
              googlePlaceId: place.googlePlaceId,
              provider: 'masjidnear.me',
              providerId: place.providerId,
              isFemaleAccessible: place.femaleAllowed ?? false,
              lastUpdatedAt: DateTime.now(),
              lastUpdatedBy: 'MasjidNear',
              jamatTimes: fallbackTimes,
            );
            if (widget.onMosqueSelected != null) {
              widget.onMosqueSelected!(mosque);
              // Don't pop if callback is provided - let the parent handle navigation
              return;
            }

            if (!context.mounted) return;
            Navigator.pop(context, mosque);
          },
          child: Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: Theme.of(context).cardColor.withOpacity(0.8),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(0.1),
                    foregroundColor: Theme.of(context).primaryColor,
                    child: const Icon(Icons.mosque_outlined),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(place.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontSize: 18)),
                        const SizedBox(height: 4),
                        if (place.address.isNotEmpty)
                          Text(place.address,
                              style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _chip(context,
                                "${place.distanceKm.toStringAsFixed(2)} km"),
                            if (place.femaleAllowed == true)
                              _chip(context, "Women allowed"),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward_ios,
                      color: Theme.of(context).primaryColor, size: 18),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
