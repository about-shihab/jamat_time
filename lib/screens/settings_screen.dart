import 'package:flutter/material.dart';
import 'package:jamat_time/config.dart';
import 'package:jamat_time/l10n/app_localizations.dart';
import 'package:jamat_time/locale_provider.dart';
import 'package:jamat_time/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'about_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _notificationsKey = 'notifications_enabled';
  bool _loading = true;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
      _loading = false;
    });
  }

  Future<void> _updateNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, value);
    setState(() => _notificationsEnabled = value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _SectionHeader(title: l10n.settingsAppearanceSection),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: SwitchListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(l10n.darkMode,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontSize: 16)),
                  value: themeProvider.isDarkMode,
                  onChanged: themeProvider.toggleTheme,
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: l10n.settingsGeneralSection),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.language),
              title: Text(l10n.language),
              subtitle: Text(_currentLanguageLabel(context, l10n)),
              onTap: () => _showLanguageSheet(context, l10n),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: Text(l10n.notificationsLabel),
              subtitle: Text(l10n.notificationsDescription),
              value: _notificationsEnabled,
              onChanged: _updateNotifications,
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: l10n.settingsSupportSection),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(l10n.aboutUs),
              subtitle: Text(l10n.aboutUsSubtitle),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.star_rate_rounded),
              title: Text(l10n.rateThisApp),
              subtitle: Text(l10n.rateThisAppSubtitle),
              onTap: _launchStore,
            ),
          ),
        ],
      ),
    );
  }

  String _currentLanguageLabel(BuildContext context, AppLocalizations l10n) {
    final locale =
        Provider.of<LocaleProvider>(context, listen: false).locale.languageCode;
    return locale.startsWith('bn') ? l10n.bangla : l10n.english;
  }

  Future<void> _showLanguageSheet(
      BuildContext context, AppLocalizations l10n) async {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final selected = await showModalBottomSheet<Locale>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        final current = localeProvider.locale.languageCode;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(l10n.language),
            ),
            RadioListTile<String>(
              value: 'en',
              groupValue: current,
              title: Text(l10n.english),
              onChanged: (value) => Navigator.pop(context, const Locale('en')),
            ),
            RadioListTile<String>(
              value: 'bn',
              groupValue: current,
              title: Text(l10n.bangla),
              onChanged: (value) => Navigator.pop(context, const Locale('bn')),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
    if (selected != null) {
      await localeProvider.setLocale(selected);
      if (mounted) setState(() {});
    }
  }

  Future<void> _launchStore() async {
    final url = Uri.tryParse(AppConfig.appReviewUrl);
    if (url == null) return;
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.rateThisAppError)));
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}
