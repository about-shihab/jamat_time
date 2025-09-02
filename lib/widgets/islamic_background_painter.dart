import 'dart:math';
import 'package:flutter/material.dart';

class IslamicBackgroundPainter extends CustomPainter {
  final BuildContext context;

  IslamicBackgroundPainter({required this.context});

  @override
  void paint(Canvas canvas, Size size) {
    // Define the paint properties. The color is derived from the theme.
    final paint = Paint()
      ..color = Theme.of(context).cardColor.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final bigRadius = size.width * 0.4;
    final smallRadius = bigRadius * 0.75;

    // Calculate the 16 points for the 8-pointed star
    for (int i = 0; i < 16; i++) {
      final radius = i.isEven ? bigRadius : smallRadius;
      final angle = (pi / 8) * i - (pi / 16); // Offset to align it nicely
      
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}