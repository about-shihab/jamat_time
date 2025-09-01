import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamat_time/notification_service.dart';
import 'package:jamat_time/screens/home_screen.dart';
import 'package:jamat_time/theme_provider.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize notification service
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
          theme: AppTheme.lightTheme, // Define light theme
          darkTheme: AppTheme.darkTheme, // Define dark theme
          themeMode: themeProvider.themeMode, // Control theme
          home: const HomeScreen(),
        );
      },
    );
  }
}