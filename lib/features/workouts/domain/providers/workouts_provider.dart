import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlife/features/workouts/domain/repositories/workouts_repository.dart';
import 'package:fitlife/features/workouts/data/mock_workouts_repository.dart';
import 'package:fitlife/features/workouts/domain/models/workout.dart';
import 'package:fitlife/core/utils/result.dart';

final workoutsRepositoryProvider = Provider<WorkoutsRepository>((ref) {
  return MockWorkoutsRepository();
});

final workoutsProvider = FutureProvider<Result<List<Workout>>>((ref) {
  final repo = ref.watch(workoutsRepositoryProvider);
  return repo.getAllWorkouts();
});
