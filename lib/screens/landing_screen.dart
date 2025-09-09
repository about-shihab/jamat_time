import 'package:flutter/material.dart';
import 'package:jamat_time/models/mosque_model.dart';
import 'package:jamat_time/screens/main_screen.dart';
// Removed ScanView from landing flow per new UX (show results directly)
import 'package:jamat_time/widgets/aurora_background_painter.dart';
import 'package:provider/provider.dart';
import 'package:jamat_time/locale_provider.dart';
import 'package:jamat_time/models/jamat_time_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jamat_time/screens/scan_results_screen.dart';
import 'package:jamat_time/providers/location_provider.dart';
import 'package:jamat_time/providers/prayer_times_provider.dart';
import 'dart:async';
import 'dart:convert';
import 'package:jamat_time/services/jamat_time_service.dart';

class LandingScreen extends StatefulWidget {
  final Mosque? initialMosque;
  const LandingScreen({super.key, this.initialMosque});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> with SingleTickerProviderStateMixin {
  Mosque? _favoriteMosque;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 40))..repeat();
    // If a mosque was provided (e.g., reselect flow), set it immediately and persist
    if (widget.initialMosque != null) {
      _favoriteMosque = widget.initialMosque;
      // Enrich with Supabase jamat times if available
      unawaited(_enrichFavoriteWithJamatTimes());
      unawaited(_saveFavorite(_favoriteMosque!));
      SharedPreferences.getInstance().then((prefs) => prefs.setBool('has_favorite', true));
    }
    // After language selection: if no favorite chosen before, show scan results.
    // Otherwise, show nearest mosque immediately.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final localeProvider = context.read<LocaleProvider>();
      // Always try to get location and fetch prayer times in background
      unawaited(_ensureLocationAndTimings());
      if (!localeProvider.hasChosenLanguage) return;
      final prefs = await SharedPreferences.getInstance();
      final hasFavorite = prefs.getBool('has_favorite') ?? false;
      if (!hasFavorite && widget.initialMosque == null) {
        if (!mounted) return;
        // Navigate to scan results and wait for selection.
        final selected = await Navigator.push<Mosque>(
          context,
          MaterialPageRoute(
            builder: (context) => ScanResultsScreen(),
          ),
        );
        if (selected != null && mounted) {
          await onMosqueFavorited(selected);
        }
      } else if (_favoriteMosque == null) {
        final saved = await _loadFavorite();
        if (saved != null && mounted) {
          setState(() => _favoriteMosque = saved);
          await _enrichFavoriteWithJamatTimes();
        } else {
          setState(() => _favoriteMosque = _getNearestMockedMosque());
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> onMosqueFavorited(Mosque mosque) async {
    // Set immediately for snappy UX
    if (mounted) setState(() => _favoriteMosque = mosque);
    SharedPreferences.getInstance().then((prefs) => prefs.setBool('has_favorite', true));
    await _saveFavorite(mosque);
    // Then enrich with jamat times from Supabase if mosque has id
    await _enrichFavoriteWithJamatTimes();
  }

  Future<void> _enrichFavoriteWithJamatTimes() async {
    final current = _favoriteMosque;
    if (current == null) return;
    final id = current.id;
    if (id == null) return; // OSM-only mosque, no Supabase id
    try {
      final map = await JamatTimeService.fetchForMosque(id);
      if (map.isEmpty) return;
      final enriched = Mosque(
        id: current.id,
        name: current.name,
        address: current.address,
        latitude: current.latitude,
        longitude: current.longitude,
        city: current.city,
        district: current.district,
        isFemaleAccessible: current.isFemaleAccessible,
        createdBy: current.createdBy,
        createdAt: current.createdAt,
        jamatTimes: map,
        lastUpdatedAt: DateTime.now(),
        lastUpdatedBy: 'Supabase',
      );
      if (!mounted) return;
      setState(() => _favoriteMosque = enriched);
    } catch (_) {
      // keep existing
    }
  }

  Future<void> _saveFavorite(Mosque m) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final map = <String, dynamic>{
        'id': m.id,
        'name': m.name,
        'address': m.address,
        'lat': m.latitude,
        'lon': m.longitude,
        'city': m.city,
        'district': m.district,
        'fa': m.isFemaleAccessible,
      };
      await prefs.setString('favorite_mosque', json.encode(map));
    } catch (_) {}
  }

  Future<Mosque?> _loadFavorite() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('favorite_mosque');
      if (raw == null) return null;
      final m = json.decode(raw) as Map<String, dynamic>;
      return Mosque(
        id: (m['id'] as num?)?.toInt(),
        name: (m['name'] ?? 'Mosque').toString(),
        address: m['address'] as String?,
        latitude: (m['lat'] as num?)?.toDouble(),
        longitude: (m['lon'] as num?)?.toDouble(),
        city: m['city'] as String?,
        district: m['district'] as String?,
        isFemaleAccessible: (m['fa'] as bool?) ?? false,
        jamatTimes: const {},
        lastUpdatedAt: DateTime.now(),
        lastUpdatedBy: 'Saved',
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _ensureLocationAndTimings() async {
    final loc = context.read<LocationProvider>();
    await loc.ensureLocation();
    if (loc.position != null) {
      final pt = context.read<PrayerTimesProvider>();
      await pt.fetchByLatLng(loc.position!.latitude, loc.position!.longitude);
    }
  }

  Mosque _getNearestMockedMosque() {
    return Mosque(
      name: 'Baitul Falah Mosque',
      address: 'WASA Circle, Chattogram',
      latitude: 22.3569,
      longitude: 91.8333,
      lastUpdatedAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      lastUpdatedBy: 'A. Khan',
      jamatTimes: {
        'Fajr': JamatTimeDetails(jamatTime: '05:10 AM'),
        'Dhuhr': JamatTimeDetails(jamatTime: '01:35 PM'),
        'Asr': JamatTimeDetails(jamatTime: '05:05 PM'),
        'Maghrib': JamatTimeDetails(jamatTime: '06:22 PM'),
        'Isha': JamatTimeDetails(jamatTime: '08:05 PM'),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // FIX: Get the colors from the theme here, in the build method.
    final theme = Theme.of(context);
    final color1 = theme.primaryColor.withOpacity(0.3);
    final color2 = theme.scaffoldBackgroundColor;
    final color3 = theme.cardColor.withOpacity(0.3);

    return Scaffold(
      body: Stack(
        children: [
          IgnorePointer(
            child: CustomPaint(
              size: Size.infinite,
              // FIX: Pass the colors directly to the painter, not the context.
              painter: AuroraBackgroundPainter(
                animation: _animationController,
                color1: color1,
                color2: color2,
                color3: color3,
              ),
            ),
          ),
          _favoriteMosque == null
              ? const SizedBox.shrink()
              : MainScreen(favoriteMosque: _favoriteMosque!),
        ],
      ),
    );
  }
}
