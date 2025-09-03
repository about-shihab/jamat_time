import 'package:flutter/material.dart';
import 'package:jamat_time/models/mosque_model.dart';
import 'package:jamat_time/screens/contribution_screen.dart';
import 'package:jamat_time/screens/events_view.dart';
import 'package:jamat_time/screens/home_view.dart';
import 'package:jamat_time/screens/qibla_view.dart';
import 'package:jamat_time/screens/quran_view.dart';
import 'package:jamat_time/screens/tracker_view.dart';

class MainScreen extends StatefulWidget {
  final Mosque favoriteMosque;
  const MainScreen({super.key, required this.favoriteMosque});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> views = [
      HomeView(favoriteMosque: widget.favoriteMosque),
      const QiblaView(),
      const QuranView(),
      const TrackerView(),
      const EventsView(),
    ];
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _selectedIndex = index),
        children: views,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ContributionScreen())),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return BottomAppBar(
      height: 70,
      elevation: 0,
      color: Theme.of(context).cardColor.withOpacity(0.5),
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(icon: Icons.home_filled, index: 0),
          _buildNavItem(icon: Icons.explore_outlined, index: 1),
          const SizedBox(width: 40), // The space for the notch
          _buildNavItem(icon: Icons.book_outlined, index: 2),
          _buildNavItem(icon: Icons.event_note_outlined, index: 4), // Mapped to EventsView
        ],
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required int index}) {
    return IconButton(
      icon: Icon(icon, color: _selectedIndex == index ? Theme.of(context).primaryColor : Colors.grey, size: 28),
      onPressed: () => _onItemTapped(index),
    );
  }
}