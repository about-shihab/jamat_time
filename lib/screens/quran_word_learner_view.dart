import 'package:flutter/material.dart';
import 'package:jamat_time/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:jamat_time/providers/quran_learning_provider.dart';
import 'package:jamat_time/widgets/aurora_background_painter.dart';
import 'package:jamat_time/screens/quran_word_learning_screen.dart';

class QuranWordLearnerView extends StatefulWidget {
  const QuranWordLearnerView({super.key});

  @override
  State<QuranWordLearnerView> createState() => _QuranWordLearnerViewState();
}

class _QuranWordLearnerViewState extends State<QuranWordLearnerView>
    with SingleTickerProviderStateMixin {
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
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ChangeNotifierProvider(
      create: (_) => QuranLearningProvider()..load(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Text(l10n.quranWordLearner)),
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
            Consumer<QuranLearningProvider>(
              builder: (context, vm, _) {
                if (vm.loading && !vm.loaded) {
                  return const Center(child: CircularProgressIndicator());
                }
                final sections = vm.sectionCount;
                if (sections == 0) {
                  return const Center(child: Text('No words available'));
                }
                final isBn = Localizations.localeOf(context)
                    .languageCode
                    .toLowerCase()
                    .startsWith('bn');
                String t(String en, String bn) => isBn ? bn : en;
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                  itemCount: sections + 1,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4.0, vertical: 8.0),
                        child: Text(
                          t('Frequent Quran Words',
                              'কুরআনের বহুল ব্যবহৃত শব্দসমূহ'),
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                        ),
                      );
                    }
                    final i = index - 1;
                    final unlocked = vm.isSectionUnlocked(i);
                    final completed = vm.isSectionCompleted(i);
                    final words = vm.sectionWords(i);
                    final progress = vm.sectionProgress(i);
                    return Card(
                      color: Theme.of(context).cardColor.withOpacity(0.8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: completed
                              ? Colors.green
                              : (unlocked
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey),
                          child: Text('${i + 1}',
                              style: const TextStyle(color: Colors.white)),
                        ),
                        title: Text(
                          isBn
                              ? 'সেকশন ${i + 1} • ${words.length} টি শব্দ'
                              : 'Section ${i + 1} • ${words.length} words',
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            LinearProgressIndicator(
                                value: completed ? 1 : progress),
                            const SizedBox(height: 6),
                            Text(completed
                                ? t('Completed', 'সম্পন্ন')
                                : unlocked
                                    ? t('Tap to learn and take test',
                                        'শেখার জন্য ট্যাপ করুন এবং পরীক্ষা দিন')
                                    : t('Locked — complete previous section',
                                        'লকড — আগের সেকশন সম্পন্ন করুন')),
                          ],
                        ),
                        trailing: Icon(
                          completed
                              ? Icons.check_circle
                              : unlocked
                                  ? Icons.lock_open
                                  : Icons.lock,
                          color: completed
                              ? Colors.green
                              : unlocked
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey,
                        ),
                        onTap: unlocked
                            ? () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ChangeNotifierProvider.value(
                                      value: Provider.of<QuranLearningProvider>(
                                          context,
                                          listen: false),
                                      child: QuranWordLearningScreen(
                                          sectionIndex: i),
                                    ),
                                  ),
                                );
                              }
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
