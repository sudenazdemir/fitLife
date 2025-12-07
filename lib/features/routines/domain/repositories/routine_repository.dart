import 'package:hive_flutter/hive_flutter.dart';
import 'package:fitlife/features/routines/domain/models/routine.dart';

class RoutineRepository {
  static const _boxName = 'routines';

  Future<Box<Routine>> _openBox() async {
    return Hive.openBox<Routine>(_boxName);
  }

  Future<void> saveRoutine(Routine routine) async {
    final box = await _openBox();
    await box.put(routine.id, routine);
  }

  Future<List<Routine>> getAllRoutines() async {
    final box = await _openBox();
    final list = box.values.toList();
    // İstersen tarihe göre sırala
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  Future<void> deleteRoutine(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }

  Future<void> clearAll() async {
    final box = await _openBox();
    await box.clear();
  }
}
