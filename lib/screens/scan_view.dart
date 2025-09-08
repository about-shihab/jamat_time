import 'package:flutter/material.dart';
import 'package:jamat_time/models/mosque_model.dart';
import 'package:jamat_time/screens/scan_results_screen.dart';
import 'package:jamat_time/l10n/app_localizations.dart';

class ScanView extends StatelessWidget {
  final Function(Mosque) onMosqueFavorited;
  const ScanView({super.key, required this.onMosqueFavorited});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.welcomeTitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24)),
            const SizedBox(height: 10),
            Text(l10n.welcomeSubtitle, style: Theme.of(context).textTheme.bodyMedium),
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
                child: Center(child: Text(l10n.scan, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
              ),
            )
          ],
        ),
      ),
    );
  }
}
