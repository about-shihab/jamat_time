import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../models/jamat_time_details.dart';
import '../models/mosque_model.dart';
import '../widgets/event_card.dart';

class ScanResultsScreen extends StatelessWidget {
  final Function(Mosque) onMosqueFavorited;
  ScanResultsScreen({super.key, required this.onMosqueFavorited});

  // FIX: Removed 'const' from the list declaration
  final List<Mosque> _nearbyMosques = [
    Mosque(
      name: 'Baitul Falah Mosque',
      address: 'WASA Circle, Chattogram',
      lastUpdatedAt: DateTime(2025, 9, 2, 10, 5),
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
      lastUpdatedAt: DateTime(2025, 9, 1, 20, 10),
      lastUpdatedBy: 'Admin',
       jamatTimes: {
        'Fajr': JamatTimeDetails(jamatTime: '05:00 AM'),
        'Dhuhr': JamatTimeDetails(jamatTime: '01:30 PM'),
        'Asr': JamatTimeDetails(jamatTime: '05:00 PM'),
        'Maghrib': JamatTimeDetails(jamatTime: '06:20 PM'),
        'Isha': JamatTimeDetails(jamatTime: '08:00 PM'),
      },
    ),
    Mosque(
      name: 'Chandanpura Masjid',
      address: 'Kaptainar road, Chattogram',
      lastUpdatedAt: DateTime(2025, 9, 3, 4, 55),
      lastUpdatedBy: 'S. Chowdhury',
       jamatTimes: {
        'Fajr': JamatTimeDetails(jamatTime: '05:05 AM'),
        'Dhuhr': JamatTimeDetails(jamatTime: '01:30 PM'),
        'Asr': JamatTimeDetails(jamatTime: '04:55 PM'),
        'Maghrib': JamatTimeDetails(jamatTime: '06:21 PM'),
        'Isha': JamatTimeDetails(jamatTime: '08:00 PM'),
      },
    ),
  ];

  // FIX: Removed 'const' from the list declaration
  final List<EventModel> _nearbyEvents = [
    EventModel(title: "Weekly Tafsir Circle", location: "Baitul Falah Mosque Hall", eventTime: DateTime(2025, 9, 5, 19, 45), goingCount: 45),
    EventModel(title: "Youth Community Iftar", location: "Chittagong Club Ltd.", eventTime: DateTime(2025, 9, 7, 18, 0), goingCount: 112),
    EventModel(title: "Charity Drive for Orphans", location: "Nasirabad Community Center", eventTime: DateTime(2025, 9, 6, 11, 0), goingCount: 32),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Scan Results'),
          bottom: const TabBar(tabs: [Tab(text: 'Nearby Mosques'), Tab(text: 'Nearby Events')]),
        ),
        body: TabBarView(
          children: [
            // Mosques Tab
            ListView.builder(
              itemCount: _nearbyMosques.length,
              itemBuilder: (context, index) {
                final mosque = _nearbyMosques[index];
                return ListTile(
                  title: Text(mosque.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(mosque.address),
                  trailing: const Icon(Icons.favorite_border_outlined),
                  onTap: () {
                    onMosqueFavorited(mosque);
                    Navigator.pop(context);
                  },
                );
              },
            ),
            // Events Tab
            ListView.builder(
              itemCount: _nearbyEvents.length,
              itemBuilder: (context, index) {
                return EventCard(event: _nearbyEvents[index]);
              },
            ),
          ],
        ),
      ),
    );
  }
}