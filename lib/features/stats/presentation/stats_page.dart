import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlife/features/workouts/domain/models/workout_session.dart';
import 'package:fitlife/features/workouts/domain/providers/workout_session_providers.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(workoutSessionsProvider);

    return Scaffold(
      body: sessionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (sessions) {
          return Column(
            children: [
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final repo = ref.read(workoutSessionRepositoryProvider);

                  final session = WorkoutSession(
                    workoutId: 'w1',
                    name: 'Test Session',
                    category: 'Full Body',
                    durationMinutes: 30,
                    calories: 200,
                    date: DateTime.now(),
                  );

                  await repo.addSession(session);
                  ref.invalidate(workoutSessionsProvider);
                },
                child: const Text('Add test session'),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: sessions.length,
                  itemBuilder: (context, i) {
                    final s = sessions[i];
                    return ListTile(
                      title: Text(s.name),
                      subtitle: Text(
                        '${s.durationMinutes} min - ${s.category}',
                      ),
                      trailing: Text('${s.calories} kcal'),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
