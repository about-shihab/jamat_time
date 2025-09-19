import 'package:flutter/material.dart';
import 'package:jamat_time/models/mosque_model.dart';
import 'package:jamat_time/screens/edit_jamat_time_screen.dart';
import 'package:jamat_time/screens/events_view.dart';
import 'package:jamat_time/screens/home_view.dart';
import 'package:jamat_time/screens/qibla_view.dart';
import 'package:jamat_time/screens/quran_library_view.dart';
import 'package:jamat_time/screens/quran_word_learner_view.dart';
import 'package:jamat_time/screens/scan_results_screen.dart';
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
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final views = <Widget>[
      HomeView(favoriteMosque: widget.favoriteMosque),
      const QiblaView(),
      const TrackerView(),
      const QuranLibraryView(),
      const QuranWordLearnerView(),
      const EventsView(),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PageView(
        controller: _pageController,
        physics: const ClampingScrollPhysics(),
        onPageChanged: (index) => setState(() => _selectedIndex = index),
        children: views,
      ),
      floatingActionButton: _buildFab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildFab(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        final selected = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ScanResultsScreen()),
        );
        if (selected is Mosque && context.mounted) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditJamatTimeScreen(mosque: selected),
            ),
          );
        }
      },
      shape: const _MosqueDomeBorder(),
      backgroundColor: const Color(0xFF006A71),
      foregroundColor: Colors.white,
      child: const Icon(Icons.edit_note_outlined),
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
          _buildNavItem(icon: Icons.access_time_rounded, index: 2),
          const SizedBox(width: 40),
          _buildNavItem(icon: Icons.menu_book_outlined, index: 3),
          _buildNavItem(icon: Icons.school_outlined, index: 4),
          _buildNavItem(icon: Icons.event_note_outlined, index: 5),
        ],
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required int index}) {
    final isSelected = _selectedIndex == index;
    return IconButton(
      icon: Icon(
        icon,
        color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
        size: 28,
      ),
      onPressed: () => _onItemTapped(index),
    );
  }
}

class _MosqueDomeBorder extends OutlinedBorder {
  const _MosqueDomeBorder({super.side = BorderSide.none});

  @override
  OutlinedBorder copyWith({BorderSide? side}) =>
      _MosqueDomeBorder(side: side ?? this.side);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final w = rect.width;
    final h = rect.height;
    final top = rect.top + h * 0.05;
    final baseY = rect.bottom - h * 0.18;
    final leftBase = Offset(rect.left + w * 0.18, baseY);
    final rightBase = Offset(rect.right - w * 0.18, baseY);
    final peak = Offset(rect.left + w * 0.5, top);
    final bottomCenter = Offset(rect.left + w * 0.5, rect.bottom);

    final path = Path()
      ..moveTo(leftBase.dx, leftBase.dy)
      ..quadraticBezierTo(
        rect.left + w * 0.22,
        rect.top + h * 0.25,
        peak.dx,
        peak.dy,
      )
      ..quadraticBezierTo(
        rect.right - w * 0.22,
        rect.top + h * 0.25,
        rightBase.dx,
        rightBase.dy,
      )
      ..quadraticBezierTo(
        bottomCenter.dx,
        rect.bottom,
        leftBase.dx,
        leftBase.dy,
      )
      ..close();
    return path;
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    final deflated = rect.deflate(side.width);
    return getOuterPath(deflated, textDirection: textDirection);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => _MosqueDomeBorder(side: side.scale(t));
}
