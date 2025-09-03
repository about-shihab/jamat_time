import 'package:flutter/material.dart';

class NextJamatCard extends StatelessWidget {
  final String prayerName;
  final String prayerTime;
  final Duration? countdown;

  const NextJamatCard({
    super.key,
    required this.prayerName,
    required this.prayerTime,
    this.countdown,
  });

  String _formatDuration(Duration d) {
    if (d.isNegative) return "Time has passed";
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    return 'in ${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // FIX: Using standard theme property
          color: Theme.of(context).cardColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Next Jamat',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              prayerName,
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              prayerTime,
              style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              countdown != null ? _formatDuration(countdown!) : 'Calculating...',
              // FIX: Using standard theme property (hintColor is our gold)
              style: TextStyle(color: Theme.of(context).hintColor, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}