// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutAdapter extends TypeAdapter<Workout> {
  @override
  final int typeId = 5;

  @override
  Workout read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Workout(
      id: fields[0] as String,
      name: fields[1] as String,
      category: fields[2] as String,
      durationMinutes: fields[3] as int,
      calories: fields[4] as int,
      date: fields[5] as DateTime?,
      title: fields[6] as String,
      difficulty: fields[7] as String?,
      description: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Workout obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.durationMinutes)
      ..writeByte(4)
      ..write(obj.calories)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.title)
      ..writeByte(7)
      ..write(obj.difficulty)
      ..writeByte(8)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

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
