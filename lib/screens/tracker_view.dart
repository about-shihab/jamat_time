import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/prayer_record.dart';

class TrackerView extends StatefulWidget {
  const TrackerView({super.key});

  @override
  State<TrackerView> createState() => _TrackerViewState();
}

class _TrackerViewState extends State<TrackerView> {
  // Mock data for the last 7 days
  late List<PrayerRecord> _weekRecords;
  final List<String> _prayerNames = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"];

  @override
  void initState() {
    super.initState();
    _weekRecords = List.generate(7, (i) {
      final date = DateTime.now().subtract(Duration(days: i));
      // Randomly mark some as prayed for demonstration
      final prayed = (i % 2 == 0) ? {0, 1, 3, 4} : {0, 1, 2};
      return PrayerRecord(date: date, prayedIndices: prayed);
    }).reversed.toList();
  }
  
  void _togglePrayer(int dayIndex, int prayerIndex) {
    setState(() {
      final record = _weekRecords[dayIndex];
      if (record.prayedIndices.contains(prayerIndex)) {
        record.prayedIndices.remove(prayerIndex);
      } else {
        record.prayedIndices.add(prayerIndex);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final todayRecord = _weekRecords.last;
    final double completion = todayRecord.prayedIndices.length / 5.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Namaz Tracker')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Daily Progress Circle
            Center(
              child: SizedBox(
                width: 150, height: 150,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(width: 150, height: 150, child: CircularProgressIndicator(value: completion, strokeWidth: 8, backgroundColor: Colors.grey.withOpacity(0.2))),
                    Text("${(completion * 100).toInt()}%", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 32)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(child: Text("Today's Progress", style: Theme.of(context).textTheme.bodyMedium)),
            const SizedBox(height: 30),
            // Weekly Tracker List
            ..._weekRecords.asMap().entries.map((entry) => _buildDayRow(entry.key, entry.value)),
          ],
        ),
      ),
    );
  }

  Widget _buildDayRow(int dayIndex, PrayerRecord record) {
    final isToday = DateFormat.yMd().format(record.date) == DateFormat.yMd().format(DateTime.now());
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
        border: isToday ? Border.all(color: Theme.of(context).primaryColor) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(DateFormat('EEEE, d MMM').format(record.date), style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (prayerIndex) {
              final isPrayed = record.prayedIndices.contains(prayerIndex);
              return GestureDetector(
                onTap: () => _togglePrayer(dayIndex, prayerIndex),
                child: Column(children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: isPrayed ? Theme.of(context).primaryColor : Colors.grey.withOpacity(0.3),
                    child: isPrayed ? const Icon(Icons.check, color: Colors.white) : null,
                  ),
                  const SizedBox(height: 4),
                  Text(_prayerNames[prayerIndex], style: const TextStyle(fontSize: 10)),
                ]),
              );
            }),
          ),
        ],
      ),
    );
  }
}