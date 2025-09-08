// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Jamat Time';

  @override
  String get today => 'Today';

  @override
  String get settings => 'Settings';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get loginRegister => 'Login / Register';

  @override
  String get aboutUs => 'About Us';

  @override
  String get rateThisApp => 'Rate This App';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get bangla => 'Bangla';

  @override
  String get getDirections => 'Get Directions';

  @override
  String get syncPrayerTimes => 'Sync Prayer Times';

  @override
  String get syncingPrayerTimes => 'Syncing prayer times...';

  @override
  String get openingMaps => 'Opening maps...';

  @override
  String get begins => 'Begins';

  @override
  String get ends => 'Ends';

  @override
  String get jamat => 'Jamat';

  @override
  String get welcomeTitle => 'Welcome to Jamat Time';

  @override
  String get welcomeSubtitle => 'Find prayer times at your local mosques.';

  @override
  String get scan => 'SCAN';

  @override
  String get scanResults => 'Scan Results';

  @override
  String get nearbyMosques => 'Nearby Mosques';

  @override
  String get nearbyEvents => 'Nearby Events';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get namazTracker => 'Namaz Tracker';

  @override
  String get todaysProgress => 'Today\'s Progress';

  @override
  String get qiblaDirection => 'Qibla Direction';

  @override
  String get quran => 'Quran';

  @override
  String get contributeTimes => 'Contribute Times';

  @override
  String get contributeMosqueTime => 'Contribute Mosque Time';

  @override
  String get searchHint => 'Search by mosque name or area...';

  @override
  String get updateTimes => 'Update Times';

  @override
  String get save => 'Save';

  @override
  String get jazakallahSubmitted =>
      'JazakAllah Khair! Times submitted successfully.';

  @override
  String get setReminder => 'Set Reminder';

  @override
  String get minutesBeforeJamat => 'Minutes before Jamat';

  @override
  String get cancel => 'Cancel';

  @override
  String get set => 'Set';

  @override
  String reminderCancelled(Object prayer) {
    return 'Reminder for $prayer cancelled.';
  }

  @override
  String reminderSet(Object prayer) {
    return 'Reminder set for $prayer.';
  }

  @override
  String updatedByOn(Object name, Object date) {
    return 'Updated by $name on $date';
  }

  @override
  String get thankYouContribution => 'Thank you for your contribution!';

  @override
  String get submit => 'Submit';

  @override
  String get yourName => 'Your Name';

  @override
  String get mobileNumber => 'Mobile Number';

  @override
  String get mosqueNameLocation => 'Mosque Name & Location';

  @override
  String goingCount(int count) {
    return '$count going';
  }

  @override
  String get youreGoing => 'You\'re Going';

  @override
  String get inshaAllahGo => 'Insha\'Allah, I will go';

  @override
  String get discoverMosques => 'Discover Mosques';

  @override
  String get chattogram => 'Chattogram';

  @override
  String get chattogramBangladesh => 'Chattogram, Bangladesh';

  @override
  String get rescanNearby => 'Rescan Nearby Mosques';

  @override
  String get generalPrayerSchedule => 'General Prayer Schedule';

  @override
  String get prayerFajr => 'Fajr';

  @override
  String get prayerDhuhr => 'Dhuhr';

  @override
  String get prayerAsr => 'Asr';

  @override
  String get prayerMaghrib => 'Maghrib';

  @override
  String get prayerIsha => 'Isha';
}
