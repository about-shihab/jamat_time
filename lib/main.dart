import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamat_time/notification_service.dart';
import 'package:jamat_time/screens/main_screen.dart'; // <-- Point to the new main screen
import 'package:jamat_time/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const JamatTimeApp(),
    ),
  );
}

class JamatTimeApp extends StatelessWidget {
  const JamatTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Jamat Time',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const MainScreen(), // <-- The new home widget
        );
      },
    );
  }
}