import 'dart:async'; // <-- FIX: Corrected the import path from 'dart.async'
import 'package:flutter/material.dart';

class HadithSlider extends StatefulWidget {
  const HadithSlider({super.key});

  @override
  State<HadithSlider> createState() => _HadithSliderState();
}

class _HadithSliderState extends State<HadithSlider> {
  late final PageController _pageController;
  late final Timer _timer;
  int _currentPage = 0;

  final List<Map<String, String>> hadithList = const [
    {
      "text": "Prayer in congregation is twenty-seven times more meritorious than a prayer performed individually.",
      "reference": "Sahih al-Bukhari & Sahih Muslim"
    },
    {
      "text": "The Messenger of Allah (ﷺ) said, 'If they knew the reward for 'Isha' and Fajr prayers in congregation, they would come to them even if they had to crawl.'",
      "reference": "Sahih al-Bukhari & Sahih Muslim"
    },
    {
      "text": "Whoever purifies himself in his house, then walks to one of the houses of Allah to perform one of the obligatory prayers of Allah, one step of his will wipe out a sin and the other step will raise him one degree.",
      "reference": "Sahih Muslim"
    }
  ];
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Set up a timer to animate the page view
    _timer = Timer.periodic(const Duration(seconds: 20), (Timer timer) {
      if (_currentPage < hadithList.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0; // Loop back to the first hadith
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    // Clean up the timer and controller to prevent memory leaks
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The container is now smaller
    return SizedBox(
      height: 100,
      child: PageView.builder(
        controller: _pageController,
        itemCount: hadithList.length,
        itemBuilder: (context, index) {
          final hadith = hadithList[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12), // Reduced padding
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '"${hadith["text"]}"',
                  textAlign: TextAlign.center,
                  // Reduced font size
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Text(
                  '- ${hadith["reference"]}',
                  // Reduced font size
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}