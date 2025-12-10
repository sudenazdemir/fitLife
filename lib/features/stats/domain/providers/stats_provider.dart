import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlife/features/workouts/domain/models/workout_session.dart';
import 'package:fitlife/features/workouts/domain/providers/workout_session_providers.dart';

// İstatistik verilerini tutacak basit bir model
class StatsData {
  final List<DailyXp> weeklyXp;
  final int totalXp;
  final int totalSessions;
  final int currentStreak;
  final WorkoutSession? lastSession;

  StatsData({
    required this.weeklyXp,
    required this.totalXp,
    required this.totalSessions,
    required this.currentStreak,
    this.lastSession,
  });
}

class DailyXp {
  final DateTime date;
  final int xp;
  DailyXp(this.date, this.xp);
}

final statsProvider = Provider.autoDispose<AsyncValue<StatsData>>((ref) {
  final sessionsAsync = ref.watch(workoutSessionsProvider);

  return sessionsAsync.whenData((sessions) {
    if (sessions.isEmpty) {
      return StatsData(
        weeklyXp: [],
        totalXp: 0,
        totalSessions: 0,
        currentStreak: 0,
      );
    }

    // 1. Total XP & Sessions
    final totalXp = sessions.fold<int>(0, (sum, s) => sum + s.xpEarned);
    
    // 2. Last Session (Tarihe göre en yeni)
    final sortedSessions = List<WorkoutSession>.from(sessions)
      ..sort((a, b) => b.date.compareTo(a.date)); // Yeni -> Eski
    final lastSession = sortedSessions.first;

    // 3. Weekly Data (Son 7 Gün - Boş günler dahil)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final List<DailyXp> weeklyData = [];

    // Bugünden geriye 6 gün git (Toplam 7 gün)
    for (int i = 6; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      
      // O güne ait sessionları bul ve XP'lerini topla
      final xpForDay = sessions
          .where((s) => 
              s.date.year == day.year && 
              s.date.month == day.month && 
              s.date.day == day.day)
          .fold<int>(0, (sum, s) => sum + s.xpEarned);

      weeklyData.add(DailyXp(day, xpForDay));
    }

    // 4. Streak Calculation (Seri Hesaplama)
    int streak = 0;
    // Bugün antrenman yapıldı mı kontrol et, yapılmadıysa dünden başla
    // (Kullanıcı bugün henüz yapmamış olabilir ama serisi bozulmamıştır)
    DateTime checkDate = today;
    
    // Tüm unique antrenman günlerini set'e at (Hızlı arama için)
    final activeDays = sessions.map((s) => 
      DateTime(s.date.year, s.date.month, s.date.day)
    ).toSet();

    // Eğer bugün yapılmadıysa, dünden itibaren seriyi kontrol et
    if (!activeDays.contains(checkDate)) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    while (activeDays.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return StatsData(
      weeklyXp: weeklyData,
      totalXp: totalXp,
      totalSessions: sessions.length,
      currentStreak: streak,
      lastSession: lastSession,
    );
  });
});