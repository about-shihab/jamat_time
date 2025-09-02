import 'package:flutter/material.dart';
import 'package:jamat_time/models/jamat_time_details.dart';
import 'package:jamat_time/screens/edit_jamat_time_screen.dart';
import '../models/mosque_model.dart';

class ContributionScreen extends StatefulWidget {
  const ContributionScreen({super.key});

  @override
  State<ContributionScreen> createState() => _ContributionScreenState();
}

class _ContributionScreenState extends State<ContributionScreen> {
  // CORRECTED MOCK DATA
  final List<Mosque> _allMosques = [
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
    // You can add more mosques here following the same structure
  ];

  late List<Mosque> _filteredMosques;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredMosques = _allMosques;
    _searchController.addListener(_filterMosques);
  }

  void _filterMosques() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMosques = _allMosques.where((mosque) {
        return mosque.name.toLowerCase().contains(query) ||
               mosque.address.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The build method remains the same
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contribute Times'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by mosque name or area',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _filteredMosques.length,
              itemBuilder: (context, index) {
                final mosque = _filteredMosques[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    title: Text(mosque.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 17)),
                    subtitle: Text(mosque.address, style: Theme.of(context).textTheme.bodyMedium),
                    trailing: const Icon(Icons.edit_outlined),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditJamatTimeScreen(mosque: mosque)),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}