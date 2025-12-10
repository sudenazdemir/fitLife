// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyXpAdapter extends TypeAdapter<DailyXp> {
  @override
  final int typeId = 6;

  @override
  DailyXp read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyXp(
      fields[0] as DateTime,
      fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, DailyXp obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.xp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyXpAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StatsDataAdapter extends TypeAdapter<StatsData> {
  @override
  final int typeId = 7;

  @override
  StatsData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StatsData(
      weeklyXp: (fields[0] as List).cast<DailyXp>(),
      totalXp: fields[1] as int,
      totalSessions: fields[2] as int,
      currentStreak: fields[3] as int,
      lastSession: fields[4] as WorkoutSession?,
    );
  }

  @override
  void write(BinaryWriter writer, StatsData obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.weeklyXp)
      ..writeByte(1)
      ..write(obj.totalXp)
      ..writeByte(2)
      ..write(obj.totalSessions)
      ..writeByte(3)
      ..write(obj.currentStreak)
      ..writeByte(4)
      ..write(obj.lastSession);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatsDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
