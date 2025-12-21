import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'routine.g.dart';

@HiveType(typeId: 1)
class Routine extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<int> daysOfWeek;

  // DİKKAT: Burası artık exercisesIds
  @HiveField(3)
  final List<String> exerciseIds; 

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final int? reminderHour;

  @HiveField(6)
  final int? reminderMinute;

  @HiveField(7)
  final bool isReminderEnabled;

  Routine({
    required this.id,
    required this.name,
    required this.daysOfWeek,
    required this.exerciseIds, // Constructor da değişti
    required this.createdAt,
    this.reminderHour,
    this.reminderMinute,
    this.isReminderEnabled = false,
  });

  TimeOfDay? get reminderTime => (reminderHour != null && reminderMinute != null)
      ? TimeOfDay(hour: reminderHour!, minute: reminderMinute!)
      : null;
}