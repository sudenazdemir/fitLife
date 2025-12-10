import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlife/features/measurements/domain/models/body_measurement.dart';
import 'package:fitlife/features/measurements/domain/repositories/measurement_repository.dart';

// Repository Provider
final measurementRepositoryProvider = Provider((ref) => MeasurementRepository());

// Liste State Provider
final measurementListProvider = AsyncNotifierProvider<MeasurementListNotifier, List<BodyMeasurement>>(() {
  return MeasurementListNotifier();
});

class MeasurementListNotifier extends AsyncNotifier<List<BodyMeasurement>> {
  late MeasurementRepository _repository;

  @override
  Future<List<BodyMeasurement>> build() async {
    _repository = ref.read(measurementRepositoryProvider);
    return _repository.getAllMeasurements();
  }

  Future<void> addMeasurement({
    required double weight,
    double? bodyFat,
    double? waist,
    double? hip,
    required DateTime date,
  }) async {
    final newMeasurement = BodyMeasurement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: date,
      weight: weight,
      bodyFat: bodyFat,
      waist: waist,
      hip: hip,
    );

    // Repoya ekle
    await _repository.addMeasurement(newMeasurement);
    
    // Listeyi yenile (UI güncellensin)
    ref.invalidateSelf();
  }
  
  Future<void> deleteMeasurement(String id) async {
    await _repository.deleteMeasurement(id);
    ref.invalidateSelf();
  }
}