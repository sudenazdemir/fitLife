// lib/features/workouts/domain/services/xp_engine.dart

class LevelInfo {
  final int level;
  final int xpIntoLevel;
  final int xpForNextLevel;

  const LevelInfo({
    required this.level,
    required this.xpIntoLevel,
    required this.xpForNextLevel,
  });
}
class XpEngine {
  int calculateXp({
    int? durationMinutes,
    int? sets,
    int? reps,
    String? difficulty,
  }) {
    int xp = 0;

    if (durationMinutes != null && durationMinutes > 0) {
      xp += durationMinutes * 5;
    }

    if (sets != null && sets > 0 && reps != null && reps > 0) {
      xp += sets * reps;
    }

    if (difficulty != null) {
      switch (difficulty.toLowerCase()) {
        case 'easy':
          xp = (xp * 0.8).round();
          break;
        case 'hard':
          xp = (xp * 1.2).round();
          break;
        default:
          break; // medium / unknown → olduğu gibi kalsın
      }
    }

    if (xp == 0) {
      xp = 10;
    }

    return xp;
  }

  /// totalXp -> kaçıncı leveldeyim?
  /// Varsayılan: her 1000 XP'de bir level atla.
  LevelInfo levelFromTotalXp(int totalXp, {int xpPerLevel = 1000}) {
    if (totalXp < 0) totalXp = 0;

    final level = (totalXp ~/ xpPerLevel) + 1; // Level 1: 0–999 XP
    final xpIntoLevel = totalXp % xpPerLevel;
    return LevelInfo(
      level: level,
      xpIntoLevel: xpIntoLevel,
      xpForNextLevel: xpPerLevel,
    );
  }

  /// Eski total XP'den yeni total XP'ye geçerken level atlandı mı?
  bool didLevelUp(int oldTotalXp, int newTotalXp, {int xpPerLevel = 1000}) {
    final oldLevel = levelFromTotalXp(oldTotalXp, xpPerLevel: xpPerLevel).level;
    final newLevel = levelFromTotalXp(newTotalXp, xpPerLevel: xpPerLevel).level;
    return newLevel > oldLevel;
  }
}

