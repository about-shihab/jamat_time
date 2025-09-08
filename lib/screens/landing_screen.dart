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
          onMosqueFavorited(selected);
        }
      } else if (_favoriteMosque == null) {
        setState(() => _favoriteMosque = _getNearestMockedMosque());
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void onMosqueFavorited(Mosque mosque) {
    setState(() => _favoriteMosque = mosque);
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setBool('has_favorite', true),
    );
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
