// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'body_measurement.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BodyMeasurementAdapter extends TypeAdapter<BodyMeasurement> {
  @override
  final int typeId = 3;

  @override
  BodyMeasurement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BodyMeasurement(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      weight: fields[2] as double,
      bodyFat: fields[3] as double?,
      waist: fields[4] as double?,
      hip: fields[5] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, BodyMeasurement obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.weight)
      ..writeByte(3)
      ..write(obj.bodyFat)
      ..writeByte(4)
      ..write(obj.waist)
      ..writeByte(5)
      ..write(obj.hip);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BodyMeasurementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
