import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamat_time/locale_provider.dart';
import 'package:jamat_time/screens/landing_screen.dart';
import 'package:jamat_time/widgets/aurora_background_painter.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 40))
          ..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _choose(BuildContext context, Locale locale) async {
    final localeProvider = context.read<LocaleProvider>();
    await localeProvider.setLocale(locale);
    // After choosing language, go to main flow. LandingScreen will route to
    // scan results if no favorite mosque is saved yet.
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LandingScreen()),
    );
  }

  Widget _buildLanguageButton(
      {required BuildContext context,
      required String title,
      required Locale locale}) {
    return InkWell(
      onTap: () => _choose(context, locale),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 220,
        height: 55,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.3)),
        ),
        child: Center(
          child: Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color1 = theme.primaryColor.withOpacity(0.3);
    final color2 = theme.scaffoldBackgroundColor;
    final color3 = theme.cardColor.withOpacity(0.3);

    return Scaffold(
      body: Stack(
        children: [
          IgnorePointer(
            child: CustomPaint(
              size: Size.infinite,
              painter: AuroraBackgroundPainter(
                animation: _animationController,
                color1: color1,
                color2: color2,
                color3: color3,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.language_outlined,
                        size: 80, color: theme.primaryColor),
                    const SizedBox(height: 20),
                    const Text("Welcome / স্বাগতম",
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    const Text(
                        "Please select your language\nআপনার ভাষা নির্বাচন করুন",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 50),
                    _buildLanguageButton(
                        context: context,
                        title: 'English',
                        locale: const Locale('en')),
                    const SizedBox(height: 20),
                    _buildLanguageButton(
                        context: context,
                        title: 'বাংলা',
                        locale: const Locale('bn')),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
