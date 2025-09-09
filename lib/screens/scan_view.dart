import 'package:flutter/material.dart';
import 'package:jamat_time/app_localizations.dart'; // Import the localizations file
import 'package:jamat_time/main.dart';
import 'package:jamat_time/models/jamat_time_details.dart';
import 'package:jamat_time/models/mosque_model.dart';
import 'package:jamat_time/widgets/aurora_background_painter.dart';
import 'package:jamat_time/widgets/mosque_list_item.dart';

class ScanView extends StatefulWidget {
  final Function(Mosque) onMosqueFavorited;
  const ScanView({super.key, required this.onMosqueFavorited});

  @override
  State<ScanView> createState() => _ScanViewState();
}

class _ScanViewState extends State<ScanView> with SingleTickerProviderStateMixin, RouteAware {
  bool _isLoading = true;
  late final AnimationController _animationController;

  // Updated Mock Data for Sunday, September 7, 2025
  final List<Mosque> _nearbyMosques = [
    Mosque(
      name: 'Baitul Falah Mosque',
      address: 'WASA Circle, Chattogram',
      lastUpdatedAt: DateTime(2025, 9, 6, 10, 5),
      lastUpdatedBy: 'A. Khan',
      jamatTimes: {
        'Fajr':  JamatTimeDetails(jamatTime: '05:10 AM'),
        'Dhuhr':  JamatTimeDetails(jamatTime: '01:35 PM'),
        'Asr':  JamatTimeDetails(jamatTime: '05:05 PM'),
        'Maghrib':  JamatTimeDetails(jamatTime: '06:22 PM'),
        'Isha':  JamatTimeDetails(jamatTime: '08:05 PM'),
      },
    ),
    Mosque(
      name: 'Anderkilla Shahi Mosque',
      address: 'Anderkilla, Chattogram',
      lastUpdatedAt: DateTime(2025, 9, 7, 8, 15),
      lastUpdatedBy: 'Admin',
       jamatTimes: {
        'Fajr':  JamatTimeDetails(jamatTime: '05:00 AM'),
        'Dhuhr':  JamatTimeDetails(jamatTime: '01:30 PM'),
        'Asr':  JamatTimeDetails(jamatTime: '05:00 PM'),
        'Maghrib':  JamatTimeDetails(jamatTime: '06:20 PM'),
        'Isha':  JamatTimeDetails(jamatTime: '08:00 PM'),
      },
    ),
    Mosque(
      name: 'Chandanpura Masjid',
      address: 'Kaptainar road, Chattogram',
      lastUpdatedAt: DateTime(2025, 9, 5, 14, 0),
      lastUpdatedBy: 'S. Chowdhury',
       jamatTimes: {
        'Fajr':  JamatTimeDetails(jamatTime: '05:05 AM'),
        'Dhuhr':  JamatTimeDetails(jamatTime: '01:30 PM'),
        'Asr':  JamatTimeDetails(jamatTime: '04:55 PM'),
        'Maghrib':  JamatTimeDetails(jamatTime: '06:21 PM'),
        'Isha':  JamatTimeDetails(jamatTime: '08:00 PM'),
      },
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 40))..repeat();
    Future.delayed(const Duration(seconds: 2), () {
      if(mounted) setState(() => _isLoading = false);
    });
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPushNext() => _animationController.stop();
  @override
  void didPopNext() => _animationController.repeat();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
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
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    // FIX: Using translated text
                    localizations.translate('nearby_mosques_title'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24),
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _nearbyMosques.length,
                          itemBuilder: (context, index) {
                            final mosque = _nearbyMosques[index];
                            return MosqueListItem(
                              mosque: mosque,
                              onSetFavorite: () => widget.onMosqueFavorited(mosque),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}