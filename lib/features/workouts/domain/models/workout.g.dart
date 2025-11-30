// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Workout _$WorkoutFromJson(Map<String, dynamic> json) => Workout(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
      title: json['title'] as String,
      difficulty: json['difficulty'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$WorkoutToJson(Workout instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'durationMinutes': instance.durationMinutes,
      'calories': instance.calories,
      'date': instance.date?.toIso8601String(),
      'title': instance.title,
      'difficulty': instance.difficulty,
      'description': instance.description,
    };
