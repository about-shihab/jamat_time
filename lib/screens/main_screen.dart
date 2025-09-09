import 'package:flutter/material.dart';
import 'package:jamat_time/app_localizations.dart';
import 'package:jamat_time/models/mosque_model.dart';
import 'package:jamat_time/screens/contribution_screen.dart';
import 'package:jamat_time/screens/events_view.dart';
import 'package:jamat_time/screens/home_view.dart';
import 'package:jamat_time/screens/qibla_view.dart';
import 'package:jamat_time/screens/quran_view.dart';
import 'package:jamat_time/screens/tracker_view.dart';
import 'package:jamat_time/widgets/aurora_background_painter.dart';

class MainScreen extends StatefulWidget {
  final Mosque favoriteMosque;
  final VoidCallback onClearFavorite;
  const MainScreen({super.key, required this.favoriteMosque, required this.onClearFavorite});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late final PageController _pageController;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 40))..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
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
    
    final theme = Theme.of(context);
    final color1 = theme.primaryColor.withOpacity(0.3);
    final color2 = theme.scaffoldBackgroundColor;
    final color3 = theme.cardColor.withOpacity(0.3);

    return Scaffold(
      body: Stack(
        children: [
          IgnorePointer(
            child: CustomPaint(
              size: Size.infinite,
              painter: AuroraBackgroundPainter(animation: _animationController, color1: color1, color2: color2, color3: color3),
            ),
          ),
          PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _selectedIndex = index),
            children: views,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ContributionScreen())),
        child: const Icon(Icons.add),
        elevation: 2,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    final localizations = AppLocalizations.of(context);
    return BottomAppBar(
      // FIX 1: Slightly reduced height for better compatibility
      height: 74, 
      elevation: 0,
      color: Theme.of(context).cardColor.withOpacity(0.95),
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(icon: Icons.home_filled, label: localizations.translate('home'), index: 0),
          _buildNavItem(icon: Icons.explore_outlined, label: localizations.translate('qibla'), index: 1),
          const SizedBox(width: 40),
          _buildNavItem(icon: Icons.book_outlined, label: localizations.translate('quran'), index: 2),
          _buildNavItem(icon: Icons.check_circle_outline, label: localizations.translate('tracker'), index: 3),
        ],
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
        child: Column(
          // FIX 2: Ensures the column is vertically compact to prevent overflow
          mainAxisSize: MainAxisSize.min, 
          children: [
            Icon(icon, color: isSelected ? Theme.of(context).primaryColor : Colors.grey, size: 25),
            Text(label, style: TextStyle(color: isSelected ? Theme.of(context).primaryColor : Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}