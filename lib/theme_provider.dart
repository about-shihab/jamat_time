import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class AppTheme {
  // --- Celestial Dark Theme ---
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0D0C1D),
    primaryColor: const Color(0xFF3BBA9C),
    hintColor: const Color(0xFFF7D59C),
    cardColor: const Color(0xFF16152C),
    fontFamily: 'Poppins',
    iconTheme: const IconThemeData(color: Colors.white70),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
    ),
    textTheme: TextTheme(
      titleLarge: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: Colors.white.withOpacity(0.9)),
      bodyMedium: TextStyle(color: Colors.white.withOpacity(0.7)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      selectedItemColor: Color(0xFF3BBA9C),
      unselectedItemColor: Colors.grey,
    ),
  );

  // --- Serene Light Theme ---
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF0F5F9),
    primaryColor: const Color(0xFF006A71),
    hintColor: const Color(0xFFC99846),
    cardColor: Colors.white,
    fontFamily: 'Poppins',
    iconTheme: const IconThemeData(color: Colors.black54),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF002729)),
      titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Poppins', color: Color(0xFF002729)),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: Color(0xFF002729), fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: Color(0xFF002729)),
      bodyMedium: TextStyle(color: Colors.black54),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      selectedItemColor: Color(0xFF006A71),
      unselectedItemColor: Colors.grey,
    ),
  );
}