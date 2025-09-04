import 'package:flutter/material.dart';
import 'package:jamat_time/models/mosque_model.dart';
import 'package:jamat_time/screens/events_view.dart';
import 'package:jamat_time/screens/jamat_time_view.dart';

class DashboardScreen extends StatefulWidget {
  final Mosque favoriteMosque;
  const DashboardScreen({super.key, required this.favoriteMosque});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Lazy initialization of views
    final List<Widget> views = [
      JamatTimeView(mosque: widget.favoriteMosque),
      const EventsView(),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: IndexedStack(index: _selectedIndex, children: views),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.access_time_filled), label: "Jamat"),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: "Events"),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () { /* Navigate to Contribution Screen */ },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}