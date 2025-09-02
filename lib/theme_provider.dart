import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  // Default to light mode as requested
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class AppTheme {
  // --- Color Palette ---
  static const Color primaryLight = Color(0xFFEAF6F6); // Soft Cyan White
  static const Color primaryDark = Color(0xFF0D1B2A);  // Deep Navy
  static const Color accentColor = Color(0xFF08A092);  // Serene Teal
  static const Color accentGold = Color(0xFFD4AF37);  // Subtle Gold
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF1B263B);
  static const Color textLight = Color(0xFF0D1B2A);
  static const Color textDark = Colors.white70;

  // --- Light Theme Data ---
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: accentColor,
    scaffoldBackgroundColor: primaryLight,
    fontFamily: 'Poppins',
    hintColor: accentColor,
    cardColor: cardLight,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryLight,
      elevation: 0,
      iconTheme: const IconThemeData(color: textLight),
      titleTextStyle: const TextStyle(
          color: textLight, fontSize: 21, fontFamily: 'Poppins', fontWeight: FontWeight.bold),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: textLight, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: textLight),
      bodyMedium: TextStyle(color: Colors.black54),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentColor,
      foregroundColor: Colors.white,
    ),
  );

  // --- Dark Theme Data ---
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: accentColor,
    scaffoldBackgroundColor: primaryDark,
    fontFamily: 'Poppins',
    hintColor: accentColor,
    cardColor: cardDark,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryDark,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(
          color: Colors.white, fontSize: 21, fontFamily: 'Poppins', fontWeight: FontWeight.bold),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: textDark),
      bodyMedium: TextStyle(color: Colors.white60),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentColor,
      foregroundColor: Colors.white,
    ),
  );
}