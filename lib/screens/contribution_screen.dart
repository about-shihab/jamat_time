import 'package:flutter/material.dart';
import 'package:jamat_time/models/mosque_model.dart';
import 'package:jamat_time/screens/edit_jamat_time_screen.dart';

class ContributionScreen extends StatefulWidget {
  const ContributionScreen({super.key});

  @override
  State<ContributionScreen> createState() => _ContributionScreenState();
}

class _ContributionScreenState extends State<ContributionScreen> {
  // Mock data - would come from a database
  final List<Mosque> _allMosques = [ /* ... Add your mock mosque data here ... */ ];
  late List<Mosque> _filteredMosques;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredMosques = _allMosques;
    _searchController.addListener(_filterMosques);
  }
  
  void _filterMosques() {
    // ... filtering logic remains the same
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                hintText: 'Search by mosque name or area...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).cardColor.withOpacity(0.5),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredMosques.length,
              itemBuilder: (context, index) {
                final mosque = _filteredMosques[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 0,
                  color: Theme.of(context).cardColor.withOpacity(0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    title: Text(mosque.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(mosque.address),
                    trailing: Icon(Icons.edit_note_outlined, color: Theme.of(context).primaryColor),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => EditJamatTimeScreen(mosque: mosque)));
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