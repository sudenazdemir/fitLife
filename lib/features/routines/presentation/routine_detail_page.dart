import 'package:fitlife/core/constants.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:fitlife/features/routines/domain/models/routine.dart';

class RoutineDetailPage extends StatelessWidget {
  final Routine routine;

  const RoutineDetailPage({
    super.key,
    required this.routine,
  });

  String _dayLabel(int d) {
    const labels = {1: 'Mon', 2: 'Tue', 3: 'Wed', 4: 'Thu', 5: 'Fri', 6: 'Sat', 7: 'Sun'};
    return labels[d] ?? d.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final daysText = routine.daysOfWeek.map(_dayLabel).join(', ');

    return Scaffold(
      appBar: AppBar(title: Text(routine.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Routine overview', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.calendar_month),
                const SizedBox(width: 8),
                Text(
                  daysText.isEmpty ? 'No days selected' : daysText,
                  style: textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.fitness_center),
                const SizedBox(width: 8),
                Text(
                  // DEĞİŞİKLİK BURADA:
                  '${routine.exerciseIds.length} exercises in this routine',
                  style: textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Next steps', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Click start to run this routine with the timer and XP system.',
              style: textTheme.bodyMedium,
            ),
            const Spacer(),
            SafeArea(
              top: false,
              minimum: const EdgeInsets.only(top: 8, bottom: 8),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    // Runner'a rutini gönderiyoruz
                    context.push(Routes.routineRunner, extra: routine);
                  },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Start this routine'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}