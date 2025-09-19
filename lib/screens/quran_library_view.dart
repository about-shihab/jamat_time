import 'package:flutter/material.dart';
import 'package:jamat_time/l10n/app_localizations.dart';

import '../models/quran_language_profile.dart';
import '../models/surah_summary.dart';
import '../services/quran_library_service.dart';
import '../services/quran_reading_prefs.dart';
import 'quran_surah_detail_screen.dart';

class QuranLibraryView extends StatefulWidget {
  const QuranLibraryView({super.key});

  @override
  State<QuranLibraryView> createState() => _QuranLibraryViewState();
}

class _QuranLibraryViewState extends State<QuranLibraryView> {
  final QuranLibraryService _service = QuranLibraryService();
  Future<List<SurahSummary>>? _surahFuture;
  QuranLanguageProfile? _language;
  Set<int> _favoriteIds = {};
  int? _lastReadId;
  bool _metaLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReadingState();
  }

  Future<void> _loadReadingState() async {
    final favorites = await QuranReadingPrefs.favoriteSurahIds();
    final last = await QuranReadingPrefs.lastSurahId();
    if (!mounted) return;
    setState(() {
      _favoriteIds = favorites;
      _lastReadId = last;
      _metaLoading = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _language ??= QuranLanguageProfile.preferredFor(
        Localizations.localeOf(context).languageCode);
    _surahFuture ??= _service.fetchSurahList(languageCode: _language!.code);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final language = _language ?? QuranLanguageProfile.english;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(l10n.quran)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(Icons.translate,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<QuranLanguageProfile>(
                    value: language,
                    decoration: InputDecoration(
                      labelText: l10n.quranLanguageLabel,
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12))),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    items: QuranLanguageProfile.values
                        .map(
                          (profile) => DropdownMenuItem<QuranLanguageProfile>(
                            value: profile,
                            child: Text(_languageLabel(profile, l10n)),
                          ),
                        )
                        .toList(),
                    onChanged: _onLanguageChanged,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<SurahSummary>>(
              future: _surahFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return _ErrorView(
                    message: l10n.quranLoadError,
                    onRetry: () => setState(() {
                      _surahFuture =
                          _service.fetchSurahList(languageCode: language.code);
                    }),
                  );
                }
                final surahs = snapshot.data ?? [];
                if (surahs.isEmpty) {
                  return _ErrorView(
                    message: l10n.quranEmptyLibrary,
                    onRetry: () => setState(() {
                      _surahFuture =
                          _service.fetchSurahList(languageCode: language.code);
                    }),
                  );
                }
                SurahSummary? lastReadSummary;
                if (!_metaLoading && _lastReadId != null) {
                  try {
                    lastReadSummary =
                        surahs.firstWhere((s) => s.id == _lastReadId);
                  } catch (_) {
                    lastReadSummary = null;
                  }
                }
                final favoriteSummaries = surahs
                    .where((s) => _favoriteIds.contains(s.id))
                    .toList();

                final items = <Widget>[];
                if (!_metaLoading && lastReadSummary != null) {
                  items.add(Card(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    elevation: 0,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.12),
                        foregroundColor:
                            Theme.of(context).colorScheme.primary,
                        child: const Icon(Icons.bookmark_added),
                      ),
                      title: Text(l10n.quranLastReadLabel),
                      subtitle: Text('${lastReadSummary.simpleName} � ${lastReadSummary.versesCount} ayat'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => _openSurah(lastReadSummary!, language),
                    ),
                  ));
                }
                if (!_metaLoading && favoriteSummaries.isNotEmpty) {
                  items.add(Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.quranFavoritesLabel,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 44,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: favoriteSummaries.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final fav = favoriteSummaries[index];
                              return ActionChip(
                                avatar: const Icon(Icons.star, size: 16),
                                label: Text(fav.simpleName),
                                onPressed: () => _openSurah(fav, language),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ));
                }

                items.addAll(surahs.map((summary) {
                  final isFavorite = _favoriteIds.contains(summary.id);
                  return Card(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    elevation: 0,
                    child: ListTile(
                      onTap: () => _openSurah(summary, language),
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.12),
                        foregroundColor:
                            Theme.of(context).colorScheme.primary,
                        child: Text('${summary.id}'),
                      ),
                      title: Text('${summary.simpleName} � ${summary.arabicName}',
                          style: Theme.of(context).textTheme.titleMedium),
                      subtitle: Text(
                        '${summary.translatedName} � ${l10n.verseCountLabel(summary.versesCount)} � ${l10n.revelationPlaceLabel(summary.revelationPlace)}',
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.star : Icons.star_border,
                          color: isFavorite
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).hintColor,
                        ),
                        onPressed: () => _toggleFavorite(summary.id),
                      ),
                    ),
                  );
                }));

                return ListView(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
                  children: items,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFavorite(int surahId) async {
    final added = await QuranReadingPrefs.toggleFavorite(surahId);
    if (!mounted) return;
    setState(() {
      if (added) {
        _favoriteIds.add(surahId);
      } else {
        _favoriteIds.remove(surahId);
      }
    });
  }

  void _onLanguageChanged(QuranLanguageProfile? profile) {
    if (profile == null || profile == _language) return;
    setState(() {
      _language = profile;
      _surahFuture = _service.fetchSurahList(languageCode: profile.code);
      _metaLoading = true;
    });
    _loadReadingState();
  }

  void _openSurah(SurahSummary summary, QuranLanguageProfile language) {
    setState(() => _lastReadId = summary.id);
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => QuranSurahDetailScreen(
          summary: summary,
          initialLanguage: language,
          service: _service,
        ),
      ),
    )
        .then((_) => _loadReadingState());
  }

  String _languageLabel(QuranLanguageProfile profile, AppLocalizations l10n) {
    switch (profile.code) {
      case 'bn':
        return l10n.bangla;
      case 'en':
      default:
        return l10n.english;
    }
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_outlined,
                size: 56, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context)!.retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}
