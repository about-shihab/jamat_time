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

  Future<void> _handleTrackMosque() async {
    final l10n = AppLocalizations.of(context)!;
    final address = widget.favoriteMosque.address;

    if (address == null || address.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Address not available to show on map.")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.openingMaps)),
    );

    final query = Uri.encodeComponent(address);
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
            // Prayer Times Title

            // Prayer Times List using original PrayerGlanceItem
            ...times.keys.where((k) => ['Fajr','Dhuhr','Asr','Maghrib','Isha'].contains(k)).map((prayerName) => PrayerGlanceItem(
                  prayerName: _localizedPrayerName(l10n, prayerName),
                  prayerTime: _format12h(times[prayerName]!),
                  prayerEnd: _format12h(_endFor(prayerName, times)),
                  jamatTime:
                      widget.favoriteMosque.jamatTimes[prayerName]?.jamatTime ??
                          '--:--',
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
