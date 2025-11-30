import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlife/features/workouts/domain/providers/workouts_provider.dart';
import 'package:fitlife/core/constants.dart';
import 'package:go_router/go_router.dart';

class WorkoutsPage extends ConsumerWidget {
  const WorkoutsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(workoutsProvider);

    return Scaffold(
      body: workoutsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (result) {
          if (result.isFailure) {
            return Center(child: Text("Error: ${result.error}"));
          }

          final workouts = result.data!;
          return ListView.builder(
            itemCount: workouts.length,
            itemBuilder: (context, i) {
              final workout = workouts[i];
              return ListTile(
                title: Text(workout.title),
                subtitle: Text(
                    '${workout.durationMinutes} min • ${workout.category}'),
                trailing: Text('${workout.calories} kcal'),
                onTap: () {
                  context.goNamed(
                    RouteNames.workoutDetail,
                    pathParameters: {'id': workout.id}, // id yoksa title kullan
                    extra: workout,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
