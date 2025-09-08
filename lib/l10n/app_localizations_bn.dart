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
}
