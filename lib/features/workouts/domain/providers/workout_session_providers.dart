import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlife/features/workouts/domain/models/workout_session.dart';
import 'package:fitlife/features/workouts/domain/repositories/workout_session_repository.dart';

final workoutSessionRepositoryProvider =
    Provider<WorkoutSessionRepository>((ref) {
  return WorkoutSessionRepository(); // ← Artık parametre yok
});

final workoutSessionsProvider =
    FutureProvider<List<WorkoutSession>>((ref) async {
  final repo = ref.watch(workoutSessionRepositoryProvider);
  return repo.getAllSessions();
});
