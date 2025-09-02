import 'package:flutter/material.dart';
import '../models/jamat_time_details.dart'; // <-- FIX: Corrected the relative import path
import 'package:jamat_time/theme_provider.dart';

class PrayerTimeCard extends StatelessWidget {
  final String prayerName;
  final JamatTimeDetails details;
  final String prayerTimeRange;
  final IconData icon;
  final bool isAlarmSet;

  const PrayerTimeCard({
    super.key,
    required this.prayerName,
    required this.details,
    required this.prayerTimeRange,
    required this.icon,
    this.isAlarmSet = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [AppTheme.accentColor.withOpacity(0.9), AppTheme.accentColor],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    prayerName.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      prayerTimeRange,
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  details.jamatTime,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                if (isAlarmSet)
                  const Icon(Icons.alarm_on, color: AppTheme.accentGold, size: 18)
                else
                  const SizedBox(height: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}