import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

class CustomAppBarTitle extends StatefulWidget {
  const CustomAppBarTitle({super.key});

  @override
  State<CustomAppBarTitle> createState() => _CustomAppBarTitleState();
}

class _CustomAppBarTitleState extends State<CustomAppBarTitle> {
  late Timer _timer;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    // Update the time every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Format Gregorian date
    final gregorianDate = DateFormat('EEEE, d MMMM y').format(_currentTime);
    // Get and format Hijri date
    final hijriDate = HijriCalendar.now();
    final hijriFormatted = hijriDate.toFormat("d MMMM, yyyy");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Live Time
        Text(
          DateFormat('hh:mm:ss a').format(_currentTime),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
        ),
        // Dates
        Text(
          '$gregorianDate | $hijriFormatted',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}