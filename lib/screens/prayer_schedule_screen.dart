import 'package:flutter/material.dart';

class PrayerScheduleScreen extends StatelessWidget {
  final Map<String, String> prayerSchedule;

  const PrayerScheduleScreen({super.key, required this.prayerSchedule});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('General Prayer Schedule'),
        backgroundColor: const Color(0xFF0A0E21),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monday, September 1, 2025\nChattogram, Bangladesh',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              itemCount: prayerSchedule.length,
              itemBuilder: (context, index) {
                final prayerName = prayerSchedule.keys.elementAt(index);
                final prayerTime = prayerSchedule.values.elementAt(index);
                return Card(
                  color: const Color(0xFF1D1E33),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.timer_outlined, color: Colors.tealAccent),
                    title: Text(prayerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Text(prayerTime, style: const TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}