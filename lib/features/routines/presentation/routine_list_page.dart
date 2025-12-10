import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fitlife/core/constants.dart';
import 'package:fitlife/features/routines/domain/models/routine.dart';
import 'package:fitlife/features/routines/domain/providers/routine_providers.dart';

class RoutineListPage extends ConsumerWidget {
  const RoutineListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routinesAsync = ref.watch(routinesFutureProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Routines'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Yeni oluştururken extra göndermiyoruz (null)
          context.push(Routes.routineCreate);
        },
        child: const Icon(Icons.add),
      ),
      body: routinesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
        data: (routines) {
          if (routines.isEmpty) {
            return Center(
              child: Text(
                'No routines yet.\nTap + to create one.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: routines.length,
            separatorBuilder: (c, i) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final routine = routines[index];
              return _RoutineCard(routine: routine);
            },
          );
        },
      ),
    );
  }
}

class _RoutineCard extends ConsumerWidget {
  final Routine routine;

  const _RoutineCard({required this.routine});

  String _formatDays(List<int> days) {
    if (days.length == 7) return 'Every Day';
    if (days.isEmpty) return 'No days set';
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days.map((d) => labels[d - 1]).join(', ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          routine.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              _formatDays(routine.daysOfWeek),
              style: TextStyle(color: colorScheme.primary),
            ),
            const SizedBox(height: 2),
            Text('${routine.workoutIds.length} Workouts assigned'),
          ],
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) async {
            if (value == 'edit') {
              // 🚀 DÜZENLEME: Rutin nesnesini 'extra' olarak gönderiyoruz
              context.push(Routes.routineCreate, extra: routine);
            } else if (value == 'delete') {
              // SİLME
              await ref.read(routineRepositoryProvider).deleteRoutine(routine.id);
              ref.invalidate(routinesFutureProvider);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('Edit')],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [Icon(Icons.delete, size: 20, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))],
              ),
            ),
          ],
        ),
      ),
    );
  }
}