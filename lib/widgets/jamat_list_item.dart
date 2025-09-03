import 'package:flutter/material.dart';

class JamatListItem extends StatelessWidget {
  final String prayerName;
  final String jamatTime;
  final IconData icon;
  final bool isNext;

  const JamatListItem({
    super.key,
    required this.prayerName,
    required this.jamatTime,
    required this.icon,
    this.isNext = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: isNext ? Theme.of(context).hintColor.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.8)),
          const SizedBox(width: 16),
          Text(
            prayerName,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Text(
            jamatTime,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}