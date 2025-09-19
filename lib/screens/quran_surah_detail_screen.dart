import 'package:flutter/material.dart';
import 'package:jamat_time/l10n/app_localizations.dart';

import '../models/quran_ayah.dart';
import '../models/quran_language_profile.dart';
import '../models/surah_summary.dart';
import '../services/quran_library_service.dart';
import '../services/quran_reading_prefs.dart';
import '../widgets/aurora_background_painter.dart';

class QuranSurahDetailScreen extends StatefulWidget {
  const QuranSurahDetailScreen({
    super.key,
    required this.summary,
    required this.initialLanguage,
    required this.service,
  });

  final SurahSummary summary;
  final QuranLanguageProfile initialLanguage;
  final QuranLibraryService service;

  @override
  State<QuranSurahDetailScreen> createState() => _QuranSurahDetailScreenState();
}

class _QuranSurahDetailScreenState extends State<QuranSurahDetailScreen>
    with SingleTickerProviderStateMixin {
  late QuranLanguageProfile _language;
  Future<SurahContent>? _contentFuture;
  late final AnimationController _bgController;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
    _bgController =
        AnimationController(vsync: this, duration: const Duration(seconds: 40))
          ..repeat();
    _initialiseFavorite();
    _loadContent();
    QuranReadingPrefs.setLastSurah(
      surahId: widget.summary.id,
      languageCode: _language.code,
    );
  }

  Future<void> _initialiseFavorite() async {
    final fav = await QuranReadingPrefs.isFavorite(widget.summary.id);
    if (!mounted) return;
    setState(() => _isFavorite = fav);
  }

  void _loadContent() {
    setState(() {
      _contentFuture = widget.service.fetchSurahContent(
        summary: widget.summary,
        language: _language,
      );
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  void _toggleFavorite() async {
    final added = await QuranReadingPrefs.toggleFavorite(widget.summary.id);
    if (!mounted) return;
    setState(() => _isFavorite = added);
  }

  void _onLanguageChanged(QuranLanguageProfile? profile) {
    if (profile == null || profile == _language) return;
    _language = profile;
    _initialiseFavorite();
    _loadContent();
    QuranReadingPrefs.setLastSurah(
      surahId: widget.summary.id,
      languageCode: _language.code,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(widget.summary.simpleName),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.star : Icons.star_border,
              color: _isFavorite
                  ? Theme.of(context).colorScheme.secondary
                  : null,
            ),
            onPressed: _toggleFavorite,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<QuranLanguageProfile>(
                value: _language,
                borderRadius: BorderRadius.circular(12),
                onChanged: _onLanguageChanged,
                items: QuranLanguageProfile.values
                    .map(
                      (profile) => DropdownMenuItem<QuranLanguageProfile>(
                        value: profile,
                        child: Text(_languageLabel(profile, l10n)),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          IgnorePointer(
            child: CustomPaint(
              size: Size.infinite,
              painter: AuroraBackgroundPainter(
                animation: _bgController,
                color1: Theme.of(context).primaryColor.withOpacity(0.25),
                color2: Theme.of(context).scaffoldBackgroundColor,
                color3: Theme.of(context).cardColor.withOpacity(0.2),
              ),
            ),
          ),
          SafeArea(
            child: FutureBuilder<SurahContent>(
              future: _contentFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return _ErrorState(
                    message: l10n.quranDetailLoadError,
                    onRetry: _loadContent,
                  );
                }
                final content = snapshot.data;
                if (content == null || content.verses.isEmpty) {
                  return _ErrorState(
                    message: l10n.quranDetailEmpty,
                    onRetry: _loadContent,
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  itemCount: content.verses.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _SurahSummaryHeader(content: content, l10n: l10n);
                    }
                    final ayah = content.verses[index - 1];
                    return _AyahCard(ayah: ayah, l10n: l10n);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
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

class _SurahSummaryHeader extends StatelessWidget {
  const _SurahSummaryHeader({required this.content, required this.l10n});

  final SurahContent content;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final summary = content.summary;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(summary.arabicName,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontFamily: 'NotoNaskhArabic')),
            const SizedBox(height: 8),
            Text(
              summary.simpleName,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              summary.translatedName,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              children: [
                Chip(
                  avatar: const Icon(Icons.menu_book_outlined, size: 18),
                  label: Text(l10n.verseCountLabel(summary.versesCount)),
                ),
                Chip(
                  avatar: const Icon(Icons.travel_explore_outlined, size: 18),
                  label:
                      Text(l10n.revelationPlaceLabel(summary.revelationPlace)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AyahCard extends StatelessWidget {
  const _AyahCard({required this.ayah, required this.l10n});

  final QuranAyahDetail ayah;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  ayah.arabicText,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: 'NotoNaskhArabic',
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${ayah.verseKey} · ${ayah.translation}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(l10n.wordByWordLabel, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            _WordByWordGrid(words: ayah.words),
            if (ayah.tafsir.isNotEmpty) ...[
              const SizedBox(height: 8),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                title: Text(
                  l10n.tafsirLabel,
                  style: theme.textTheme.titleSmall,
                ),
                children: [
                  Text(
                    ayah.tafsir,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WordByWordGrid extends StatelessWidget {
  const _WordByWordGrid({required this.words});

  final List<QuranAyahWord> words;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: words
          .map(
            (word) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context)
                    .colorScheme
                    .surfaceVariant
                    .withOpacity(0.6),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      word.arabic,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontFamily: 'NotoNaskhArabic', fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(word.translation,
                      style: Theme.of(context).textTheme.bodySmall),
                  if (word.transliteration != null &&
                      word.transliteration!.isNotEmpty)
                    Text(
                      word.transliteration!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

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
            Icon(Icons.error_outline,
                size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
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
