import 'package:hive/hive.dart';
import 'package:fitlife/features/workouts/domain/models/workout_session.dart';

part 'stats_data.g.dart';

@HiveType(typeId: 6)
class DailyXp extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final int xp;

  DailyXp(this.date, this.xp);
}

@HiveType(typeId: 7)
class StatsData extends HiveObject {
  @HiveField(0)
  final List<DailyXp> weeklyXp;

  @HiveField(1)
  final int totalXp;

  @HiveField(2)
  final int totalSessions;

  @HiveField(3)
  final int currentStreak;

  @HiveField(4)
  final WorkoutSession? lastSession;

  StatsData({
    required this.weeklyXp,
    required this.totalXp,
    required this.totalSessions,
    required this.currentStreak,
    this.lastSession,
  });
}