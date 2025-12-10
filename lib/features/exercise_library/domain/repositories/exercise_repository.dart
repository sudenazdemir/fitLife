import 'package:fitlife/features/exercise_library/domain/models/exercise.dart';

abstract class ExerciseRepository {
  Future<List<Exercise>> getExercises();
}

class MockExerciseRepository implements ExerciseRepository {
  @override
  Future<List<Exercise>> getExercises() async {
    // const kaldırıldı çünkü Exercise artık HiveObject extends ediyor
    return [
       Exercise(
        id: 'ex1',
        name: 'Push Up',
        muscleGroup: 'Chest',
        equipment: 'Bodyweight',
        difficulty: 'Beginner',
        description:
            'A basic bodyweight exercise targeting chest, shoulders and triceps.',
      ),
      Exercise(
        id: 'ex2',
        name: 'Squat',
        muscleGroup: 'Legs',
        equipment: 'Bodyweight',
        difficulty: 'Beginner',
        description:
            'Lower body compound movement focusing on quads and glutes.',
      ),
      Exercise(
        id: 'ex3',
        name: 'Deadlift',
        muscleGroup: 'Back',
        equipment: 'Barbell',
        difficulty: 'Intermediate',
        description:
            'Heavy compound lift working posterior chain and grip strength.',
      ),
      Exercise(
        id: 'ex4',
        name: 'Plank',
        muscleGroup: 'Core',
        equipment: 'Bodyweight',
        difficulty: 'Beginner',
        description:
            'Isometric hold for core stability and anti-extension strength.',
      ),
    ];
  }
}