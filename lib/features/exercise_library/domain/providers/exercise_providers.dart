import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlife/features/exercise_library/domain/models/exercise.dart';
import 'package:fitlife/features/exercise_library/domain/repositories/exercise_repository.dart';

/// Repository provider
final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return MockExerciseRepository();
});

/// Tüm egzersiz listesi
final exercisesProvider = FutureProvider<List<Exercise>>((ref) async {
  final repo = ref.watch(exerciseRepositoryProvider);
  return repo.getExercises();
});

/// Arama filtresi
final exerciseSearchQueryProvider = StateProvider<String>((ref) => '');

/// Muscle group filtresi (null => hepsi)
final exerciseMuscleFilterProvider = StateProvider<String?>((ref) => null);

/// Filtrelenmiş egzersiz listesi
final filteredExercisesProvider =
    FutureProvider<List<Exercise>>((ref) async {
  final all = await ref.watch(exercisesProvider.future);
  final query = ref.watch(exerciseSearchQueryProvider).trim().toLowerCase();
  final muscle = ref.watch(exerciseMuscleFilterProvider);

  return all.where((ex) {
    final matchesQuery = query.isEmpty ||
        ex.name.toLowerCase().contains(query) ||
        ex.muscleGroup.toLowerCase().contains(query);

    final matchesMuscle =
        muscle == null || muscle.isEmpty || ex.muscleGroup == muscle;

    return matchesQuery && matchesMuscle;
  }).toList();
});
