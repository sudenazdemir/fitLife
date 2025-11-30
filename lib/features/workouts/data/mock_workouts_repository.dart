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
          title: "Full Body Beginner Workout",
          difficulty: "Beginner",
          description: "A full body workout for beginners to build strength and endurance.",
        ),
        Workout(
          id: "w2",
          name: "Upper Body Strength",
          category: WorkoutCategories.upperBody,
          durationMinutes: 45,
          calories: 350,
          date: DateTime.now(),
          title: "Upper Body Strength Training",
          difficulty: "Intermediate",
          description: "An intermediate workout focused on building upper body strength.",
        ),
        Workout(
          id: "w3",
          name: "Cardio Burn",
          category: WorkoutCategories.cardio,
          durationMinutes: 30,
          calories: 220,
          date: DateTime.now(),
          title: "Cardio Burn Workout",
          difficulty: "Intermediate",
          description: "An intermediate cardio workout to improve endurance and burn calories.",
        ),
      ];

      return Result.success(mockData);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}
