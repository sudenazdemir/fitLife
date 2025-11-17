import 'package:fitlife/features/workouts/domain/models/workout.dart';
import 'package:fitlife/core/utils/result.dart';

abstract class WorkoutsRepository {
  Future<Result<List<Workout>>> getAllWorkouts();
}
