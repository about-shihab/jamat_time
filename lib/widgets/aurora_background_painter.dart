import 'dart:math';
import 'package:flutter/material.dart';

class AuroraBackgroundPainter extends CustomPainter {
  final Animation<double> animation;
  // FIX: It now accepts colors directly instead of the whole BuildContext
  final Color color1;
  final Color color2;
  final Color color3;

  AuroraBackgroundPainter({
    required this.animation,
    required this.color1,
    required this.color2,
    required this.color3,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    // The painter now uses the color properties passed to it
    final colors = [color1, color2, color3];
    final stops = [0.0, 0.5, 1.0];
    final center = Offset(size.width / 2, size.height / 2);
    final radius = sqrt(size.width * size.width + size.height * size.height);
    final rect = Rect.fromCircle(center: center, radius: radius);
      
    final paint = Paint()
      ..shader = RadialGradient(
        colors: colors,
        stops: stops,
        transform: GradientRotation(animation.value * 2 * pi),
      ).createShader(rect);

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}