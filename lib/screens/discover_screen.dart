import 'package:flutter/material.dart';
import '../models/mosque_model.dart';
import '../widgets/mosque_list_item.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  // Mock data for nearby mosques in Chattogram
  final List<Mosque> _nearbyMosques = [
    Mosque(
      name: 'Central Mosque of Chattogram',
      address: 'Anderkilla, Chattogram',
      jamatTimes: {
        'Fajr': '05:00 AM', 'Dhuhr': '01:30 PM', 'Asr': '05:00 PM',
        'Maghrib': '06:20 PM', 'Isha': '08:00 PM',
      },
    ),
    Mosque(
      name: 'Baytul Falah Mosque',
      address: 'WASA Circle, Chattogram',
      jamatTimes: {
        'Fajr': '05:10 AM', 'Dhuhr': '01:35 PM', 'Asr': '05:05 PM',
        'Maghrib': '06:22 PM', 'Isha': '08:05 PM',
      },
    ),
    Mosque(
        name: 'Chandranpura Mosque',
        address: 'DC Road, Chattogram',
        jamatTimes: {
          'Fajr': '04:55 AM', 'Dhuhr': '01:25 PM', 'Asr': '04:55 PM',
          'Maghrib': '06:19 PM', 'Isha': '07:55 PM',
        }),
    Mosque(
        name: 'Lal Dighi Mosque',
        address: 'Laldighi, Chattogram',
        jamatTimes: {
          'Fajr': '05:15 AM', 'Dhuhr': '01:40 PM', 'Asr': '05:10 PM',
          'Maghrib': '06:25 PM', 'Isha': '08:10 PM',
        }),
    Mosque(
        name: 'Amanat Shah Mosque',
        address: 'Court Road, Chattogram',
        jamatTimes: {
          'Fajr': '05:00 AM', 'Dhuhr': '01:30 PM', 'Asr': '05:00 PM',
          'Maghrib': '06:21 PM', 'Isha': '08:00 PM',
        }),
    Mosque(
        name: 'Chawkbazar Shahi Jam-e-Masjid',
        address: 'Chawk Bazar, Chattogram',
        jamatTimes: {
          'Fajr': '05:10 AM', 'Dhuhr': '01:35 PM', 'Asr': '05:10 PM',
          'Maghrib': '06:23 PM', 'Isha': '08:05 PM',
        }),
    Mosque(
        name: 'Nasirabad Jame Masjid',
        address: 'Nasirabad H/S, Chattogram',
        jamatTimes: {
          'Fajr': '05:00 AM', 'Dhuhr': '01:30 PM', 'Asr': '05:00 PM',
          'Maghrib': '06:20 PM', 'Isha': '08:00 PM',
        }),
    Mosque(
        name: 'Agrabad Jame Mosque',
        address: 'Agrabad C/A, Chattogram',
        jamatTimes: {
          'Fajr': '05:10 AM', 'Dhuhr': '01:40 PM', 'Asr': '05:15 PM',
          'Maghrib': '06:28 PM', 'Isha': '08:15 PM',
        }),
  ];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _scanForMosques();
  }

  void _scanForMosques() {
    // Simulate a network call or scan
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Mosques'),
        backgroundColor: const Color(0xFF0A0E21),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.tealAccent),
                  SizedBox(height: 20),
                  Text('Scanning for nearby mosques...'),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _nearbyMosques.length,
              itemBuilder: (context, index) {
                final mosque = _nearbyMosques[index];
                return MosqueListItem(
                  mosque: mosque,
                  onSetFavorite: () {
                    // Pop the screen and return the selected mosque
                    Navigator.pop(context, mosque);
                  },
                );
              },
            ),
    );
  }
}