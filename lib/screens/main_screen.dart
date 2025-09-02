import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamat_time/screens/contribution_screen.dart';
import 'package:jamat_time/screens/events_view.dart';
import 'package:jamat_time/screens/jamat_time_view.dart';
import 'package:jamat_time/theme_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Widget> _views = [
    const JamatTimeView(),
    const EventsView(),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        // --- THIS IS THE UPDATED SECTION ---
        title: Row(
          children: [
            Icon(
              Icons.mosque_outlined,
              color: Theme.of(context).hintColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            // This will automatically use the correct color from the theme
            const Text('Jamat Time'),
          ],
        ),
        // --- END OF UPDATE ---
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode 
                ? Icons.light_mode_outlined 
                : Icons.dark_mode_outlined
            ),
            tooltip: 'Toggle Theme',
            onPressed: () {
              final provider = Provider.of<ThemeProvider>(context, listen: false);
              provider.toggleTheme(!provider.isDarkMode);
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _views,
      ),
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  Widget _buildCustomBottomNav() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
             decoration: BoxDecoration(
               color: Theme.of(context).cardColor.withOpacity(0.8),
               borderRadius: BorderRadius.circular(30)
             ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.access_time_filled_outlined, 'Jamat', 0),
              const SizedBox(width: 60),
              _buildNavItem(Icons.event_note_outlined, 'Events', 1),
            ],
          ),
          SizedBox(
            width: 64,
            height: 64,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ContributionScreen()));
              },
              elevation: 4,
              child: const Icon(Icons.add, size: 30),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? Theme.of(context).hintColor : Colors.grey, size: 28),
          Text(label, style: TextStyle(color: isSelected ? Theme.of(context).hintColor : Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}