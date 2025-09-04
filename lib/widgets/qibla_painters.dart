import 'dart:math';
import 'package:flutter/material.dart';

class QiblaDialPainter extends CustomPainter {
  final BuildContext context;
  QiblaDialPainter({required this.context});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = Theme.of(context).cardColor.withOpacity(0.5)
      ..style = PaintingStyle.stroke..strokeWidth = 2;
    canvas.drawCircle(center, radius, paint);

    for (int i = 0; i < 360; i += 15) {
      final isMajorTick = i % 45 == 0;
      final tickLength = isMajorTick ? 15.0 : 8.0;
      final tickPaint = Paint()
        ..color = isMajorTick ? Theme.of(context).hintColor : Theme.of(context).primaryColor
        ..strokeWidth = isMajorTick ? 2.5 : 1.5;

      final angle = (i - 90) * (pi / 180);
      final p1 = Offset(center.dx + (radius - 5) * cos(angle), center.dy + (radius - 5) * sin(angle));
      final p2 = Offset(center.dx + (radius - 5 - tickLength) * cos(angle), center.dy + (radius - 5 - tickLength) * sin(angle));
      canvas.drawLine(p1, p2, tickPaint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class QiblaNeedlePainter extends CustomPainter {
  final BuildContext context;
  QiblaNeedlePainter({required this.context});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final path = Path();
    
    path.moveTo(center.dx, center.dy - radius * 0.8);
    path.lineTo(center.dx - 15, center.dy);
    path.lineTo(center.dx + 15, center.dy);
    path.close();

    final paint = Paint()..color = Theme.of(context).hintColor;
    canvas.drawPath(path, paint);
    canvas.drawCircle(center, 8, Paint()..color = Theme.of(context).primaryColor);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}