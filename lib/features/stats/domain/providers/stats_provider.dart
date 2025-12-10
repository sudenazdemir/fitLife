import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlife/features/workouts/domain/models/workout_session.dart';
import 'package:fitlife/features/workouts/domain/providers/workout_session_providers.dart';
import 'package:fitlife/features/stats/domain/models/stats_data.dart'; // Modeli buradan import et

final statsProvider = Provider.autoDispose<AsyncValue<StatsData>>((ref) {
  // Veritabanındaki tüm sessionları dinle
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

    // --- 1. Toplam XP Hesaplama ---
    final totalXp = sessions.fold<int>(0, (sum, s) => sum + s.xpEarned);
    
    // --- 2. Son Antrenmanı Bulma ---
    final sortedSessions = List<WorkoutSession>.from(sessions)
      ..sort((a, b) => b.date.compareTo(a.date)); // Yeniden eskiye
    final lastSession = sortedSessions.first;

    // --- 3. Haftalık Veri (Son 7 Gün) ---
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final List<DailyXp> weeklyData = [];

    for (int i = 6; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      
      // O günün toplam XP'sini bul
      final xpForDay = sessions
          .where((s) => 
              s.date.year == day.year && 
              s.date.month == day.month && 
              s.date.day == day.day)
          .fold<int>(0, (sum, s) => sum + s.xpEarned);

      weeklyData.add(DailyXp(day, xpForDay));
    }

    // --- 4. Streak (Seri) Hesaplama ---
    int streak = 0;
    DateTime checkDate = today;
    
    // Antrenman yapılan günleri normalize et (saat bilgisini at)
    final activeDays = sessions.map((s) => 
      DateTime(s.date.year, s.date.month, s.date.day)
    ).toSet();

    // Bugün yapılmadıysa, seriyi dünden kontrol etmeye başla
    if (!activeDays.contains(checkDate)) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    // Geriye doğru ardışık günleri say
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