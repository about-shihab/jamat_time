import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamat_time/providers/quran_learning_provider.dart';
import 'package:jamat_time/widgets/aurora_background_painter.dart';
import 'package:jamat_time/widgets/custom_app_bar.dart';

class QuranWordTestScreen extends StatefulWidget {
  final int sectionIndex;
  const QuranWordTestScreen({super.key, required this.sectionIndex});

  @override
  State<QuranWordTestScreen> createState() => _QuranWordTestScreenState();
}

class _QuranWordTestScreenState extends State<QuranWordTestScreen>
    with SingleTickerProviderStateMixin {
  List<QuizQuestion>? _questions;
  final Map<int, String> _answers = {};
  int _current = 0;
  late final AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController =
        AnimationController(vsync: this, duration: const Duration(seconds: 40))
          ..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_questions == null) {
      final vm = Provider.of<QuranLearningProvider>(context, listen: false);
      final code = Localizations.localeOf(context).languageCode.toLowerCase();
      var qs = vm.buildSectionQuiz(widget.sectionIndex, languageCode: code);
      final rnd = Random();
      while (qs.length < 5 && qs.isNotEmpty) {
        qs.add(qs[rnd.nextInt(qs.length)]);
      }
      qs.shuffle();
      _questions = qs;
    }
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<QuranLearningProvider>(context);
    final questions = _questions;
    if (questions == null || questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Test')),
        body: const Center(child: Text('Not enough data to generate test')),
      );
    }

    final q = questions[_current];
    final total = questions.length;

    Future<void> submit() async {
      final correct = questions
          .where((e) => _answers[questions.indexOf(e)] == e.correct)
          .length;
      final pass = correct / total >= QuranLearningProvider.passThreshold;
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(pass ? 'Passed!' : 'Try Again'),
          content: Text('Score: $correct / $total'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK')),
          ],
        ),
      );
      if (pass) {
        await vm.markSectionCompleted(widget.sectionIndex);
        if (mounted) Navigator.of(context).pop(true);
      }
    }

    final isBn = Localizations.localeOf(context)
        .languageCode
        .toLowerCase()
        .startsWith('bn');
    String t(String en, String bn) => isBn ? bn : en;
    return Scaffold(
      appBar: const CustomAppBar(),
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Progress text
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                        t('Question ${_current + 1} of $total',
                            'প্রশ্ন ${_current + 1} / $total'),
                        style: Theme.of(context).textTheme.titleSmall),
                  ),
                  // Question card
                  Card(
                    elevation: 0,
                    color: Theme.of(context).cardColor.withOpacity(0.95),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .outlineVariant
                              .withOpacity(0.5)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            t('What is the meaning of:', 'এর অর্থ কী:'),
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            q.word.word,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          () {
                            final code = Localizations.localeOf(context)
                                .languageCode
                                .toLowerCase();
                            final isBn = code.startsWith('bn');
                            final t = isBn
                                ? (q.word.bnTransliteration ?? '')
                                : (q.word.transliteration ?? '');
                            if (t.isEmpty) return const SizedBox.shrink();
                            return Text(t,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                        fontStyle: FontStyle.italic));
                          }(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                      t('Select the correct translation:',
                          'সঠিক অনুবাদ নির্বাচন করুন:'),
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  for (final opt in q.options)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: _OptionTile(
                        text: opt,
                        selected: _answers[_current] == opt,
                        onTap: () {
                          setState(() {
                            _answers[_current] = opt;
                          });
                        },
                      ),
                    ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _current > 0
                              ? () => setState(() => _current -= 1)
                              : null,
                          icon: const Icon(Icons.chevron_left),
                          label: Text(t('Previous', 'পূর্ববর্তী')),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            if (_current < total - 1) {
                              setState(() => _current += 1);
                            } else {
                              submit();
                            }
                          },
                          icon: Icon(_current < total - 1
                              ? Icons.chevron_right
                              : Icons.check_circle_outline),
                          label: Text(_current < total - 1
                              ? t('Next', 'পরবর্তী')
                              : t('Submit', 'জমা দিন')),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const _OptionTile(
      {required this.text, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceVariant,
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: selected ? 2.0 : 1.0,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    selected ? theme.colorScheme.primary : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  width: 2,
                ),
              ),
              child: selected
                  ? Icon(Icons.check,
                      size: 16, color: theme.colorScheme.onPrimary)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
