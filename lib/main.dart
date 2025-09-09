import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamat_time/notification_service.dart';
import 'package:jamat_time/screens/landing_screen.dart';
import 'package:jamat_time/theme_provider.dart';
import 'package:jamat_time/locale_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:jamat_time/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jamat_time/screens/welcome_screen.dart';
import 'package:jamat_time/providers/location_provider.dart';
import 'package:jamat_time/providers/prayer_times_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jamat_time/config.dart';
import 'package:jamat_time/services/prayer_type_cache.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  if (AppConfig.supabaseUrl.isNotEmpty && AppConfig.supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
    // Preload prayer_type cache once
    try {
      await PrayerTypeCache.ensureLoaded();
    } catch (_) {}
  }
  // Load saved locale to decide if welcome screen is needed
  final prefs = await SharedPreferences.getInstance();
  final code = prefs.getString('locale_code');
  final initialLocale = code != null ? Locale(code) : const Locale('en');
  final hasChosenLanguage = code != null;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
            create: (_) => LocaleProvider(
                  initialLocale: initialLocale,
                  hasChosenLanguage: hasChosenLanguage,
                )),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => PrayerTimesProvider()),
      ],
      child: const JamatTimeApp(),
    ),
  );
}

class JamatTimeApp extends StatelessWidget {
  const JamatTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          locale: localeProvider.locale,
          supportedLocales: localeProvider.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: localeProvider.hasChosenLanguage
              ? const LandingScreen()
              : const WelcomeScreen(),
        );
      },
    );
  }
}
