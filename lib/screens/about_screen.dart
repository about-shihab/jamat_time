import 'package:flutter/material.dart';
import 'package:jamat_time/l10n/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final features = [
      l10n.aboutFeaturePrayer,
      l10n.aboutFeatureCommunity,
      l10n.aboutFeatureLearning,
      l10n.aboutFeatureCompass,
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutUs)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(l10n.aboutHeadline,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Text(l10n.aboutDescription,
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          Text(l10n.aboutMissionTitle,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(l10n.aboutMissionBody),
          const SizedBox(height: 24),
          Text(l10n.aboutFeaturesTitle,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...features.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• '),
                  Expanded(child: Text(item)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.aboutContactTitle,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(l10n.aboutContactBody),
        ],
      ),
    );
  }
}
