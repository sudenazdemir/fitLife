import 'package:hive_flutter/hive_flutter.dart';

part 'workout_session.g.dart';

@HiveType(typeId: 0)
class WorkoutSession {
  @HiveField(0)
  final String workoutId;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final int durationMinutes;

  @HiveField(4)
  final int calories;

  @HiveField(5)
  final DateTime date;
  
  @HiveField(6)
  final String id;

   @HiveField(7) // 👈 yeni alan (bir önceki index'ten sonrasını kullan)
  final int xpEarned;

  WorkoutSession({
    required this.workoutId,
    required this.name,
    required this.category,
    required this.durationMinutes,
    required this.calories,
    required this.date,
    required this.id,
      this.xpEarned = 0, // 👈 default 0
  });
}
