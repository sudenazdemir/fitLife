import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlife/features/workouts/domain/repositories/workouts_repository.dart';
import 'package:fitlife/features/workouts/data/mock_workouts_repository.dart';
import 'package:fitlife/features/workouts/domain/models/workout.dart';
import 'package:fitlife/core/utils/result.dart';
import 'package:fitlife/core/constants.dart';

final workoutsRepositoryProvider = Provider<WorkoutsRepository>((ref) {
  return MockWorkoutsRepository();
});

final workoutsProvider = FutureProvider<Result<List<Workout>>>((ref) {
  final repo = ref.watch(workoutsRepositoryProvider);
  return repo.getAllWorkouts();
});
/// Kullanıcının seçtiği kategori
/// Seçili kategori (null veya 'all' → hepsi)
final selectedWorkoutCategoryProvider = StateProvider<String?>((ref) => null);

/// Kategoriye göre filtrelenmiş workout listesi
/// ❗ Burada artık Result üstünde `where` çağırmıyoruz.
final filteredWorkoutsProvider =
    FutureProvider<List<Workout>>((ref) async {
  // workoutsProvider içindeki Result<List<Workout>> objesini al
  final result = await ref.watch(workoutsProvider.future);

  // Seçili kategori
  final selected = ref.watch(selectedWorkoutCategoryProvider);

  // Result içinden gerçek listeyi çek
  // NOT: Eğer senin Result içinde alanın adı `value` / `data` değilse
  // burayı ona göre değiştirmen yeterli.
  final List<Workout> all = result.data ?? <Workout>[];

  if (selected == null || selected == WorkoutCategories.all) {
    return all;
  }

  return all.where((w) => w.category == selected).toList();
});