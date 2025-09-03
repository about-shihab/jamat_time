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
  final Map<String, String> _prayerTimes = { 'Fajr': '04:29 AM', 'Dhuhr': '12:01 PM', 'Asr': '04:25 PM', 'Maghrib': '06:18 PM', 'Isha': '07:33 PM' };

  @override
  Widget build(BuildContext context) {
    final hijriDate = HijriCalendar.now().toFormat("d MMMM yyyy");

    return Scaffold(
      backgroundColor: Colors.transparent,
      // FIX: AppBar is now customized for the Home screen
      appBar: CustomAppBar(
        title: widget.favoriteMosque.name,
        showHadith: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            Center(
              child: Text(
                "Today, ${DateFormat('d MMMM').format(DateTime.now())} | $hijriDate",
                style: Theme.of(context).textTheme.bodyMedium
              ),
            ),
            const SizedBox(height: 20),
            // "At a Glance" List
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