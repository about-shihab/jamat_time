import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale;
  bool _hasChosenLanguage;

  LocaleProvider({Locale? initialLocale, bool hasChosenLanguage = false})
      : _locale = initialLocale ?? const Locale('en'),
        _hasChosenLanguage = hasChosenLanguage;

  Locale get locale => _locale;
  bool get hasChosenLanguage => _hasChosenLanguage;

  List<Locale> get supportedLocales => const [Locale('en'), Locale('bn')];

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale && _hasChosenLanguage) return;
    _locale = locale;
    _hasChosenLanguage = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale_code', locale.languageCode);
    notifyListeners();
  }
}
