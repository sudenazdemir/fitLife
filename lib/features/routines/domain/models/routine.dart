import 'package:hive/hive.dart';

part 'routine.g.dart';

@HiveType(typeId: 3) // ⚠️ WorkoutSession'dan FARKLI bir id olsun (0/1/2 değilse 3 iyi)
class Routine {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  /// 1 = Monday ... 7 = Sunday
  @HiveField(2)
  final List<int> daysOfWeek;

  /// Workout IDs in order
  @HiveField(3)
  final List<String> workoutIds;

  @HiveField(4)
  final DateTime createdAt;

  const Routine({
    required this.id,
    required this.name,
    required this.daysOfWeek,
    required this.workoutIds,
    required this.createdAt,
  });
}
