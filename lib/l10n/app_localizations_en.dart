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

  @override
  String get homeMenu => 'Home';

  @override
  String get qiblaShort => 'Qibla';

  @override
  String get prayerTracker => 'Prayer Tracker';

  @override
  String get quranWordLearner => 'Word Learner';

  @override
  String get events => 'Events';

  @override
  String get fetchingLocation => 'Getting your location...';

  @override
  String get enableLocationServices =>
      'Enable location services to align with the Qibla.';

  @override
  String get retryLabel => 'Retry';

  @override
  String get qiblaCircleHint =>
      'Stand within the circle, align the arrow with the Kaaba, and steady your breathing.';

  @override
  String get qiblaAlignStep1 =>
      'Place your feet shoulder-width apart and face the Kaaba icon.';

  @override
  String get qiblaAlignStep2 =>
      'Rotate gently until the arrow lines up with your chest.';

  @override
  String get qiblaAlignStep3 =>
      'Relax your shoulders, breathe in, and set your intention.';

  @override
  String get locationUnknown => 'Unknown location';

  @override
  String coordinatesLabel(Object lat, Object lon) {
    return 'Lat $lat, Lon $lon';
  }

  @override
  String qiblaBearingLabel(Object degrees) {
    return 'Qibla bearing: $degrees° from true north';
  }

  @override
  String get orientationSummary => 'Orientation summary';

  @override
  String get orientationUnknown => 'Orientation not available yet';

  @override
  String get distanceUnknown => 'Distance unavailable';

  @override
  String qiblaDistanceLabel(Object kilometers) {
    return 'Distance to Kaaba: $kilometers km';
  }

  @override
  String get quranLanguageLabel => 'Recitation language';

  @override
  String get quranLoadError => 'We couldn\'t load the surah list right now.';

  @override
  String get quranEmptyLibrary => 'No surahs available.';

  @override
  String verseCountLabel(int count) {
    return 'Verses: $count';
  }

  @override
  String revelationPlaceLabel(Object place) {
    return 'Revealed in $place';
  }

  @override
  String get quranDetailLoadError => 'Unable to load surah details.';

  @override
  String get quranDetailEmpty => 'No verses to display for this surah.';

  @override
  String get wordByWordLabel => 'Word-by-word translation';

  @override
  String get tafsirLabel => 'Tafsir';

  @override
  String get monthlyOverviewTitle => 'Monthly prayed overview';

  @override
  String get monthlyOverviewCaption =>
      'Percentages reflect how many days you marked each prayer for this month.';

  @override
  String get settingsAppearanceSection => 'Appearance';

  @override
  String get settingsGeneralSection => 'General';

  @override
  String get settingsSupportSection => 'Support';

  @override
  String get notificationsLabel => 'Prayer reminders';

  @override
  String get notificationsDescription =>
      'Enable reminders for upcoming prayers and jamat times.';

  @override
  String get aboutUsSubtitle => 'Learn more about the team and vision.';

  @override
  String get rateThisAppSubtitle => 'Share your feedback with a quick review.';

  @override
  String get rateThisAppError =>
      'We couldn\'t open the store page. Please try again later.';

  @override
  String get aboutHeadline => 'Connecting hearts through prayer';

  @override
  String get aboutDescription =>
      'Jamat Time helps you discover prayer times, nearby masjids, and community events with a modern experience.';

  @override
  String get aboutMissionTitle => 'Our Mission';

  @override
  String get aboutMissionBody =>
      'To empower every Muslim to stay connected with the masjid and never miss a congregational prayer.';

  @override
  String get aboutFeaturesTitle => 'What you\'ll love';

  @override
  String get aboutFeaturePrayer =>
      'Track daily prayers and monitor your monthly progress.';

  @override
  String get aboutFeatureCommunity =>
      'Discover community events and nearby masjids at a glance.';

  @override
  String get aboutFeatureLearning =>
      'Deepen your Quran journey with translations, tafsir, and word-by-word study.';

  @override
  String get aboutFeatureCompass =>
      'Face the Qibla confidently with a guided compass experience.';

  @override
  String get aboutContactTitle => 'Stay connected';

  @override
  String get aboutContactBody =>
      'We\'d love to hear from you at support@jamattime.app. Send feedback, stories, or salaam!';

  @override
  String get qiblaSourceTitle => 'Direction source';

  @override
  String get qiblaSourceLoading =>
      'Contacting Al Adhan for a precise bearing...';

  @override
  String qiblaSourceSuccess(Object degrees) {
    return 'Al Adhan reports a bearing of $degrees° from true north.';
  }

  @override
  String qiblaSourceComparison(Object degrees) {
    return 'Device fallback bearing: $degrees°.';
  }

  @override
  String get qiblaSourceFallback =>
      'Could not reach Al Adhan. Using the device-calculated direction instead.';

  @override
  String get qiblaTipsTitle => 'Alignment tips';

  @override
  String get quranLastReadLabel => 'Last read';

  @override
  String get quranFavoritesLabel => 'Favorite surahs';

  @override
  String get noDataLabel => 'No prayer data yet';

  @override
  String get trackerDateLabel => 'Date';
}
