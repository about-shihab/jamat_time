import 'package:flutter/material.dart';
import 'package:jamat_time/l10n/app_localizations.dart';

class PrayerGlanceItem extends StatelessWidget {
  final String prayerName;
  final String prayerTime;
  final String prayerEnd;
  final String jamatTime;
  final IconData icon;
  final bool isNext;
  final VoidCallback? onAlarmTap;
  final bool alarmSet;

  const PrayerGlanceItem({
    super.key,
    required this.prayerName,
    required this.prayerTime,
    required this.prayerEnd,
    required this.jamatTime,
    required this.icon,
    this.isNext = false,
    this.onAlarmTap,
    this.alarmSet = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(isNext ? 1.0 : 0.5),
        borderRadius: BorderRadius.circular(15),
        border: isNext
            ? Border.all(color: Theme.of(context).primaryColor, width: 2)
            : null,
        boxShadow: isNext
            ? [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ]
            : [],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            foregroundColor: Theme.of(context).primaryColor,
            child: Icon(icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(prayerName,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontSize: 18)),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).hintColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "$prayerTime - $prayerEnd",
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Centered alarm icon
          SizedBox(
            width: 44,
            child: Center(
              child: IconButton(
                onPressed: onAlarmTap,
                tooltip: 'Set alarm',
                icon: Icon(
                  alarmSet ? Icons.alarm_on : Icons.alarm_add_outlined,
                  color: alarmSet
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: Theme.of(context).hintColor.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(l10n.jamat,
                    style: TextStyle(
                        color: Theme.of(context).hintColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
                Text(jamatTime,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 18, color: Theme.of(context).hintColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
