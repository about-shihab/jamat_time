import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      // Welcome
      'welcome_title': 'Welcome', 'welcome_subtitle': 'Please select your language',
      // Scan / Nearby
      'nearby_mosques_title': 'Select a Nearby Mosque',
      'scan_results': 'Scan Results', 'nearby_mosques_tab': 'Nearby Mosques', 'nearby_events_tab': 'Nearby Events',
      // Main Nav
      'home': 'Home', 'qibla': 'Qibla', 'quran': 'Quran', 'tracker': 'Tracker', 'events': 'Events',
      // Home Screen
      'updated_by': 'Updated by', 'on': 'on',
      'begins': 'Begins', 'jamat': 'Jamat',
      // AppBar & Menus
      'jamat_time': 'Jamat Time', 'contribute_times': 'Contribute Times',
      'qibla_direction': 'Qibla Direction',
      'namaz_tracker': 'Namaz Tracker',
      'dark_mode': 'Dark Mode', 'login_register': 'Login / Register', 'my_contributions': 'My Contributions',
      'change_language': 'Change Language', 'share_app': 'Share App', 'about_us': 'About Us', 'rate_app': 'Rate This App',
      'profile_settings': 'Profile & Settings', 'change_mosque': 'Change Mosque',
      // Alarms
      'set_reminder': 'Set Reminder', 'remind_me_before': 'Remind me before', 'minutes_before': 'Minutes before',
      'cancel': 'Cancel', 'set_alarm': 'Set Alarm', 'reminder_set_for': 'Reminder set for', 'reminder_cancelled': 'Reminder for',
      // Tracker
      'todays_progress': "Today's Progress",
      // Events
      'going': 'going', 'you_are_going': "You're Going", 'i_am_going': 'I am Going',
      // Prayer Names
      'fajr': 'Fajr', 'dhuhr': 'Dhuhr', 'asr': 'Asr', 'maghrib': 'Maghrib', 'isha': 'Isha',
    },
    'bn': {
      // Welcome
      'welcome_title': 'স্বাগতম', 'welcome_subtitle': 'আপনার ভাষা নির্বাচন করুন',
      // Scan / Nearby
      'nearby_mosques_title': 'কাছাকাছি একটি মসজিদ নির্বাচন করুন',
      'scan_results': 'স্ক্যানের ফলাফল', 'nearby_mosques_tab': 'কাছাকাছি মসজিদ', 'nearby_events_tab': 'কাছাকাছি ইভেন্ট',
      // Main Nav
      'home': 'হোম', 'qibla': 'কিবলা', 'quran': 'কুরআন', 'tracker': 'ট্র্যাকার', 'events': 'ইভেন্ট',
      // Home Screen
      'updated_by': 'আপডেট করেছেন', 'on': '',
      'begins': 'শুরু', 'jamat': 'জামাত',
      'change_mosque': 'মসজিদ পরিবর্তন করুন',
      // AppBar & Menus
      'jamat_time': 'জামাতের সময়', 'contribute_times': 'সময় যোগ করুন',
      'qibla_direction': 'কিবলার দিক',
      'namaz_tracker': 'নামাজ ট্র্যাকার',
      'dark_mode': 'ডার্ক মোড', 'login_register': 'লগইন/রেজিস্টার', 'my_contributions': 'আমার অবদান',
      'change_language': 'ভাষা পরিবর্তন', 'share_app': 'অ্যাপ শেয়ার করুন', 'about_us': 'আমাদের সম্পর্কে', 'rate_app': 'অ্যাপটিকে রেট দিন',
      'profile_settings': 'প্রোফাইল ও সেটিংস',
      // Alarms
      'set_reminder': 'রিমাইন্ডার সেট করুন', 'remind_me_before': 'জামাতের আগে আমাকে মনে করিয়ে দিন', 'minutes_before': 'মিনিট আগে',
      'cancel': 'বাতিল', 'set_alarm': 'অ্যালার্ম সেট করুন', 'reminder_set_for': 'এর জন্য রিমাইন্ডার সেট করা হয়েছে', 'reminder_cancelled': 'এর জন্য রিমাইন্ডার বাতিল করা হয়েছে',
      // Tracker
      'todays_progress': "আজকের অগ্রগতি",
      // Events
      'going': 'যাচ্ছেন', 'you_are_going': "আপনি যাচ্ছেন", 'i_am_going': 'আমি যাচ্ছি',
      // Prayer Names
      'fajr': 'ফজর', 'dhuhr': 'যোহর', 'asr': 'আসর', 'maghrib': 'মাগরিব', 'isha': 'এশা',
    },
  };

  String translate(String key) => _localizedValues[locale.languageCode]![key] ?? key;
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) => ['en', 'bn'].contains(locale.languageCode);
  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}