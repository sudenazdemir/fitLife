// lib/features/workouts/domain/services/xp_engine.dart
class XpEngine {
  int calculateXp({
    int? durationMinutes,
    int? sets,
    int? reps,
    String? difficulty,
  }) {
    int xp = 0;

    // Süreye dayalı XP (örn: dakika başına 5 XP)
    if (durationMinutes != null && durationMinutes > 0) {
      xp += durationMinutes * 5;
    }

    // Set/rep bazlı XP (her rep 1 XP)
    if (sets != null && sets > 0 && reps != null && reps > 0) {
      xp += sets * reps;
    }

    // Zorluk çarpanı (istersen sonra fine-tune edersin)
    if (difficulty != null) {
      switch (difficulty.toLowerCase()) {
        case 'easy':
          xp = (xp * 0.8).round();
          break;
        case 'hard':
          xp = (xp * 1.2).round();
          break;
        // 'medium' veya bilinmeyen → olduğu gibi kalsın
      }
    }

    if (xp == 0) {
      xp = 10; // minimum XP
    }

    return xp;
  }
}
