import 'package:flutter/material.dart';
import 'package:jamat_time/models/jamat_time_details.dart';
import '../models/mosque_model.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});
  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  // CORRECTED MOCK DATA: Removed prayerTimeRange from JamatTimeDetails
  final List<Mosque> _nearbyMosques = [
    Mosque(
      name: 'Baitul Falah Mosque',
      address: 'WASA Circle, Chattogram',
      lastUpdatedAt: DateTime(2025, 8, 31, 10, 5),
      lastUpdatedBy: 'A. Khan',
      jamatTimes: {
        'Fajr': JamatTimeDetails(jamatTime: '05:10 AM'),
        'Dhuhr': JamatTimeDetails(jamatTime: '01:35 PM'),
        'Asr': JamatTimeDetails(jamatTime: '05:05 PM'),
        'Maghrib': JamatTimeDetails(jamatTime: '06:22 PM'),
        'Isha': JamatTimeDetails(jamatTime: '08:05 PM'),
      },
    ),
     Mosque(
      name: 'Anderkilla Shahi Mosque',
      address: 'Anderkilla, Chattogram',
      lastUpdatedAt: DateTime(2025, 8, 29, 20, 10),
      lastUpdatedBy: 'Admin',
       jamatTimes: {
        'Fajr': JamatTimeDetails(jamatTime: '05:00 AM'),
        'Dhuhr': JamatTimeDetails(jamatTime: '01:30 PM'),
        'Asr': JamatTimeDetails(jamatTime: '05:00 PM'),
        'Maghrib': JamatTimeDetails(jamatTime: '06:20 PM'),
        'Isha': JamatTimeDetails(jamatTime: '08:00 PM'),
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover Mosques')),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _nearbyMosques.length,
        itemBuilder: (context, index) {
          final mosque = _nearbyMosques[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              title: Text(mosque.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 17)),
              subtitle: Text(mosque.address, style: Theme.of(context).textTheme.bodyMedium),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pop(context, mosque),
            ),
          );
        },
      ),
    );
  }
}