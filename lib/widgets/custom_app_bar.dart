import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamat_time/theme_provider.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String? title;
  final bool showHadith;

  const CustomAppBar({
    super.key,
    this.title,
    this.showHadith = false, // Defaults to not showing the hadith
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (showHadith ? 30.0 : 0.0));
}

class _CustomAppBarState extends State<CustomAppBar> {
  int _hadithIndex = 0;
  Timer? _timer;

  final List<String> _hadithList = [
    "Prayer in congregation is 27 times more meritorious than a prayer performed individually.",
    "If they knew the reward for 'Isha' and Fajr prayers... they would come to them even if they had to crawl.",
    "One step of his will wipe out a sin and the other step will raise him one degree.",
  ];

  @override
  void initState() {
    super.initState();
    if (widget.showHadith) {
      _timer = Timer.periodic(const Duration(seconds: 20), (timer) {
        if (mounted) {
          setState(() {
            _hadithIndex = (_hadithIndex + 1) % _hadithList.length;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(widget.title ?? 'Jamat Time'),
      actions: [
        Row(
          children: [
            const Icon(Icons.location_on_outlined, size: 16),
            const SizedBox(width: 4),
            Text("Chattogram", style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        IconButton(
          icon: Icon(themeProvider.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
          tooltip: 'Toggle Theme',
          onPressed: () {
            // This is the correct way to call the provider for an action
            Provider.of<ThemeProvider>(context, listen: false).toggleTheme(!themeProvider.isDarkMode);
          },
        ),
      ],
      bottom: widget.showHadith
          ? PreferredSize(
              preferredSize: const Size.fromHeight(30.0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 1000),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Text(
                  _hadithList[_hadithIndex],
                  key: ValueKey<int>(_hadithIndex),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : null,
    );
  }
}