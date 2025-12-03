import 'package:fitlife/features/exercise_library/domain/models/exercise.dart';

abstract class ExerciseRepository {
  Future<List<Exercise>> getExercises();
}

class MockExerciseRepository implements ExerciseRepository {
  @override
  Future<List<Exercise>> getExercises() async {
    // Basit mock data
    return [
      const Exercise(
        id: 'ex1',
        name: 'Push Up',
        muscleGroup: 'Chest',
        equipment: 'Bodyweight',
        difficulty: 'Beginner',
        description:
            'A basic bodyweight exercise targeting chest, shoulders and triceps.',
      ),
     const Exercise(
        id: 'ex2',
        name: 'Squat',
        muscleGroup: 'Legs',
        equipment: 'Bodyweight',
        difficulty: 'Beginner',
        description:
            'Lower body compound movement focusing on quads and glutes.',
      ),
      const Exercise(
        id: 'ex3',
        name: 'Deadlift',
        muscleGroup: 'Back',
        equipment: 'Barbell',
        difficulty: 'Intermediate',
        description:
            'Heavy compound lift working posterior chain and grip strength.',
      ),
      const Exercise(
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
