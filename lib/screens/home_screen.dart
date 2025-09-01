import 'package:flutter/material.dart';
import 'package:jamat_time/notification_service.dart';
import 'package:jamat_time/screens/settings_screen.dart';
import 'add_mosque_screen.dart';
import 'discover_screen.dart';
import 'prayer_schedule_screen.dart';
import '../models/mosque_model.dart';
import '../widgets/prayer_time_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Mosque? _favoriteMosque;
  int _selectedIndex = 0;
  final TextEditingController _minutesController = TextEditingController(text: "10");

  final Map<String, String> _prayerSchedule = {
    'Fajr': '04:28 AM', 'Sunrise': '05:43 AM', 'Dhuhr': '12:01 PM',
    'Asr': '04:25 PM', 'Maghrib': '06:19 PM', 'Isha': '07:34 PM',
  };

  @override
  void dispose() {
    _minutesController.dispose();
    super.dispose();
  }

  // ALARM FEATURE: Shows the dialog to set a notification
  void _showSetAlarmDialog(String prayerName, String prayerTimeStr) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Set Alarm for $prayerName'),
          content: TextField(
            controller: _minutesController,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Minutes before Jamat',
              hintText: 'e.g., 10',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final prayerTime = _parsePrayerTime(prayerTimeStr);
                final minutes = int.tryParse(_minutesController.text) ?? 10;
                
                NotificationService().scheduleNotification(prayerName, prayerTime, minutes);
                
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Alarm set for $prayerName!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Set Alarm'),
            ),
          ],
        );
      },
    );
  }

  // ALARM FEATURE: Converts a time string like "05:30 PM" to a DateTime object
  DateTime _parsePrayerTime(String timeStr) {
    final now = DateTime.now();
    final parts = timeStr.replaceAll(' AM', '').replaceAll(' PM', '').split(':');
    int hour = int.parse(parts[0]);
    final int minute = int.parse(parts[1]);

    if (timeStr.contains('PM') && hour != 12) {
      hour += 12;
    }
    if (timeStr.contains('AM') && hour == 12) { // Handles 12 AM (midnight)
      hour = 0;
    }
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  // NAVIGATION: Handles bottom navigation bar taps
  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PrayerScheduleScreen(
                    prayerSchedule: _prayerSchedule,
                  )));
    }
     setState(() {
      _selectedIndex = 0; // Always return to home visually
    });
  }

  // NAVIGATION: Navigates to the discover screen and waits for a result
  void _navigateAndSetFavorite(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DiscoverScreen()),
    );

    if (result != null && result is Mosque) {
      setState(() {
        _favoriteMosque = result;
      });
    }
  }

  // UI BUILDER: Shows the initial welcome screen
  Widget _buildInitialView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.explore, size: 100, color: Theme.of(context).textTheme.bodyMedium?.color),
          const SizedBox(height: 20),
          Text(
            'Welcome to Jamat Time',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 10),
          Text(
            'Find prayer times at your local mosques.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            icon: const Icon(Icons.search),
            label: const Text('Discover Nearby Mosques'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onPressed: () => _navigateAndSetFavorite(context),
          ),
        ],
      ),
    );
  }

  // UI BUILDER: Shows the favorite mosque's prayer times
  Widget _buildFavoriteMosqueView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _favoriteMosque!.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 28),
          ),
          const SizedBox(height: 4),
          Text(
            _favoriteMosque!.address,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 24),
          Text(
            'Today\'s Jamat Times',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).hintColor),
          ),
          const SizedBox(height: 16),
          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.5,
            children: _favoriteMosque!.jamatTimes.entries.map((entry) {
              return InkWell( // <-- WRAPPER for alarm tap
                onTap: () => _showSetAlarmDialog(entry.key, entry.value),
                borderRadius: BorderRadius.circular(15),
                child: PrayerTimeCard(prayerName: entry.key, time: entry.value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jamat Time'),
        actions: [
          if (_favoriteMosque != null)
            IconButton(
              icon: const Icon(Icons.sync_alt),
              tooltip: 'Change Favorite Mosque',
              onPressed: () => _navigateAndSetFavorite(context),
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _favoriteMosque == null ? _buildInitialView() : _buildFavoriteMosqueView(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddMosqueScreen(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Contribute'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              MaterialButton(
                minWidth: 40,
                onPressed: () {
                  setState(() { _selectedIndex = 0; });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.home,
                      color: _selectedIndex == 0 ? Theme.of(context).hintColor : Colors.grey,
                    ),
                    Text('Home', style: TextStyle(color: _selectedIndex == 0 ? Theme.of(context).hintColor : Colors.grey)),
                  ],
                ),
              ),
              MaterialButton(
                minWidth: 40,
                onPressed: () => _onItemTapped(1),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.schedule, color: Colors.grey),
                    Text('Schedule', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}