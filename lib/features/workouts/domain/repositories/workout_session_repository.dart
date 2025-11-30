import 'package:hive_flutter/hive_flutter.dart';
import 'package:fitlife/features/workouts/domain/models/workout_session.dart';

class WorkoutSessionRepository {
  static const _boxName = 'workout_sessions_v2';

  Future<Box<WorkoutSession>> _openBox() async {
    return Hive.openBox<WorkoutSession>(_boxName);
  }

  Future<void> addSession(WorkoutSession session) async {
    final box = await _openBox();
    await box.put(session.id, session);
  }

  Future<List<WorkoutSession>> getAllSessions() async {
    final box = await _openBox();
    final list = box.values.toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<void> clearAll() async {
    final box = await _openBox();
    await box.clear();
  }
}
