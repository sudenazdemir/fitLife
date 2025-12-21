import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fitlife/features/routines/domain/models/routine.dart';

/// 1. Repository: Hive işlemlerini yapan sınıf
class RoutineRepository {
  final Box<Routine> _box;

  RoutineRepository(this._box);

  // Kaydet veya Güncelle
  Future<void> saveRoutine(Routine routine) async {
    await _box.put(routine.id, routine);
  }

  // Sil
  Future<void> deleteRoutine(String id) async {
    await _box.delete(id);
  }
  
  List<Routine> getAllRoutines() {
    return _box.values.toList();
  }
}

/// 2. Repository Provider
final routineRepositoryProvider = Provider<RoutineRepository>((ref) {
  final box = Hive.box<Routine>('routines');
  return RoutineRepository(box);
});

/// 3. Routines List Provider (Stream)
/// startWith yerine async* kullanarak düzeltildi.
final routinesListProvider = StreamProvider<List<Routine>>((ref) async* {
  final box = Hive.box<Routine>('routines');
  
  // 1. Önce kutudaki mevcut veriyi hemen gönder (Initial State)
  yield box.values.toList();

  // 2. Sonra kutudaki değişiklikleri dinle ve her değişimde listeyi güncelle
  await for (final _ in box.watch()) {
    yield box.values.toList();
  }
});