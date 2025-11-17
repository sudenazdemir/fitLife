import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fitlife/features/workouts/domain/models/workout_session.dart';
import 'package:fitlife/features/workouts/domain/repositories/workout_session_repository.dart';

final workoutSessionBoxProvider = Provider<Box<WorkoutSession>>((ref) {
  return Hive.box<WorkoutSession>('workout_sessions');
});

final workoutSessionRepositoryProvider =
    Provider<WorkoutSessionRepository>((ref) {
  final box = ref.watch(workoutSessionBoxProvider);
  return WorkoutSessionRepository(box);
});

final workoutSessionsProvider =
    FutureProvider<List<WorkoutSession>>((ref) async {
  final repo = ref.watch(workoutSessionRepositoryProvider);
  return repo.getAllSessions();
});
