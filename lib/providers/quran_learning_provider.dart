import 'dart:math';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:jamat_time/models/quran_word.dart';
import 'package:jamat_time/services/quran_word_service.dart';

class QuranLearningProvider extends ChangeNotifier {
  QuranLearningProvider();

  List<QuranWord> _allWords = [];
  bool _loading = false;
  bool _loaded = false;

  // Section state
  // 10 words per section, last may be fewer.
  static const int wordsPerSection = 10;
  Set<int> _unlockedSections = {0};
  Set<int> _completedSections = {};
  // Tracks viewed words per section during learning session
  final Map<int, Set<int>> _viewedWordIdsBySection = {};

  // Quiz pass threshold (e.g., 80%)
  static const double passThreshold = 0.8;

  bool get loading => _loading;
  bool get loaded => _loaded;
  List<QuranWord> get allWords => _allWords;

  int get sectionCount => (_allWords.length / wordsPerSection).ceil();
  bool isSectionUnlocked(int sectionIndex) => _unlockedSections.contains(sectionIndex);
  bool isSectionCompleted(int sectionIndex) => _completedSections.contains(sectionIndex);

  double sectionProgress(int sectionIndex) {
    final total = sectionWords(sectionIndex).length;
    if (total == 0) return 0;
    final viewed = _viewedWordIdsBySection[sectionIndex]?.length ?? 0;
    return viewed.clamp(0, total) / total;
  }

  List<QuranWord> sectionWords(int sectionIndex) {
    final start = sectionIndex * wordsPerSection;
    final end = min(start + wordsPerSection, _allWords.length);
    if (start >= _allWords.length || start >= end) return const [];
    return _allWords.sublist(start, end);
  }

  Future<void> load() async {
    if (_loading || _loaded) return;
    _loading = true;
    notifyListeners();
    try {
      // Try cache first
      try {
        final prefs = await SharedPreferences.getInstance();
        final raw = prefs.getString('quran_words_cache_v1');
        if (raw != null && raw.isNotEmpty) {
          final List<dynamic> list = List<dynamic>.from(jsonDecode(raw));
          _allWords = list
              .whereType<Map<String, dynamic>>()
              .map(QuranWord.fromMap)
              .toList();
        }
      } catch (_) {}
      if (_allWords.isEmpty) {
        _allWords = await QuranWordService.fetchWords(limit: 125);
        // Save cache
        try {
          final prefs = await SharedPreferences.getInstance();
          final raw = jsonEncode(_allWords.map((e) => e.toMap()).toList());
          await prefs.setString('quran_words_cache_v1', raw);
        } catch (_) {}
      } else {
        // Refresh in background without blocking UI
        unawaited(() async {
          try {
            final fresh = await QuranWordService.fetchWords(limit: 125);
            if (fresh.isNotEmpty) {
              _allWords = fresh;
              final prefs = await SharedPreferences.getInstance();
              final raw = jsonEncode(_allWords.map((e) => e.toMap()).toList());
              await prefs.setString('quran_words_cache_v1', raw);
              notifyListeners();
            }
          } catch (_) {}
        }());
      }
      await _loadProgress();
    } finally {
      _loading = false;
      _loaded = true;
      notifyListeners();
    }
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final unlocked = prefs.getStringList('quran_unlocked_sections') ?? ['0'];
    final completed = prefs.getStringList('quran_completed_sections') ?? <String>[];
    _unlockedSections = unlocked.map(int.parse).toSet();
    _completedSections = completed.map(int.parse).toSet();
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('quran_unlocked_sections',
        _unlockedSections.map((e) => e.toString()).toList());
    await prefs.setStringList('quran_completed_sections',
        _completedSections.map((e) => e.toString()).toList());
  }

  void markWordViewed(int sectionIndex, int wordId) {
    final set = _viewedWordIdsBySection.putIfAbsent(sectionIndex, () => <int>{});
    set.add(wordId);
    notifyListeners();
  }

  bool canStartTest(int sectionIndex) {
    final words = sectionWords(sectionIndex);
    final viewed = _viewedWordIdsBySection[sectionIndex]?.length ?? 0;
    return words.isNotEmpty && viewed >= words.length;
  }

  Future<void> markSectionCompleted(int sectionIndex) async {
    _completedSections.add(sectionIndex);
    if (sectionIndex + 1 < sectionCount) {
      _unlockedSections.add(sectionIndex + 1);
    }
    await _saveProgress();
    notifyListeners();
  }

  // Quiz generation utilities
  List<QuizQuestion> buildSectionQuiz(int sectionIndex, {String languageCode = 'en'}) {
    final rnd = Random();
    final words = sectionWords(sectionIndex);
    // Use all words for distractors to increase variety
    final pool = List<QuranWord>.from(_allWords);
    final items = <QuizQuestion>[];
    for (final w in words) {
      final useBn = languageCode.toLowerCase().startsWith('bn');
      final correct =
          (useBn ? w.bnTranslation : w.enTranslation)?.trim();
      if (correct == null || correct.isEmpty) continue;
      final options = <String>{correct};
      // Pick 3 unique distractors
      while (options.length < 4 && pool.isNotEmpty) {
        final p = pool[rnd.nextInt(pool.length)];
        final candidate = (useBn ? p.bnTranslation : p.enTranslation)?.trim();
        if (candidate != null && candidate.isNotEmpty) options.add(candidate);
      }
      final shuffled = options.toList()..shuffle(rnd);
      items.add(QuizQuestion(word: w, options: shuffled, correct: correct));
    }
    return items;
  }
}

class QuizQuestion {
  final QuranWord word;
  final List<String> options;
  final String correct;
  const QuizQuestion({required this.word, required this.options, required this.correct});
}
