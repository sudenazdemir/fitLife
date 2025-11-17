import 'package:fitlife/features/workouts/domain/repositories/workouts_repository.dart';
import 'package:fitlife/features/workouts/domain/models/workout.dart';
import 'package:fitlife/core/utils/result.dart';
import 'package:fitlife/core/constants.dart';

class MockWorkoutsRepository implements WorkoutsRepository {
  @override
  Future<Result<List<Workout>>> getAllWorkouts() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300)); // loading hissi

      final mockData = [
        Workout(
          id: "w1",
          name: "Full Body Beginner",
          category: WorkoutCategories.fullBody,
          durationMinutes: 20,
          calories: 150,
          date: DateTime.now(),
        ),
        Workout(
          id: "w2",
          name: "Upper Body Strength",
          category: WorkoutCategories.upperBody,
          durationMinutes: 45,
          calories: 350,
          date: DateTime.now(),
        ),
        Workout(
          id: "w3",
          name: "Cardio Burn",
          category: WorkoutCategories.cardio,
          durationMinutes: 30,
          calories: 220,
          date: DateTime.now(),
        ),
      ];

      return Result.success(mockData);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}
