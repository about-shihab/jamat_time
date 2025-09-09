import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:jamat_time/models/mosque_model.dart';
import 'package:jamat_time/widgets/custom_app_bar.dart';
import 'package:jamat_time/widgets/prayer_glance_item.dart';

class HomeView extends StatefulWidget {
  final Mosque favoriteMosque;
  const HomeView({super.key, required this.favoriteMosque});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Mock Prayer Times for Chattogram - September 3, 2025
  final Map<String, String> _prayerTimes = { 
    'Fajr': '04:29 AM', 
    'Dhuhr': '12:01 PM', 
    'Asr': '04:25 PM', 
    'Maghrib': '06:18 PM', 
    'Isha': '07:33 PM' 
  };

  void _handleSync() {
    // Navigate to scan screen or sync data
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Syncing prayer times...')),
    );
  }

  void _handleTrackMosque() {
    // Add your map navigation logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening maps...')),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                        tooltip: 'Get Directions',
                      ),
                      // Mosque Name
                      Expanded(
                        child: Text(
                          widget.favoriteMosque.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Sync Icon
                      IconButton(
                        onPressed: _handleSync,
                        icon: Icon(
                          Icons.sync,
                          color: Theme.of(context).primaryColor,
                          size: 24,
                        ),
                        tooltip: 'Sync Prayer Times',
                      ),
                    ],
                  ),
                  if (widget.favoriteMosque.address != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.favoriteMosque.address!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        
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
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Prayer Times',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Prayer Times List using original PrayerGlanceItem
            ..._prayerTimes.keys.map((prayerName) => PrayerGlanceItem(
                prayerName: prayerName,
                prayerTime: _prayerTimes[prayerName]!,
                jamatTime: widget.favoriteMosque.jamatTimes[prayerName]?.jamatTime ?? '--:--',
                icon: getIconForPrayer(prayerName),
              )),
          ],
        ),
      ),
    );
  }

  IconData getIconForPrayer(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr': return Icons.wb_twilight_outlined;
      case 'dhuhr': return Icons.wb_sunny_outlined;
      case 'asr': return Icons.filter_drama_outlined;
      case 'maghrib': return Icons.wb_sunny;
      case 'isha': return Icons.nightlight_round_outlined;
      default: return Icons.access_time;
    }
  }
}

// Custom painter for Islamic decorative shape
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
      path.quadraticBezierTo(size.width, size.height * 0.5, size.width * 0.5, 0);
    } else {
      // Bottom shape (inverted)
      path.moveTo(0, 0);
      path.quadraticBezierTo(0, size.height * 0.5, size.width * 0.5, size.height);
      path.quadraticBezierTo(size.width, size.height * 0.5, size.width, 0);
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}