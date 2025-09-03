import 'package:flutter/material.dart';
import 'package:jamat_time/widgets/qibla_painters.dart';

class QiblaView extends StatelessWidget {
  const QiblaView({super.key});

  @override
  Widget build(BuildContext context) {
    // In a real app, you would use a compass plugin to get the actual heading.
    const double qiblaDirectionInDegrees = 278.5; 

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Qibla Direction')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Chattogram, Bangladesh", style: Theme.of(context).textTheme.bodyMedium),
            Text("$qiblaDirectionInDegrees° W", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 28)),
            const SizedBox(height: 30),
            SizedBox(
              width: 300,
              height: 300,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(size: const Size(300, 300), painter: QiblaDialPainter(context: context)),
                  // The needle would be rotated based on compass heading vs. Qibla direction
                  CustomPaint(size: const Size(300, 300), painter: QiblaNeedlePainter(context: context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}