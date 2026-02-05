import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlife/features/measurements/domain/models/body_measurement.dart';
import 'package:fitlife/features/measurements/domain/repositories/measurement_repository.dart';

// Repository Provider
final measurementRepositoryProvider = Provider((ref) => MeasurementRepository());

// Liste State Provider
final measurementListProvider = AsyncNotifierProvider.autoDispose<MeasurementListNotifier, List<BodyMeasurement>>(MeasurementListNotifier.new);

class MeasurementListNotifier extends AutoDisposeAsyncNotifier<List<BodyMeasurement>> {
  late MeasurementRepository _repository;

  @override
  Future<List<BodyMeasurement>> build() async {
    _repository = ref.read(measurementRepositoryProvider);
    
    // Kullanıcı giriş yapmamışsa boş liste dön (Hata almamak için)
    if (FirebaseAuth.instance.currentUser == null) {
      return [];
    }

    return _repository.getAllMeasurements();
  }

  Future<void> addMeasurement({
    required double weight,
    double? bodyFat,
    double? waist,
    double? hip,
    required DateTime date,
  }) async {
    // Yeni kayıt için ID'yi boş bırakıyoruz, Repo oluşturacak
    final newMeasurement = BodyMeasurement(
      id: '', 
      date: date,
      weight: weight,
      bodyFat: bodyFat,
      waist: waist,
      hip: hip,
    );

    await _repository.addMeasurement(newMeasurement);
    
    // Listeyi yenile (Firebase'den tekrar çek)
    ref.invalidateSelf();
  }
  
  Future<void> deleteMeasurement(String id) async {
    await _repository.deleteMeasurement(id);
    ref.invalidateSelf();
  }
}