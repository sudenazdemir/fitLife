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

  @HiveField(7)
  final int xpEarned;

  WorkoutSession({
    required this.workoutId,
    required this.name,
    required this.category,
    required this.durationMinutes,
    required this.calories,
    required this.date,
    required this.id,
    this.xpEarned = 0,
  });

  // --- 🔥 FIREBASE İÇİN EKLENEN KISIMLAR ---

  // 1. Modeli JSON'a (Map) çevirir (Firebase'e gönderirken)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workoutId': workoutId,
      'name': name,
      'category': category,
      'durationMinutes': durationMinutes,
      'calories': calories,
      'date': date.toIso8601String(), // Tarihi String olarak saklıyoruz
      'xpEarned': xpEarned,
    };
  }

  // 2. JSON'dan (Map) Modele çevirir (Firebase'den çekerken)
  factory WorkoutSession.fromMap(Map<String, dynamic> map) {
    return WorkoutSession(
      id: map['id']?.toString() ?? '',
      workoutId: map['workoutId']?.toString() ?? '',
      name: map['name'] ?? 'Unknown Workout',
      category: map['category'] ?? 'General',
      // Sayısal değerleri güvenli çevir (int/double hatası olmasın)
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 0,
      calories: (map['calories'] as num?)?.toInt() ?? 0,
      // Tarih null gelirse şu anı al
      date: map['date'] != null 
          ? DateTime.parse(map['date']) 
          : DateTime.now(),
      xpEarned: (map['xpEarned'] as num?)?.toInt() ?? 0,
    );
  }
}