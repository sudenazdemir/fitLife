import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exercise.g.dart';

@JsonSerializable()
@HiveType(typeId: 4) // typeId projedeki diğer Hive sınıflarından farklı olmalıdır.
class Exercise extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String muscleGroup; // örn: Chest, Back, Legs

  @HiveField(3)
  final String equipment;   // örn: Bodyweight, Dumbbell, Barbell

  @HiveField(4)
  final String difficulty;  // Beginner / Intermediate / Advanced

  @HiveField(5)
  final String description;

  Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.equipment,
    required this.difficulty,
    required this.description,
  });

  // JSON işlemleri için factory ve metodlar
  factory Exercise.fromJson(Map<String, dynamic> json) =>
      _$ExerciseFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseToJson(this);
}