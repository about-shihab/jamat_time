import 'package:flutter/material.dart';
import 'package:jamat_time/models/mosque_model.dart';
import 'package:jamat_time/screens/scan_results_screen.dart';

class ScanView extends StatelessWidget {
  final Function(Mosque) onMosqueFavorited;
  const ScanView({super.key, required this.onMosqueFavorited});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome to Jamat Time", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24)),
            const SizedBox(height: 10),
            Text("Find prayer times at your local mosques.", style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () {
                // Simulate scan and navigate to results
                Navigator.push(context, MaterialPageRoute(builder: (context) => ScanResultsScreen(onMosqueFavorited: onMosqueFavorited)));
              },
              child: Container(
                width: 150, height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor,
                  boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.5), blurRadius: 20, spreadRadius: 5)],
                ),
                child: const Center(child: Text("SCAN", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
              ),
            )
          ],
        ),
      ),
    );
  }
}