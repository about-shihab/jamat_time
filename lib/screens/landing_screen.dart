import 'package:flutter/material.dart';
import 'package:jamat_time/models/mosque_model.dart';
import 'package:jamat_time/screens/main_screen.dart';
import 'package:jamat_time/screens/scan_view.dart';
import 'package:jamat_time/widgets/aurora_background_painter.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> with SingleTickerProviderStateMixin {
  Mosque? _favoriteMosque;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 40))..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void onMosqueFavorited(Mosque mosque) {
    setState(() => _favoriteMosque = mosque);
  }

  @override
  Widget build(BuildContext context) {
    // FIX: Get the colors from the theme here, in the build method.
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
              // FIX: Pass the colors directly to the painter, not the context.
              painter: AuroraBackgroundPainter(
                animation: _animationController,
                color1: color1,
                color2: color2,
                color3: color3,
              ),
            ),
          ),
          _favoriteMosque == null
              ? ScanView(onMosqueFavorited: onMosqueFavorited)
              : MainScreen(favoriteMosque: _favoriteMosque!),
        ],
      ),
    );
  }
}