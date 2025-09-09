import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:jamat_time/models/mosque_model.dart';
import 'package:jamat_time/widgets/custom_app_bar.dart';
import 'package:jamat_time/widgets/prayer_glance_item.dart';
import 'package:jamat_time/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:jamat_time/providers/prayer_times_provider.dart';
import 'package:jamat_time/screens/scan_results_screen.dart';
import 'package:jamat_time/screens/landing_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:jamat_time/services/jamat_time_service.dart';
import 'package:jamat_time/widgets/next_jamat_card.dart';

class HomeView extends StatefulWidget {
  final Mosque favoriteMosque;
  const HomeView({super.key, required this.favoriteMosque});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Fallback static times until fetched from API
  final Map<String, String> _fallbackPrayerTimes = const {
    'Fajr': '--:--',
    'Dhuhr': '--:--',
    'Asr': '--:--',
    'Maghrib': '--:--',
    'Isha': '--:--'
  };

  Map<String, String>? _jamatTimes; // fetched from Supabase by mosque id
  Map<String, String> get _effectiveJamatTimes => _jamatTimes ??
      widget.favoriteMosque.jamatTimes.map((k, v) => MapEntry(k, v.jamatTime));

  Future<void> _handleSync() async {
    // Rescan nearby mosques: open results directly and replace MainScreen on choice
    final selected = await Navigator.push<Mosque>(
      context,
      MaterialPageRoute(builder: (context) => ScanResultsScreen()),
    );
    if (selected != null && context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LandingScreen(initialMosque: selected)),
        (route) => false,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadJamatTimes();
  }

  @override
  void didUpdateWidget(covariant HomeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.favoriteMosque.id != widget.favoriteMosque.id) {
      _jamatTimes = null;
      _loadJamatTimes();
    }
  }

  Future<void> _loadJamatTimes() async {
    final id = widget.favoriteMosque.id;
    if (id == null) return;
    try {
      final map = await JamatTimeService.fetchForMosque(id);
      if (!mounted) return;
      if (map.isNotEmpty) {
        setState(() {
          _jamatTimes = map.map((k, v) => MapEntry(k, v.jamatTime));
        });
      }
    } catch (_) {
      // ignore: keep fallback
    }
  }

  String? _computeNextJamat() {
    final now = DateTime.now();
    DateTime? bestTime;
    String? bestName;
    final jt = _effectiveJamatTimes;
    for (final entry in jt.entries) {
      final parsed = _parseToToday(entry.value);
      if (parsed == null) continue;
      if (parsed.isAfter(now) && (bestTime == null || parsed.isBefore(bestTime))) {
        bestTime = parsed;
        bestName = entry.key;
      }
    }
    if (bestTime == null || bestName == null) return null;
    return '$bestName|${_format12h(_hhmm(bestTime))}';
  }

  DateTime? _parseToToday(String hhmm) {
    try {
      if (hhmm.contains('AM') || hhmm.contains('PM')) {
        // Normalize to 24h
        final parts = hhmm.split(' ');
        final t = parts[0];
        final ampm = parts.length > 1 ? parts[1].toUpperCase() : '';
        final p = t.split(':');
        int h = int.parse(p[0]);
        final m = int.parse(p[1]);
        if (ampm == 'PM' && h != 12) h += 12;
        if (ampm == 'AM' && h == 12) h = 0;
        final n = DateTime.now();
        return DateTime(n.year, n.month, n.day, h, m);
      }
      final p = hhmm.split(':');
      final h = int.parse(p[0]);
      final m = int.parse(p[1]);
      final n = DateTime.now();
      return DateTime(n.year, n.month, n.day, h, m);
    } catch (_) {
      return null;
    }
  }

  String _hhmm(DateTime dt) => '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  Future<void> _handleTrackMosque() async {
    final l10n = AppLocalizations.of(context)!;
    final lat = widget.favoriteMosque.latitude;
    final lon = widget.favoriteMosque.longitude;
    final address = widget.favoriteMosque.address;

    if ((lat == null || lon == null) && (address == null || address.isEmpty)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location data not available for this mosque.")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.openingMaps)),
    );

    // Prioritize lat/lon for accuracy
    final String query;
    if (lat != null && lon != null) {
      query = '$lat,$lon';
    } else {
      query = Uri.encodeComponent(address!);
    }
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open maps application.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final timings = context.watch<PrayerTimesProvider>().timings;
    final times = timings ?? _fallbackPrayerTimes;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 20),
            // Mosque Header with Islamic Design
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  // Islamic decorative line
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor.withOpacity(0),
                                Theme.of(context).primaryColor.withOpacity(0.5),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: CustomPaint(
                          size: const Size(40, 20),
                          painter: IslamicShapePainter(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor.withOpacity(0.5),
                                Theme.of(context).primaryColor.withOpacity(0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Mosque Name Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Track Icon
                      IconButton(
                        onPressed: _handleTrackMosque,
                        icon: Icon(
                          Icons.directions_outlined,
                          color: Theme.of(context).primaryColor,
                          size: 24,
                        ),
                        tooltip: l10n.getDirections,
                      ),
                      // Mosque Name
                      Expanded(
                        child: Text(
                          widget.favoriteMosque.name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Rescan Nearby Mosques
                      IconButton(
                        onPressed: _handleSync,
                        icon: Icon(
                          Icons.travel_explore,
                          color: Theme.of(context).primaryColor,
                          size: 24,
                        ),
                        tooltip: l10n.rescanNearby,
                      ),
                    ],
                  ),
                  if (widget.favoriteMosque.address != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.favoriteMosque.address!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withOpacity(0.6),
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Islamic decorative line bottom
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor.withOpacity(0),
                                Theme.of(context).primaryColor.withOpacity(0.5),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor.withOpacity(0.5),
                                Theme.of(context).primaryColor.withOpacity(0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Next Jamat Card (if jamat times available)
            Builder(builder: (context){
              final next = _computeNextJamat();
              if (next == null) return const SizedBox.shrink();
              final parts = next.split('|');
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: NextJamatCard(
                  prayerName: _localizedPrayerName(l10n, parts[0]),
                  prayerTime: parts[1],
                ),
              );
            }),
            // Prayer Times Title

            // Prayer Times List using original PrayerGlanceItem
            ...times.keys.where((k) => ['Fajr','Dhuhr','Asr','Maghrib','Isha'].contains(k)).map((prayerName) => PrayerGlanceItem(
                  prayerName: _localizedPrayerName(l10n, prayerName),
                  prayerTime: _format12h(times[prayerName]!),
                  prayerEnd: _format12h(_endFor(prayerName, times)),
                  jamatTime: _format12h(
                      _effectiveJamatTimes[prayerName] ?? '--:--'
                  ),
                  icon: getIconForPrayer(prayerName),
                )),
          ],
        ),
      ),
    );
  }

  IconData getIconForPrayer(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return Icons.wb_twilight_outlined;
      case 'dhuhr':
        return Icons.wb_sunny_outlined;
      case 'asr':
        return Icons.filter_drama_outlined;
      case 'maghrib':
        return Icons.wb_sunny;
      case 'isha':
        return Icons.nightlight_round_outlined;
      default:
        return Icons.access_time;
    }
  }
}

String _format12h(String time24) {
  // Accept "HH:mm" or already formatted values
  if (time24.contains('AM') || time24.contains('PM') || time24 == '--:--') return time24;
  try {
    final parts = time24.split(':');
    int h = int.parse(parts[0]);
    final m = parts[1];
    final am = h < 12;
    if (h == 0) h = 12; else if (h > 12) h -= 12;
    return '${h.toString().padLeft(2, '0')}:$m ${am ? 'AM' : 'PM'}';
  } catch (_) {
    return time24;
  }
}

String _endFor(String prayer, Map<String, String> t) {
  switch (prayer) {
    case 'Fajr':
      return t['Sunrise'] ?? '--:--';
    case 'Dhuhr':
      return t['Asr'] ?? '--:--';
    case 'Asr':
      return t['Maghrib'] ?? '--:--';
    case 'Maghrib':
      return t['Isha'] ?? '--:--';
    case 'Isha':
      return t['Midnight'] ?? '--:--';
    default:
      return '--:--';
  }
}

// Custom painter for Islamic decorative shape
String _localizedPrayerName(AppLocalizations l10n, String key){
  switch (key) {
    case 'Fajr': return l10n.prayerFajr;
    case 'Dhuhr': return l10n.prayerDhuhr;
    case 'Asr': return l10n.prayerAsr;
    case 'Maghrib': return l10n.prayerMaghrib;
    case 'Isha': return l10n.prayerIsha;
    default: return key;
  }
}

class IslamicShapePainter extends CustomPainter {
  final Color color;
  final bool isInverted;

  IslamicShapePainter({
    required this.color,
    this.isInverted = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    if (!isInverted) {
      // Top shape
      path.moveTo(size.width * 0.5, 0);
      path.quadraticBezierTo(0, size.height * 0.5, 0, size.height);
      path.lineTo(size.width, size.height);
      path.quadraticBezierTo(
          size.width, size.height * 0.5, size.width * 0.5, 0);
    } else {
      // Bottom shape (inverted)
      path.moveTo(0, 0);
      path.quadraticBezierTo(
          0, size.height * 0.5, size.width * 0.5, size.height);
      path.quadraticBezierTo(size.width, size.height * 0.5, size.width, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
