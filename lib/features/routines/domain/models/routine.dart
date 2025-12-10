import 'package:hive/hive.dart';

part 'routine.g.dart';

@HiveType(typeId: 1) // ⚠️ typeId'yi projedeki diğer modellerle çakışmayacak şekilde ayarla
class Routine {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  /// 0 = Monday, 6 = Sunday gibi düşünebiliriz (veya sen nasıl karar verdiysen)
  @HiveField(2)
  final List<int> daysOfWeek;

  /// Bu rutinin içinde hangi workout'lar var (Workout.id listesi)
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
