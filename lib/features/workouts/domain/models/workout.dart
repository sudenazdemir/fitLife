import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workout.g.dart';

@JsonSerializable()
@HiveType(typeId: 5) // Exercise sınıfı 1 idi, bu yüzden buna 2 verdik.
class Workout extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final int durationMinutes;

  @HiveField(4)
  final int calories;

  @HiveField(5)
  final DateTime? date;

  @HiveField(6)
  final String title;

  @HiveField(7)
  final String? difficulty;

  @HiveField(8)
  final String? description;

  // HiveObject extend edildiği için const kaldırıldı
  Workout({
    required this.id,
    required this.name,
    required this.category,
    required this.durationMinutes,
    this.calories = 0,
    this.date,
    required this.title,
    this.difficulty,
    this.description,
  });

  factory Workout.fromJson(Map<String, dynamic> json) =>
      _$WorkoutFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutToJson(this);
}