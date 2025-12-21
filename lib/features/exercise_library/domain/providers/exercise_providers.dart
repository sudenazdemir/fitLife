import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlife/features/exercise_library/domain/models/exercise.dart';

// 1. Interface (Soyut Sınıf) Importu:
import 'package:fitlife/features/exercise_library/domain/repositories/exercise_repository.dart';

// 2. Implementation (Gerçek Sınıf) Importu:
import 'package:fitlife/features/exercise_library/domain/repositories/hive_exercise_repository.dart';

/// Repository provider
final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  // Mock değil, gerçek Hive repo dönüyor
  return HiveExerciseRepository();
});

/// Tüm Egzersiz Listesi
final exerciseListProvider = FutureProvider<List<Exercise>>((ref) async {
  final repository = ref.watch(exerciseRepositoryProvider);
  return repository.getExercises();
});

/// Arama filtresi
final exerciseSearchQueryProvider = StateProvider<String>((ref) => '');

/// Muscle group filtresi
final exerciseMuscleFilterProvider = StateProvider<String?>((ref) => null);

/// Filtrelenmiş egzersiz listesi
final filteredExercisesProvider = FutureProvider<List<Exercise>>((ref) async {
  // DÜZELTME: Aşağıdaki satırda 'exercisesProvider' yazıyordu,
  // doğrusu yukarıda tanımladığın 'exerciseListProvider'.
  final all = await ref.watch(exerciseListProvider.future);
  
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