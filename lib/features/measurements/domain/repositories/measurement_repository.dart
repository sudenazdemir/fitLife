import 'package:hive_flutter/hive_flutter.dart';
import 'package:fitlife/features/measurements/domain/models/body_measurement.dart';

class MeasurementRepository {
  static const _boxName = 'body_measurements_v1';

  Future<Box<BodyMeasurement>> _openBox() async {
    return Hive.openBox<BodyMeasurement>(_boxName);
  }

  Future<void> addMeasurement(BodyMeasurement measurement) async {
    final box = await _openBox();
    await box.put(measurement.id, measurement);
  }

  Future<void> deleteMeasurement(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }

  Future<List<BodyMeasurement>> getAllMeasurements() async {
    final box = await _openBox();
    final list = box.values.toList();
    // Tarihe göre sırala (Yeniden eskiye)
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }
}