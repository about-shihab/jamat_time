import 'package:flutter/material.dart';
import 'package:jamat_time/main.dart'; // For the RouteObserver
import 'package:jamat_time/models/mosque_model.dart';
import 'package:jamat_time/screens/main_screen.dart';
import 'package:jamat_time/screens/scan_view.dart';
import 'package:jamat_time/widgets/aurora_background_painter.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

// The RouteAware mixin is essential to fix the mouse/gesture bug on web
class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin, RouteAware {
  // In a real app, you'd load the favorite mosque's ID from device storage here
  Mosque? _favoriteMosque;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 40))
          ..repeat();
  }

  // This section subscribes the screen to navigation events
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    _animationController.dispose();
    routeObserver.unsubscribe(this); // Clean up the subscription
    super.dispose();
  }

  // These methods pause and resume the animation to prevent errors on other screens
  @override
  void didPushNext() => _animationController.stop(); // Pause when a new screen is pushed
  @override
  void didPopNext() => _animationController.repeat(); // Resume when returning to this screen

  void onMosqueFavorited(Mosque mosque) {
    // In a real app, you'd save the favorite mosque's ID to device storage here
    setState(() => _favoriteMosque = mosque);
  }

  void _clearFavorite() {
    // In a real app, you'd clear the saved mosque ID here
    setState(() => _favoriteMosque = null);
  }

  @override
  Widget build(BuildContext context) {
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
              painter: AuroraBackgroundPainter(
                animation: _animationController,
                color1: color1,
                color2: color2,
                color3: color3,
              ),
            ),
          ),

          // An AnimatedSwitcher provides a smoother transition between views
           _favoriteMosque == null
                ? ScanView(onMosqueFavorited: onMosqueFavorited)
                : MainScreen(
                    favoriteMosque: _favoriteMosque!,
                    onClearFavorite: _clearFavorite,
                  ),
        ],
      ),
    );
  }
}