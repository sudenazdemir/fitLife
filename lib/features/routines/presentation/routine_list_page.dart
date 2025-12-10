import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlife/features/routines/domain/providers/routine_providers.dart';
import 'package:fitlife/features/routines/domain/models/routine.dart';
import 'package:go_router/go_router.dart';
import 'package:fitlife/core/constants.dart';

class RoutineListPage extends ConsumerWidget {
  const RoutineListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routinesAsync = ref.watch(routinesFutureProvider);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Routines'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push(Routes.routineCreate),
          ),
        ],
      ),
      body: routinesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (routines) {
          if (routines.isEmpty) {
            return Center(
              child: Text(
                'No routines yet.\nCreate one to get started!',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge,
              ),
            );
          }

          return ListView.separated(
            itemCount: routines.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final Routine r = routines[index]; // 👈 tipi açık yazdık
              final days = r.daysOfWeek.map((d) => _dayLabel(d)).join(', ');

              return ListTile(
                title: Text(r.name),
                subtitle: Text('$days • ${r.workoutIds.length} workouts'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.push(Routes.routineDetail, extra: r);
                },
              );
            },
          );
        },
      ),
    );
  }

  String _dayLabel(int d) {
    const labels = {
      1: 'Mon',
      2: 'Tue',
      3: 'Wed',
      4: 'Thu',
      5: 'Fri',
      6: 'Sat',
      7: 'Sun'
    };
    return labels[d] ?? d.toString();
  }
}
