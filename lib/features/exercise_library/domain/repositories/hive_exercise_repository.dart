import 'package:hive/hive.dart';
import 'package:fitlife/features/exercise_library/domain/repositories/exercise_repository.dart';
import 'package:fitlife/features/exercise_library/domain/models/exercise.dart';

class HiveExerciseRepository implements ExerciseRepository {
  @override
  Future<List<Exercise>> getExercises() async {
    // 'exercises' kutusu main.dart içinde açıldığı için burada direkt erişebiliriz.
    if (!Hive.isBoxOpen('exercises')) {
        await Hive.openBox<Exercise>('exercises');
    }
    final box = Hive.box<Exercise>('exercises');
    return box.values.toList();
  }
}