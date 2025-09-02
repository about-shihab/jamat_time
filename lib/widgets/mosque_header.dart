import 'package:flutter/material.dart';
import 'package:jamat_time/models/mosque_model.dart';

class MosqueHeader extends StatelessWidget {
  final Mosque mosque;
  const MosqueHeader({super.key, required this.mosque});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.mosque_outlined, size: 40, color: Theme.of(context).hintColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mosque.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
                ),
                Text(
                  mosque.address,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}