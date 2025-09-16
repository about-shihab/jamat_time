import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamat_time/providers/quran_learning_provider.dart';
import 'package:jamat_time/screens/quran_word_learning_screen.dart';

class QuranWordTimelineScreen extends StatelessWidget {
  const QuranWordTimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => QuranLearningProvider()..load(),
      child: const _TimelineBody(),
    );
  }
}

class _TimelineBody extends StatelessWidget {
  const _TimelineBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Frequent Quran Words')),
      body: Consumer<QuranLearningProvider>(
        builder: (context, vm, _) {
          if (vm.loading && !vm.loaded) {
            return const Center(child: CircularProgressIndicator());
          }
          final sections = vm.sectionCount;
          if (sections == 0) {
            return const Center(child: Text('No words available'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: sections,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final unlocked = vm.isSectionUnlocked(index);
              final completed = vm.isSectionCompleted(index);
              final words = vm.sectionWords(index);
              final progress = vm.sectionProgress(index);
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        completed ? Colors.green : (unlocked ? Colors.blue : Colors.grey),
                    child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text('Section ${index + 1} • ${words.length} words'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      LinearProgressIndicator(value: completed ? 1 : progress),
                      const SizedBox(height: 6),
                      Text(completed
                          ? 'Completed'
                          : unlocked
                              ? 'Tap to learn and take test'
                              : 'Locked — complete previous section'),
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
                              builder: (_) => ChangeNotifierProvider.value(
                                value: Provider.of<QuranLearningProvider>(context, listen: false),
                                child: QuranWordLearningScreen(sectionIndex: index),
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
    );
  }
}

