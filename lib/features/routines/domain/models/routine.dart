import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'routine.g.dart';

@HiveType(typeId: 1)
class Routine {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<int> daysOfWeek;

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
    required this.exerciseIds,
    required this.createdAt,
    this.reminderHour,
    this.reminderMinute,
    this.isReminderEnabled = false,
  });

  TimeOfDay? get reminderTime => (reminderHour != null && reminderMinute != null)
      ? TimeOfDay(hour: reminderHour!, minute: reminderMinute!)
      : null;

  // --- 🔥 FIREBASE İÇİN EKLENEN KISIMLAR ---

  // 1. Firebase'e gönderirken (Map'e çevir)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'daysOfWeek': daysOfWeek, // List<int>
      'exerciseIds': exerciseIds, // List<String>
      'createdAt': createdAt.toIso8601String(),
      'reminderHour': reminderHour,
      'reminderMinute': reminderMinute,
      'isReminderEnabled': isReminderEnabled,
    };
  }

  // 2. Firebase'den çekerken (Model'e çevir)
  factory Routine.fromMap(Map<String, dynamic> map) {
    return Routine(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? 'Unnamed Routine',
      // Listeleri güvenli bir şekilde çeviriyoruz:
      daysOfWeek: (map['daysOfWeek'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [],
      exerciseIds: (map['exerciseIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
      reminderHour: map['reminderHour'],
      reminderMinute: map['reminderMinute'],
      isReminderEnabled: map['isReminderEnabled'] ?? false,
    );
  }
}