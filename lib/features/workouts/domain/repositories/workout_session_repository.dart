import 'package:hive_flutter/hive_flutter.dart';
import 'package:fitlife/features/workouts/domain/models/workout_session.dart';

class WorkoutSessionRepository {
  final Box<WorkoutSession> _box;

  WorkoutSessionRepository(this._box);

  Future<void> addSession(WorkoutSession session) async {
    await _box.add(session);
  }

  Future<List<WorkoutSession>> getAllSessions() async {
    final list = _box.values.toList();
    list.sort((a, b) => b.date.compareTo(a.date)); // yeniler üstte
    return list;
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}
