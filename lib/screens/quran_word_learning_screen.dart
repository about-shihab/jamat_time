import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamat_time/models/quran_word.dart';
import 'package:jamat_time/providers/quran_learning_provider.dart';
import 'package:jamat_time/screens/quran_word_test_screen.dart';
import 'package:jamat_time/widgets/aurora_background_painter.dart';
import 'package:jamat_time/widgets/custom_app_bar.dart';
import 'package:jamat_time/l10n/app_localizations.dart';

class QuranWordLearningScreen extends StatefulWidget {
  final int sectionIndex;
  const QuranWordLearningScreen({super.key, required this.sectionIndex});

  @override
  State<QuranWordLearningScreen> createState() =>
      _QuranWordLearningScreenState();
}

class _QuranWordLearningScreenState extends State<QuranWordLearningScreen>
    with SingleTickerProviderStateMixin {
  final PageController _controller = PageController();
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
  void dispose() {
    _controller.dispose();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<QuranLearningProvider>(context);
    final words = vm.sectionWords(widget.sectionIndex);
    if (words.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Section ${widget.sectionIndex + 1}')),
        body: const Center(child: Text('No words found')),
      );
    }

    void markViewed(int index) {
      final w = words[index];
      vm.markWordViewed(widget.sectionIndex, w.id);
    }

    // Mark first as viewed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        markViewed(_current);
      }
    });

    final isBn = Localizations.localeOf(context)
        .languageCode
        .toLowerCase()
        .startsWith('bn');
    String t(String en, String bn) => isBn ? bn : en;

    // Helper to build the dynamic "Next" or "Start Test" button
    Widget _buildNextOrTestButton() {
      bool isLastPage = _current == words.length - 1;

      if (isLastPage) {
        // On the last page, show "Start Test"
        return FilledButton.icon(
          icon: const Icon(Icons.quiz_rounded),
          label: Text(t('Start Test', 'পরীক্ষা শুরু')),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: vm.canStartTest(widget.sectionIndex)
              ? () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider.value(
                        value: vm,
                        child: QuranWordTestScreen(
                            sectionIndex: widget.sectionIndex),
                      ),
                    ),
                  );
                  if (result == true && mounted) {
                    Navigator.of(context).pop();
                  }
                }
              : null,
        );
      } else {
        // Otherwise, show "Next"
        return FilledButton.icon(
          icon: const Icon(Icons.chevron_right),
          label: Text(t('Next', 'পরবর্তী')),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: () => _controller.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          ),
        );
      }
    }

    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: const CustomAppBar(),
      // Background: Aurora painter like HomeView; and no timeline UI
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
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: words.length,
                    onPageChanged: (i) {
                      setState(() => _current = i);
                      markViewed(i);
                    },
                    itemBuilder: (context, index) =>
                        _WordCard(word: words[index]),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _current > 0
                              ? () => _controller.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOutCubic,
                                  )
                              : null,
                          icon: const Icon(Icons.chevron_left),
                          label: Text(t('Previous', 'পূর্ববর্তী')),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: _buildNextOrTestButton()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- NEW WIDGETS FOR VERTICAL TIMELINE ---
// (All old timeline widgets have been removed)

const double _verticalItemHeight = 90.0;

class _VerticalTimelineIndicator extends StatefulWidget {
  final int totalSteps;
  final int currentStep;

  const _VerticalTimelineIndicator({
    required this.totalSteps,
    required this.currentStep,
  });

  @override
  State<_VerticalTimelineIndicator> createState() =>
      _VerticalTimelineIndicatorState();
}

class _VerticalTimelineIndicatorState
    extends State<_VerticalTimelineIndicator> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollToCurrent();
  }

  @override
  void didUpdateWidget(covariant _VerticalTimelineIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentStep != oldWidget.currentStep) {
      _scrollToCurrent();
    }
  }

  void _scrollToCurrent() {
    Timer(const Duration(milliseconds: 100), () {
      if (!mounted || !_scrollController.hasClients) return;

      final listHeight = _scrollController.position.viewportDimension;
      final targetScrollOffset = (widget.currentStep * _verticalItemHeight) -
          (listHeight / 2) +
          (_verticalItemHeight / 2);

      _scrollController.animateTo(
        targetScrollOffset.clamp(
            0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70.0, // Fixed width for the timeline
      child: ListView.builder(
        controller: _scrollController,
        itemCount: widget.totalSteps,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        itemBuilder: (context, index) {
          return SizedBox(
            height: _verticalItemHeight,
            child: _VerticalTimelineNode(
              index: index,
              isFirst: index == 0,
              isLast: index == widget.totalSteps - 1,
              isCompleted: index < widget.currentStep,
              isCurrent: index == widget.currentStep,
            ),
          );
        },
      ),
    );
  }
}

class _VerticalTimelineNode extends StatelessWidget {
  final int index;
  final bool isFirst;
  final bool isLast;
  final bool isCompleted;
  final bool isCurrent;

  const _VerticalTimelineNode({
    required this.index,
    required this.isFirst,
    required this.isLast,
    required this.isCompleted,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isNodeActive = isCompleted || isCurrent;
    // This creates the horizontal "snake" effect
    final double snakeOffset = index % 2 == 0 ? -20.0 : 20.0;

    return Stack(
      alignment: Alignment.center,
      children: [
        // --- 1. The Calligraphic Path ---
        CustomPaint(
          size: Size.infinite,
          painter: _TimelinePathPainter(
            isFirst: isFirst,
            isLast: isLast,
            isActive: isNodeActive,
            isLineAfterActive: isCompleted,
            snakeOffset: snakeOffset,
            activeColor: theme.colorScheme.primary,
            inactiveColor: theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),

        // --- 2. The Node ---
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.all(isCurrent ? 12.0 : 8.0),
          decoration: BoxDecoration(
            color: isNodeActive
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceVariant,
            shape: BoxShape.circle,
            border: Border.all(
              color: isNodeActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withOpacity(0.3),
              width: 2.0,
            ),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ]
                : [],
          ),
          child: Text(
            // You could replace this with Arabic numerals
            '${index + 1}',
            style: TextStyle(
              color: isNodeActive
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}

class _TimelinePathPainter extends CustomPainter {
  final bool isFirst;
  final bool isLast;
  final bool isActive;
  final bool isLineAfterActive;
  final double snakeOffset;
  final Color activeColor;
  final Color inactiveColor;

  _TimelinePathPainter({
    required this.isFirst,
    required this.isLast,
    required this.isActive,
    required this.isLineAfterActive,
    required this.snakeOffset,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final Paint inactivePaint = Paint()
      ..color = inactiveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;

    // --- Draw line BEFORE the node ---
    if (!isFirst) {
      final Path pathBefore = Path();
      pathBefore.moveTo(centerX, 0); // Start top-center
      pathBefore.quadraticBezierTo(
        centerX + snakeOffset, // Horizontal curve
        centerY / 2, // Vertical midpoint
        centerX, // End node-center-x
        centerY, // End node-center-y
      );
      canvas.drawPath(pathBefore, isActive ? activePaint : inactivePaint);
    }

    // --- Draw line AFTER the node ---
    if (!isLast) {
      final Path pathAfter = Path();
      pathAfter.moveTo(centerX, centerY); // Start node-center
      pathAfter.quadraticBezierTo(
        centerX - snakeOffset, // Horizontal curve (opposite)
        centerY + (size.height - centerY) / 2, // Vertical midpoint
        centerX, // End bottom-center-x
        size.height, // End bottom-center-y
      );
      canvas.drawPath(
          pathAfter, isLineAfterActive ? activePaint : inactivePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TimelinePathPainter oldDelegate) {
    return oldDelegate.isActive != isActive ||
        oldDelegate.isLineAfterActive != isLineAfterActive ||
        oldDelegate.snakeOffset != snakeOffset;
  }
}

// --- _WordCard Widget (Unchanged) ---
// (This is the same as the previous refactor, no changes needed)
class _WordCard extends StatelessWidget {
  final QuranWord word;
  const _WordCard({required this.word});

  List<String> _segments(String s) {
    final exp = RegExp(r"`([^`]*)`");
    final matches = exp.allMatches(s);
    if (matches.isEmpty) return s.isEmpty ? const [] : [s];
    return matches
        .map((m) => m.group(1) ?? '')
        .where((e) => e.trim().isNotEmpty)
        .toList();
  }

// Moved helper classes outside of _WordCard

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final code = Localizations.localeOf(context).languageCode.toLowerCase();
    final isBn = code.startsWith('bn');
    final transliteration =
        isBn ? (word.bnTransliteration ?? '') : (word.transliteration ?? '');
    final translation =
        isBn ? (word.bnTranslation ?? '') : (word.enTranslation ?? '');
    final exampleAr = word.exampleAr ?? '';
    final exampleLocal =
        isBn ? (word.exampleArBn ?? '') : (word.exampleArEn ?? '');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      child: Card(
        elevation: 0,
        color: theme.cardColor.withOpacity(0.92),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
              color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  if (word.occurrence != null)
                    Chip(
                      label: Text(isBn
                          ? '${word.occurrence} বার এসেছে'
                          : 'Occurs ${word.occurrence} times'),
                      labelStyle: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                    ),
                  const Spacer(),
                ],
              ),
              const Spacer(flex: 2),
              Text(
                word.word,
                textAlign: TextAlign.center,
                style: theme.textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                  height: 1.15,
                ),
              ),
              const Spacer(flex: 1),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(isBn ? 'অনুবাদ' : 'Translation',
                            style: theme.textTheme.labelLarge
                                ?.copyWith(color: theme.hintColor)),
                        const SizedBox(height: 6),
                        Text(
                          translation.isEmpty ? '-' : translation,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  Container(
                      width: 1,
                      height: 48,
                      color: theme.dividerColor.withOpacity(0.5)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(isBn ? 'উচ্চারণ' : 'Transliteration',
                            style: theme.textTheme.labelLarge
                                ?.copyWith(color: theme.hintColor)),
                        const SizedBox(height: 6),
                        Text(
                          transliteration.isEmpty ? '-' : transliteration,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.hintColor,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(flex: 2),
              if (exampleAr.isNotEmpty || exampleLocal.isNotEmpty) ...[
                const Divider(),
                const SizedBox(height: 12),
                // Arabic words on top, meanings at bottom (aligned boxes)
                _ExampleAlignedRow(exampleLocal: exampleLocal),
                const Spacer(flex: 1),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ExampleAlignedRow extends StatelessWidget {
  final String exampleLocal; // backtick-delimited tokens: `AR (tr)`
  const _ExampleAlignedRow({required this.exampleLocal});

  List<_Pair> _parsePairs(String s) {
    final List<_Pair> res = [];
    final tokenExp = RegExp(r"`([^`]*)`");
    for (final m in tokenExp.allMatches(s)) {
      final token = (m.group(1) ?? '').trim();
      if (token.isEmpty) continue;
      final open = token.lastIndexOf('(');
      final close = token.lastIndexOf(')');
      if (open != -1 && close != -1 && close > open) {
        final ar = token.substring(0, open).trim();
        final tr = token.substring(open + 1, close).trim();
        if (ar.isNotEmpty || tr.isNotEmpty) res.add(_Pair(ar: ar, tr: tr));
      } else {
        res.add(_Pair(ar: token, tr: ''));
      }
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pairs = _parsePairs(exampleLocal);
    if (pairs.isEmpty) return const SizedBox.shrink();

    final palette = <Color>[
      theme.colorScheme.primary,
      Colors.indigo,
      Colors.teal,
      Colors.amber,
      Colors.deepPurple,
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Wrap(
        spacing: 0,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          for (var i = 0; i < pairs.length; i++)
            _ExampleCell(
              arabic: pairs[i].ar,
              meaning: pairs[i].tr,
              color: palette[i % palette.length],
            )
        ],
      ),
    );
  }
}

class _ExampleCell extends StatelessWidget {
  final String arabic;
  final String meaning;
  final Color color;
  const _ExampleCell(
      {required this.arabic, required this.meaning, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(right: 0),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: theme.dividerColor.withOpacity(0.6)),
          bottom: BorderSide(color: theme.dividerColor.withOpacity(0.6)),
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 80),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                arabic,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 6),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  meaning,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pair {
  final String ar;
  final String tr;
  _Pair({required this.ar, required this.tr});
}
