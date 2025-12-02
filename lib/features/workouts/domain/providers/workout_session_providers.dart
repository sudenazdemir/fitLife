// lib/features/workouts/domain/providers/workout_session_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlife/features/workouts/domain/models/workout_session.dart';
import 'package:fitlife/features/workouts/domain/repositories/workout_session_repository.dart';

/// Repository provider
final workoutSessionRepositoryProvider =
    Provider<WorkoutSessionRepository>((ref) {
  return WorkoutSessionRepository();
});

/// Tüm session’ları çeken provider
final workoutSessionsProvider =
    FutureProvider<List<WorkoutSession>>((ref) async {
  final repo = ref.watch(workoutSessionRepositoryProvider);
  return repo.getAllSessions();
});
