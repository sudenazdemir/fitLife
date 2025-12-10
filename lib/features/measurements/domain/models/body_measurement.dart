import 'package:hive_flutter/hive_flutter.dart';

part 'body_measurement.g.dart';

@HiveType(typeId: 3) // WorkoutSession 0 idi, bu 1 olsun
class BodyMeasurement {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final double weight;

  @HiveField(3)
  final double? bodyFat; // Opsiyonel

  @HiveField(4)
  final double? waist; // Opsiyonel

  @HiveField(5)
  final double? hip; // Opsiyonel

  BodyMeasurement({
    required this.id,
    required this.date,
    required this.weight,
    this.bodyFat,
    this.waist,
    this.hip,
  });
}