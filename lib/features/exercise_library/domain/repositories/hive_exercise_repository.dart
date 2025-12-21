import 'package:hive/hive.dart';
// Abstract sınıfı (Interface) buradan import ediyoruz:
import 'package:fitlife/features/exercise_library/domain/repositories/exercise_repository.dart';
import 'package:fitlife/features/exercise_library/domain/models/exercise.dart';

// DİKKAT: Burada 'abstract class ExerciseRepository' TANIMLAMIYORUZ.
// Sadece HiveExerciseRepository sınıfını tanımlıyoruz.

class HiveExerciseRepository implements ExerciseRepository {
  @override
  Future<List<Exercise>> getExercises() async {
    final box = Hive.box<Exercise>('exercises');
    return box.values.toList();
  }
}