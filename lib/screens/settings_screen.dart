import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamat_time/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return Card(
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                 child: SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text('Dark Mode', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16)),
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme(value);
                  },
                 ),
              );
            },
          ),
        ],
      ),
    );
  }
}