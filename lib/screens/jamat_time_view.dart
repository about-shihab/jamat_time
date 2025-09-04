import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jamat_time/models/mosque_model.dart';
import 'package:jamat_time/notification_service.dart';
import 'package:jamat_time/widgets/prayer_dashboard_card.dart';

class JamatTimeView extends StatefulWidget {
  final Mosque mosque;
  const JamatTimeView({super.key, required this.mosque});

  @override
  State<JamatTimeView> createState() => _JamatTimeViewState();
}

class _JamatTimeViewState extends State<JamatTimeView> {
  final Set<String> _alarmsSet = {};
  final TextEditingController _minutesController = TextEditingController(text: "15");
  
  // ACCURATE PRAYER TIME RANGES FOR CHATTOGRAM - SEP 3, 2025
  final Map<String, String> _prayerTimeRanges = {
    'Fajr': '04:29 - 05:44',
    'Dhuhr': '12:01 - 16:25',
    'Asr': '16:25 - 18:18',
    'Maghrib': '18:18 - 19:33',
    'Isha': '19:33 - 04:28',
  };
  
  @override
  void dispose() {
    _minutesController.dispose();
    super.dispose();
  }

  void _toggleAlarm(String prayerName) {
    if (_alarmsSet.contains(prayerName)) {
      setState(() {
        _alarmsSet.remove(prayerName);
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Reminder for $prayerName cancelled.'),
      ));
    } else {
      _showSetAlarmDialog(prayerName, widget.mosque.jamatTimes[prayerName]!.jamatTime);
    }
  }

  void _showSetAlarmDialog(String prayerName, String timeStr) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Set Reminder', style: Theme.of(context).textTheme.titleLarge),
        content: TextField(
          controller: _minutesController,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Minutes before Jamat', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final prayerTime = _parseTime(timeStr);
              final minutes = int.tryParse(_minutesController.text) ?? 15;
              NotificationService().scheduleNotification(prayerName, prayerTime, minutes);
              setState(() => _alarmsSet.add(prayerName));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Reminder set for $prayerName.'),
                backgroundColor: Theme.of(context).primaryColor,
              ));
            },
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }

  DateTime _parseTime(String timeStr) {
    final now = DateTime.now();
    final parts = timeStr.replaceAll(RegExp(r'\s*(AM|PM)'), '').split(':');
    int hour = int.parse(parts[0]);
    final int minute = int.parse(parts[1]);
    if (timeStr.contains('PM') && hour != 12) hour += 12;
    if (timeStr.contains('AM') && hour == 12) hour = 0;
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('MMM d, hh:mm a');
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.mosque.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24)),
            Text(
              "Updated by ${widget.mosque.lastUpdatedBy} on ${formatter.format(widget.mosque.lastUpdatedAt)}",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildPrayerCard('Fajr')),
            Expanded(child: _buildPrayerCard('Dhuhr')),
            Expanded(child: _buildPrayerCard('Asr')),
            Expanded(child: _buildPrayerCard('Maghrib')),
            Expanded(child: _buildPrayerCard('Isha')),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerCard(String prayerName) {
    return PrayerDashboardCard(
      prayerName: prayerName,
      jamatTime: widget.mosque.jamatTimes[prayerName]?.jamatTime ?? '--:--',
      prayerTimeRange: _prayerTimeRanges[prayerName] ?? 'N/A',
      isAlarmSet: _alarmsSet.contains(prayerName),
      onAlarmPressed: () => _toggleAlarm(prayerName),
    );
  }
}