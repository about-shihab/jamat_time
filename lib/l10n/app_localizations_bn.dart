// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'জামাত টাইম';

  @override
  String get today => 'আজ';

  @override
  String get settings => 'সেটিংস';

  @override
  String get darkMode => 'ডার্ক মোড';

  @override
  String get loginRegister => 'লগইন / রেজিস্টার';

  @override
  String get aboutUs => 'আমাদের সম্পর্কে';

  @override
  String get rateThisApp => 'এই অ্যাপটি রেট করুন';

  @override
  String get language => 'ভাষা';

  @override
  String get english => 'ইংরেজি';

  @override
  String get bangla => 'বাংলা';

  @override
  String get getDirections => 'দিকনির্দেশ নিন';

  @override
  String get syncPrayerTimes => 'নামাজের সময় সিঙ্ক করুন';

  @override
  String get syncingPrayerTimes => 'নামাজের সময় সিঙ্ক হচ্ছে...';

  @override
  String get openingMaps => 'ম্যাপ খুলছে...';

  @override
  String get begins => 'শুরু';

  @override
  String get ends => 'শেষ';

  @override
  String get jamat => 'জামাত';

  @override
  String get welcomeTitle => 'জামাত টাইমে স্বাগতম';

  @override
  String get welcomeSubtitle => 'আপনার আশেপাশের মসজিদের নামাজের সময় খুঁজুন।';

  @override
  String get scan => 'স্ক্যান';

  @override
  String get scanResults => 'স্ক্যান ফলাফল';

  @override
  String get nearbyMosques => 'কাছাকাছি মসজিদ';

  @override
  String get nearbyEvents => 'কাছাকাছি ইভেন্ট';

  @override
  String get settingsTitle => 'সেটিংস';

  @override
  String get namazTracker => 'নামাজ ট্র্যাকার';

  @override
  String get todaysProgress => 'আজকের অগ্রগতি';

  @override
  String get qiblaDirection => 'কিবলার দিক';

  @override
  String get quran => 'কুরআন';

  @override
  String get contributeTimes => 'সময় যোগ করুন';

  @override
  String get contributeMosqueTime => 'মসজিদের সময় যোগ করুন';

  @override
  String get searchHint => 'মসজিদের নাম বা এলাকা দিয়ে খুঁজুন...';

  @override
  String get updateTimes => 'সময় হালনাগাদ';

  @override
  String get save => 'সংরক্ষণ';

  @override
  String get jazakallahSubmitted =>
      'জাযাকাল্লাহ খাইর! সময় সফলভাবে জমা হয়েছে।';

  @override
  String get setReminder => 'রিমাইন্ডার সেট করুন';

  @override
  String get minutesBeforeJamat => 'জামাতের আগে মিনিট';

  @override
  String get cancel => 'বাতিল';

  @override
  String get set => 'সেট';

  @override
  String reminderCancelled(Object prayer) {
    return '$prayer এর রিমাইন্ডার বাতিল করা হয়েছে।';
  }

  @override
  String reminderSet(Object prayer) {
    return '$prayer এর জন্য রিমাইন্ডার সেট হয়েছে।';
  }

  @override
  String updatedByOn(Object name, Object date) {
    return '$name দ্বারা $date তারিখে হালনাগাদ';
  }

  @override
  String get thankYouContribution => 'আপনার অবদানের জন্য ধন্যবাদ!';

  @override
  String get submit => 'জমা দিন';

  @override
  String get yourName => 'আপনার নাম';

  @override
  String get mobileNumber => 'মোবাইল নম্বর';

  @override
  String get mosqueNameLocation => 'মসজিদের নাম ও অবস্থান';

  @override
  String goingCount(int count) {
    return '$count জন যাচ্ছেন';
  }

  @override
  String get youreGoing => 'আপনি যাচ্ছেন';

  @override
  String get inshaAllahGo => 'ইনশাআল্লাহ, আমি যাব';

  @override
  String get discoverMosques => 'মসজিদ খুঁজুন';

  @override
  String get chattogram => 'চট্টগ্রাম';

  @override
  String get chattogramBangladesh => 'চট্টগ্রাম, বাংলাদেশ';

  @override
  String get rescanNearby => 'কাছাকাছি মসজিদ পুনঃস্ক্যান';

  @override
  String get generalPrayerSchedule => 'সাধারণ নামাজের সময়সূচি';

  @override
  String get prayerFajr => 'ফজর';

  @override
  String get prayerDhuhr => 'যোহর';

  @override
  String get prayerAsr => 'আসর';

  @override
  String get prayerMaghrib => 'মাগরিব';

  @override
  String get prayerIsha => 'ইশা';

  @override
  String get homeMenu => 'হোম';

  @override
  String get qiblaShort => 'কিবলা';

  @override
  String get prayerTracker => 'নামাজ ট্র্যাকার';

  @override
  String get quranWordLearner => 'বাক্য শেখা';

  @override
  String get events => 'ইভেন্ট';

  @override
  String get fetchingLocation => 'আপনার অবস্থান নেওয়া হচ্ছে...';

  @override
  String get enableLocationServices =>
      'কিবলার সঙ্গে মিলানোর জন্য লোকেশন পরিষেবা চালু করুন।';

  @override
  String get retryLabel => 'পুনরায় চেষ্টা করুন';

  @override
  String get qiblaCircleHint =>
      'বৃত্তের মধ্যে দাঁড়ান, তীরকে কাবার সাথে মিলিয়ে নিন এবং শ্বাস ধীরে নিন।';

  @override
  String get qiblaAlignStep1 =>
      'পা কাঁধ-প্রস্থে রেখে কিবা আইকনের দিকে দাঁড়ান।';

  @override
  String get qiblaAlignStep2 =>
      'তীর আপনার বুকে সারিবদ্ধ না হওয়া পর্যন্ত ধীরে ধীরে ঘুরুন।';

  @override
  String get qiblaAlignStep3 =>
      'কাঁধ শিথিল করুন, গভীর শ্বাস নিন এবং নিয়ত ঠিক করুন।';

  @override
  String get locationUnknown => 'অজানা অবস্থান';

  @override
  String coordinatesLabel(Object lat, Object lon) {
    return 'অক্ষাংশ $lat, দ্রাঘিমাংশ $lon';
  }

  @override
  String qiblaBearingLabel(Object degrees) {
    return 'কিবলার দিক: উত্তর থেকে $degrees°';
  }

  @override
  String get orientationSummary => 'অভিমুখ সংক্ষেপ';

  @override
  String get orientationUnknown => 'অভিমুখ এখনো নির্ধারিত হয়নি';

  @override
  String get distanceUnknown => 'দূরত্ব পাওয়া যায়নি';

  @override
  String qiblaDistanceLabel(Object kilometers) {
    return 'কাবার দূরত্ব: $kilometers কিমি';
  }

  @override
  String get quranLanguageLabel => 'পাঠের ভাষা';

  @override
  String get quranLoadError => 'এ মুহূর্তে সূরা তালিকা আনা গেল না।';

  @override
  String get quranEmptyLibrary => 'কোনো সূরা পাওয়া যায়নি।';

  @override
  String verseCountLabel(int count) {
    return 'আয়াত: $count';
  }

  @override
  String revelationPlaceLabel(Object place) {
    return '$place এ অবতীর্ণ';
  }

  @override
  String get quranDetailLoadError => 'সূরার বিস্তারিত লোড করা যায়নি।';

  @override
  String get quranDetailEmpty => 'এই সূরার জন্য প্রদর্শনের মতো আয়াত নেই।';

  @override
  String get wordByWordLabel => 'শব্দে শব্দে অনুবাদ';

  @override
  String get tafsirLabel => 'তাফসির';

  @override
  String get monthlyOverviewTitle => 'মাসিক নামাজের সারাংশ';

  @override
  String get monthlyOverviewCaption =>
      'এই মাসে প্রতিটি নামাজ কতদিন পড়েছেন তার শতকরা হিসাব।';

  @override
  String get settingsAppearanceSection => 'রূপ';

  @override
  String get settingsGeneralSection => 'সাধারণ';

  @override
  String get settingsSupportSection => 'সহায়তা';

  @override
  String get notificationsLabel => 'নামাজ রিমাইন্ডার';

  @override
  String get notificationsDescription =>
      'নামাজ ও জামাতের আগে স্মরণ করিয়ে দিন চালু করুন।';

  @override
  String get aboutUsSubtitle => 'দল ও স্বপ্ন সম্পর্কে জানুন।';

  @override
  String get rateThisAppSubtitle => 'একটি দ্রুত রিভিউ দিয়ে মতামত দিন।';

  @override
  String get rateThisAppError => 'স্টোর পেজ খোলা যায়নি। পরে আবার চেষ্টা করুন।';

  @override
  String get aboutHeadline => 'নামাজের মাধ্যমে হৃদয়ের সংযোগ';

  @override
  String get aboutDescription =>
      'জমাত টাইম আধুনিক অভিজ্ঞতায় নামাজের সময়, নিকটবর্তী মসজিদ ও কমিউনিটি ইভেন্ট খুঁজে দেয়।';

  @override
  String get aboutMissionTitle => 'আমাদের লক্ষ্য';

  @override
  String get aboutMissionBody =>
      'প্রতিটি মুসলিম যেন মসজিদের সাথে সংযুক্ত থাকে এবং জামাতে নামাজ মিস না করে—এই লক্ষ্যেই আমাদের কাজ।';

  @override
  String get aboutFeaturesTitle => 'আপনি যা পছন্দ করবেন';

  @override
  String get aboutFeaturePrayer =>
      'দৈনিক নামাজ ট্র্যাক করুন এবং মাসিক অগ্রগতি দেখুন।';

  @override
  String get aboutFeatureCommunity =>
      'এক নজরে নিকটবর্তী মসজিদ ও ইভেন্ট আবিষ্কার করুন।';

  @override
  String get aboutFeatureLearning =>
      'অনুবাদ, তাফসির এবং শব্দে শব্দে অধ্যয়নের মাধ্যমে কুরআনের যাত্রা গভীর করুন।';

  @override
  String get aboutFeatureCompass =>
      'এআই-নির্দেশিত কম্পাসে আত্মবিশ্বাস নিয়ে কিবলার মুখোমুখি হন।';

  @override
  String get aboutContactTitle => 'যোগাযোগে থাকুন';

  @override
  String get aboutContactBody =>
      'support@jamattime.app এ আমাদের জানান। মতামত, গল্প কিংবা সালাম—সবাইকে স্বাগতম!';

  @override
  String get qiblaSourceTitle => 'দিকের উৎস';

  @override
  String get qiblaSourceLoading =>
      'সঠিক দিক জানার জন্য আল আদহানকে জিজ্ঞেস করা হচ্ছে...';

  @override
  String qiblaSourceSuccess(Object degrees) {
    return 'আল আদহান জানাচ্ছে দিক $degrees° (উত্তর থেকে)।';
  }

  @override
  String qiblaSourceComparison(Object degrees) {
    return 'যন্ত্রের হিসাবে দিক $degrees°।';
  }

  @override
  String get qiblaSourceFallback =>
      'আল আদহানের সাথে যোগাযোগ করা গেল না। যন্ত্রের হিসাব দেখানো হচ্ছে।';

  @override
  String get qiblaTipsTitle => 'সঠিকভাবে দাঁড়ানোর টিপস';

  @override
  String get quranLastReadLabel => 'শেষ পড়া';

  @override
  String get quranFavoritesLabel => 'পছন্দের সূরা';

  @override
  String get noDataLabel => 'কোনো নামাজের রেকর্ড নেই';

  @override
  String get trackerDateLabel => 'তারিখ';
}
