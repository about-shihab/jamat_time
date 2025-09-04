import 'package:flutter/material.dart';

class PrayerDashboardCard extends StatelessWidget {
  final String prayerName;
  final String jamatTime;
  final String prayerTimeRange;
  final bool isAlarmSet;
  final VoidCallback onAlarmPressed;

  const PrayerDashboardCard({
    super.key,
    required this.prayerName,
    required this.jamatTime,
    required this.prayerTimeRange,
    required this.isAlarmSet,
    required this.onAlarmPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Theme.of(context).cardColor.withOpacity(0.8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            // Prayer Name
            Expanded(
              flex: 2,
              child: Text(prayerName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
            ),
            // Times
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(jamatTime, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22, color: Theme.of(context).primaryColor)),
                  Text(prayerTimeRange, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            // Alarm Button
            IconButton(
              icon: Icon(isAlarmSet ? Icons.notifications_active : Icons.notifications_none_outlined),
              color: isAlarmSet ? Theme.of(context).hintColor : Colors.grey,
              onPressed: onAlarmPressed,
            ),
          ],
        ),
      ),
    );
  }
}