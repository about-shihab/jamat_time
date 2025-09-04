import 'package:flutter/material.dart';

class PrayerGlanceItem extends StatelessWidget {
  final String prayerName;
  final String prayerTime;
  final String jamatTime;
  final IconData icon;
  final bool isNext;

  const PrayerGlanceItem({
    super.key,
    required this.prayerName,
    required this.prayerTime,
    required this.jamatTime,
    required this.icon,
    this.isNext = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(isNext ? 1.0 : 0.5),
        borderRadius: BorderRadius.circular(15),
        border: isNext ? Border.all(color: Theme.of(context).primaryColor, width: 2) : null,
        boxShadow: isNext ? [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ] : [],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            foregroundColor: Theme.of(context).primaryColor,
            child: Icon(icon),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(prayerName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
              Text("Begins: $prayerTime", style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Theme.of(context).hintColor.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                Text("Jamat", style: TextStyle(color: Theme.of(context).hintColor, fontSize: 11, fontWeight: FontWeight.bold)),
                Text(jamatTime, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18, color: Theme.of(context).hintColor)),
              ],
            ),
          )
        ],
      ),
    );
  }
}