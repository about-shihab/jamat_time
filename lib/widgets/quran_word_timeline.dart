import 'dart:math';
import 'dart:ui'; // Required for the glassmorphism blur effect
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamat_time/providers/quran_learning_provider.dart';
import 'package:jamat_time/screens/quran_word_learning_screen.dart';

/// A vertical, scrollable timeline of all Quran learning sections.
/// - Uses a "snake" or "calligraphic" path to connect nodes.
/// - Nodes are 8-pointed stars with Arabic numerals.
/// - Includes a subtle Islamic pattern background.
class QuranWordTimeline extends StatelessWidget {
  // --- THIS IS THE FIX ---
  // Make sure your constructor has 'const'
  const QuranWordTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<QuranLearningProvider>(
      builder: (context, vm, _) {
        if (vm.loading && !vm.loaded) {
          return const Center(child: CircularProgressIndicator());
        }
        final sections = vm.sectionCount;
        if (sections == 0) {
          return const Center(child: Text('No words available'));
        }

        return Container(
          // --- Islamic Background ---
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage('assets/images/islamic_pattern.png'),
              fit: BoxFit.cover,
              opacity: 0.05, // Make it very subtle
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- NEW: Vertical Snake Timeline ---
              Expanded(
                child: Container(
                  // --- NEW: Futuristic Glow Effect ---
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.5), // Glow from the top
                      radius: 1.5,
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: ListView.builder(
                    itemCount: sections,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 24.0),
                    itemBuilder: (context, index) {
                      final bool isCompleted = vm.isSectionCompleted(index);
                      final bool isUnlocked = vm.isSectionUnlocked(index);
                      return _VerticalSectionNode(
                        index: index,
                        isFirst: index == 0,
                        isLast: index == sections - 1,
                        isCompleted: isCompleted,
                        isUnlocked: isUnlocked,
                      );
                    },
                  ),
                ),
              ),
              // --- Legend / tips ---
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 24.0),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    const _Legend(color: Colors.green, label: 'Completed'),
                    _Legend(
                        color: Theme.of(context).colorScheme.primary,
                        label: 'Unlocked'),
                    const _Legend(color: Colors.grey, label: 'Locked'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// --- List Item Widget (Holds the Row Layout) ---
const double _verticalItemHeight = 110.0; // Increased height for info

class _VerticalSectionNode extends StatelessWidget {
  final int index;
  final bool isFirst;
  final bool isLast;
  final bool isCompleted;
  final bool isUnlocked;

  const _VerticalSectionNode({
    required this.index,
    required this.isFirst,
    required this.isLast,
    required this.isCompleted,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isNodeActive = isUnlocked || isCompleted;
    // This creates the horizontal "snake" effect
    final double snakeOffset = index % 2 == 0 ? -20.0 : 20.0;
    // This determines if info is on the left or right
    final bool isInfoOnRight = index % 2 == 0;

    return SizedBox(
      height: _verticalItemHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // --- Info Box (Left) ---
          Expanded(
            child: isInfoOnRight
                ? const SizedBox()
                : _SectionInfo(
                    sectionIndex: index,
                    isUnlocked: isUnlocked,
                    isCompleted: isCompleted,
                    alignment: CrossAxisAlignment.end,
                  ),
          ),

          // --- Path & Node (Center) ---
          SizedBox(
            width: 70.0, // Fixed width for the center timeline
            child: Stack(
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
                // --- 2. The Node Content ---
                Center(
                  child: _SectionNodeContent(sectionIndex: index),
                ),
              ],
            ),
          ),

          // --- Info Box (Right) ---
          Expanded(
            child: !isInfoOnRight
                ? const SizedBox()
                : _SectionInfo(
                    sectionIndex: index,
                    isUnlocked: isUnlocked,
                    isCompleted: isCompleted,
                    alignment: CrossAxisAlignment.start,
                  ),
          ),
        ],
      ),
    );
  }
}

// --- The Star Node Widget ---
class _SectionNodeContent extends StatelessWidget {
  final int sectionIndex;
  const _SectionNodeContent({required this.sectionIndex});

  @override
  Widget build(BuildContext context) {
    final double radius = 22.0; // Base radius
    final theme = Theme.of(context);
    final vm = Provider.of<QuranLearningProvider>(context);
    final unlocked = vm.isSectionUnlocked(sectionIndex);
    final completed = vm.isSectionCompleted(sectionIndex);
    final words = vm.sectionWords(sectionIndex);
    final progress = vm.sectionProgress(sectionIndex);

    final Color completedColor = Colors.green;
    final Color unlockedColor = theme.colorScheme.primary;
    final Color lockedColor = Colors.grey;

    final Color nodeColor =
        completed ? completedColor : (unlocked ? unlockedColor : lockedColor);
    final Color textColor = Colors.white;

    // "Pop" the node if it's the current one to work on
    final bool isPopped = unlocked && !completed;
    final double nodeSize = isPopped ? radius * 2.3 : radius * 2;

    return Tooltip(
      message:
          'Section ${sectionIndex + 1} • ${words.length} words\n${(progress * 100).toStringAsFixed(0)}% learned',
      child: InkWell(
        onTap: unlocked
            ? () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: vm,
                      child:
                          QuranWordLearningScreen(sectionIndex: sectionIndex),
                    ),
                  ),
                );
              }
            : null,
        borderRadius: BorderRadius.circular(radius * 1.5),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: nodeSize,
          height: nodeSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // --- UPDATED: Futuristic Shadow ---
            boxShadow: isPopped
                ? [
                    // "Popped" state shadow
                    BoxShadow(
                      color: nodeColor.withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 3,
                    )
                  ]
                : [
                    // Default subtle shadow
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      spreadRadius: 1,
                    )
                  ],
          ),
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background Star Shape
              Icon(
                Icons.brightness_7_rounded, // 8-pointed star
                size: nodeSize,
                color: nodeColor,
              ),
              // Foreground Content
              completed
                  ? Icon(Icons.check, color: textColor, size: radius)
                  : Text(
                      _toArabicNumeral(sectionIndex + 1), // Use the converter
                      style: TextStyle(
                        // fontFamily: 'YourCalligraphyFont',
                        color: textColor,
                        fontWeight:
                            isPopped ? FontWeight.w900 : FontWeight.w500,
                        fontSize: radius * 0.7,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Futuristic Glassmorphism Info Box ---
class _SectionInfo extends StatelessWidget {
  final int sectionIndex;
  final bool isUnlocked;
  final bool isCompleted;
  final CrossAxisAlignment alignment;

  const _SectionInfo({
    required this.sectionIndex,
    required this.isUnlocked,
    required this.isCompleted,
    this.alignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<QuranLearningProvider>(context, listen: false);
    final words = vm.sectionWords(sectionIndex);
    final progress = vm.sectionProgress(sectionIndex);
    final theme = Theme.of(context);

    final Color titleColor = isCompleted
        ? Colors.green
        : (isUnlocked
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface.withOpacity(0.4));

    final Color textColor = isUnlocked
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurface.withOpacity(0.4);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: theme.colorScheme.onSurface.withOpacity(0.2),
              width: 1.0,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: alignment,
            children: [
              Text(
                'Section ${_toArabicNumeral(sectionIndex + 1)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                '${words.length} Words',
                style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
              ),
              if (isUnlocked && !isCompleted) ...[
                const SizedBox(height: 6.0),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}% Learned',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.primary),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

// --- Vertical Snake Path Painter (with Gradient) ---
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
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        colors: [
          activeColor.withOpacity(0.6),
          activeColor,
          activeColor.withOpacity(0.6)
        ],
        stops: const [0.0, 0.5, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

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
        oldDelegate.snakeOffset != oldDelegate.snakeOffset;
  }
}

// --- UNCHANGED: Legend Widget ---
class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

// --- UNCHANGED: Helper for Arabic Numerals ---
String _toArabicNumeral(int number) {
  final Map<String, String> arabicNumerals = {
    '0': '٠',
    '1': '١',
    '2': '٢',
    '3': '٣',
    '4': '٤',
    '5': '٥',
    '6': '٦',
    '7': '٧',
    '8': '٨',
    '9': '٩',
  };
  return number
      .toString()
      .split('')
      .map((digit) => arabicNumerals[digit] ?? digit)
      .join();
}
