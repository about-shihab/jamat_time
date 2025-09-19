import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jamat_time/models/quran_word.dart';

class QuranWordService {
  static final _client = Supabase.instance.client;

  /// Fetch up to [limit] active words ordered by occurrence desc.
  static Future<List<QuranWord>> fetchWords({int limit = 125}) async {
    try {
      final res = await _client
          .from('quran_word')
          .select(
              'id, word, transliteration, bn_transliteration, en_translation, bn_translation, occurrence, example_ar, example_ar_en, example_ar_bn, is_active')
          .eq('is_active', 1)
          .order('occurrence', ascending: false)
          .limit(limit);
      final data = (res as List).cast<Map<String, dynamic>>();
      final items = data.map(QuranWord.fromMap).toList();
      if (items.isNotEmpty) return items;
      return _fallback();
    } catch (_) {
      return _fallback();
    }
  }

  static List<QuranWord> _fallback() {
    // Minimal fallback so UI works even if backend not ready.
    final samples = <Map<String, dynamic>>[
      {
        'id': 1,
        'word': 'الْآخِرَة',
        'transliteration': "Al-''aakhirat",
        'bn_transliteration': 'আল-আখিরাত',
        'en_translation': 'the Hereafter',
        'bn_translation': 'আখিরাত',
        'occurrence': 115,
        'example_ar': 'وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
        'example_ar_en':
            '`وَفِي الْآخِرَةِ (and in the Hereafter)` `حَسَنَةً (good,)` `وَقِنَا (and save us)` `عَذَابَ ((from the) punishment)` `النَّارِ ((of) the Fire.)`',
        'example_ar_bn':
            '`وَفِي الْآخِرَةِ (এবং আখিরাতে)` `حَسَنَةً (কল্যাণ),` `وَقِنَا (এবং আমাদের রক্ষা করুন)` `عَذَابَ (শাস্তি থেকে)` `النَّارِ (আগুনের)।`',
        'is_active': 1,
      },
      {
        'id': 2,
        'word': 'عَذَاب',
        'transliteration': "a’zaab",
        'bn_transliteration': 'আযাব',
        'en_translation': 'punishment',
        'bn_translation': 'শাস্তি',
        'occurrence': 322,
        'example_ar': 'وَقِنَا عَذَابَ النَّارِ',
        'example_ar_en':
            '`وَقِنَا (and save us)` `عَذَابَ ((from the) punishment)` `النَّارِ ((of) the Fire.)`',
        'example_ar_bn':
            '`وَقِنَا (এবং আমাদের রক্ষা করুন)` `عَذَابَ (শাস্তি থেকে)` `النَّارِ (আগুনের)।`',
        'is_active': 1,
      },
      {
        'id': 3,
        'word': 'النَّار',
        'transliteration': 'An-naar',
        'bn_transliteration': 'আন-নার',
        'en_translation': 'the Fire',
        'bn_translation': 'আগুন',
        'occurrence': 145,
        'example_ar': 'وَقِنَا عَذَابَ النَّارِ',
        'example_ar_en':
            '`وَقِنَا (and save us)` `عَذَابَ ((from the) punishment)` `النَّارِ ((of) the Fire.)`',
        'example_ar_bn':
            '`وَقِنَا (এবং আমাদের রক্ষা করুন)` `عَذَابَ (শাস্তি থেকে)` `النَّارِ (আগুনের)।`',
        'is_active': 1,
      },
    ];
    final r = Random();
    // Repeat and shuffle to reach 15 items for demo
    final list = List<QuranWord>.from(samples.map(QuranWord.fromMap));
    final pool = List<QuranWord>.from(list);
    while (list.length < 15) {
      list.add(pool[r.nextInt(pool.length)]);
    }
    return list;
  }
}
