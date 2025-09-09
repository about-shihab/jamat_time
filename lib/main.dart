import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jamat_time/app_localizations.dart';
import 'package:jamat_time/notification_service.dart';
import 'package:jamat_time/screens/landing_screen.dart';
import 'package:jamat_time/screens/welcome_screen.dart';
import 'package:jamat_time/theme_provider.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const LanguageWrapper(),
    ),
  );
}

class LanguageWrapper extends StatefulWidget {
  const LanguageWrapper({super.key});

  @override
  State<LanguageWrapper> createState() => _LanguageWrapperState();
}

class _LanguageWrapperState extends State<LanguageWrapper> {
  Locale? _locale;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  void _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('languageCode');
    if (languageCode != null) {
      _locale = Locale(languageCode);
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    if (mounted) setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator())));
    }
    
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      locale: _locale,
      supportedLocales: const [Locale('en', ''), Locale('bn', '')],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      // FIX: WelcomeScreen now only takes onLocaleChange
      home: _locale == null ? WelcomeScreen(onLocaleChange: _setLocale) : const LandingScreen(),
      navigatorObservers: [routeObserver],
    );
  }
}