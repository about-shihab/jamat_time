import 'package:flutter/material.dart';

class QuranView extends StatelessWidget {
  const QuranView({super.key});

  final List<String> surahNames = const [
    "Al-Fatihah", "Al-Baqarah", "Aal-E-Imran", "An-Nisa", "Al-Ma'idah", "Al-An'am", "Al-A'raf", "Al-Anfal", "At-Tawbah", "Yunus"
    // ... add more surahs
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Quran')),
      body: ListView.builder(
        itemCount: surahNames.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Text("${index + 1}", style: TextStyle(color: Theme.of(context).hintColor, fontSize: 16)),
            title: Text(surahNames[index], style: const TextStyle(fontWeight: FontWeight.bold)),
            onTap: () { /* Navigate to Surah reading screen */ },
          );
        },
      ),
    );
  }
}