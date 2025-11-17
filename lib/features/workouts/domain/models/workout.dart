import 'package:json_annotation/json_annotation.dart';

part 'workout.g.dart';

@JsonSerializable()
class Workout {
  final String id;
  final String name;
  final String category;
  final int durationMinutes;
  final int calories;
  final DateTime? date;

  const Workout({
    required this.id,
    required this.name,
    required this.category,
    required this.durationMinutes,
    this.calories = 0,
    this.date,
  });

  factory Workout.fromJson(Map<String, dynamic> json) =>
      _$WorkoutFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutToJson(this);
}
