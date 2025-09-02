import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jamat_time/models/jamat_time_details.dart';
import 'package:jamat_time/notification_service.dart';
import 'package:jamat_time/screens/discover_screen.dart';
import 'package:jamat_time/theme_provider.dart';
import 'package:jamat_time/widgets/islamic_background_painter.dart';
import 'package:jamat_time/widgets/mosque_header.dart';
import 'package:jamat_time/widgets/prayer_time_card.dart';
import '../models/mosque_model.dart';
import 'package:jamat_time/widgets/hadith_slider.dart';

class JamatTimeView extends StatefulWidget {
  const JamatTimeView({super.key});

  @override
  State<JamatTimeView> createState() => _JamatTimeViewState();
}

class _JamatTimeViewState extends State<JamatTimeView> {
  Mosque? _favoriteMosque;
  final TextEditingController _minutesController = TextEditingController(text: "15");
  final Set<String> _alarmsSet = {}; // To track which prayers have alarms

  final Map<String, String> _prayerTimeRanges = {
    'Fajr': '04:28 - 05:43', 'Dhuhr': '12:01 - 16:25', 'Asr': '16:25 - 18:19',
    'Maghrib': '18:19 - 19:34', 'Isha': '19:34 - 04:27',
  };

  @override
  void dispose() {
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          size: Size.infinite,
          painter: IslamicBackgroundPainter(context: context),
        ),
        _favoriteMosque == null ? _buildInitialView() : _buildFavoriteMosqueView(),
      ],
    );
  }

  void _navigateAndSetFavorite() async {
    final result = await Navigator.push(
      context, MaterialPageRoute(builder: (context) => const DiscoverScreen()));
    if (result != null && result is Mosque) {
      setState(() => _favoriteMosque = result);
    }
  }

  void _showSetAlarmDialog(String prayerName, String timeStr) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Set Reminder', style: Theme.of(context).textTheme.titleLarge),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Remind me before $prayerName Jamat.', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          TextField(
            controller: _minutesController, keyboardType: TextInputType.number, autofocus: true,
            decoration: const InputDecoration(labelText: 'Minutes before', border: OutlineInputBorder()),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final prayerTime = _parsePrayerTime(timeStr);
              final minutes = int.tryParse(_minutesController.text) ?? 15;
              NotificationService().scheduleNotification(prayerName, prayerTime, minutes);
              setState(() => _alarmsSet.add(prayerName)); // Add prayer to alarms set
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Reminder set for $prayerName.'),
                backgroundColor: AppTheme.accentColor,
              ));
            },
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }

  DateTime _parsePrayerTime(String timeStr) {
    final now = DateTime.now();
    final parts = timeStr.replaceAll(RegExp(r'\s*(AM|PM)'), '').split(':');
    int hour = int.parse(parts[0]);
    final int minute = int.parse(parts[1]);
    if (timeStr.contains('PM') && hour != 12) hour += 12;
    if (timeStr.contains('AM') && hour == 12) hour = 0;
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  Widget _buildInitialView() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.track_changes, size: 100, color: Colors.grey),
        const SizedBox(height: 20),
        Text('Scan for Nearby Mosques', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24)),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: _navigateAndSetFavorite,
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16)),
          child: const Text('SCAN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }

 Widget _buildFavoriteMosqueView() {
  final DateFormat formatter = DateFormat('MMM d, yyyy');
  return ListView(
    padding: const EdgeInsets.symmetric(vertical: 8), // Adjusted padding
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: MosqueHeader(mosque: _favoriteMosque!),
      ),
      const SizedBox(height: 16),
      
      // --- HADITH SLIDER WIDGET ADDED HERE ---
      const HadithSlider(),
      const SizedBox(height: 20),

      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          'Last updated by ${_favoriteMosque!.lastUpdatedBy} on ${formatter.format(_favoriteMosque!.lastUpdatedAt)}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
        ),
      ),
      const SizedBox(height: 12),
      ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _favoriteMosque!.jamatTimes.length,
        itemBuilder: (context, index) {
          final prayerName = _favoriteMosque!.jamatTimes.keys.elementAt(index);
          final details = _favoriteMosque!.jamatTimes.values.elementAt(index);
          final prayerRange = _prayerTimeRanges[prayerName] ?? 'N/A';
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: SizedBox(
              height: 85,
              child: InkWell(
                onTap: () => _showSetAlarmDialog(prayerName, details.jamatTime),
                child: PrayerTimeCard(
                  prayerName: prayerName,
                  details: details,
                  prayerTimeRange: prayerRange,
                  icon: getIconForPrayer(prayerName),
                  isAlarmSet: _alarmsSet.contains(prayerName),
                ),
              ),
            ),
          );
        },
      ),
      const SizedBox(height: 80),
    ],
  );
}

  IconData getIconForPrayer(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr': return Icons.wb_twilight_outlined;
      case 'dhuhr': return Icons.wb_sunny_outlined;
      case 'asr': return Icons.filter_drama_outlined;
      case 'maghrib': return Icons.wb_sunny;
      case 'isha': return Icons.nightlight_round_outlined;
      case 'sunrise': return Icons.brightness_high;
      default: return Icons.access_time;
    }
  }
}