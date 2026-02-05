import 'dart:math';

// ProfilePage bu modeli bekliyor
class LevelInfo {
  final int level;
  final int currentXp;

  LevelInfo({required this.level, required this.currentXp});
}

class XpEngine {
  /// 1. Antrenmandan kazanılan XP'yi hesaplar
  /// Hem süreye hem de set/tekrar sayısına bakar.
  int calculateXp({
    int? durationMinutes,
    int? sets,
    int? reps,
    String? difficulty,
  }) {
    double xp = 0;

    // Süre bazlı XP (Dakika başı 5 XP)
    if (durationMinutes != null && durationMinutes > 0) {
      xp += durationMinutes * 5;
    }

    // Hacim bazlı XP (Set * Tekrar)
    // Eğer sadece set varsa (Rutinlerdeki gibi), set başına 10 XP
    if (sets != null && sets > 0) {
      if (reps != null && reps > 0) {
        xp += (sets * reps) * 0.5; // Her tekrar 0.5 XP
      } else {
        xp += sets * 10; // Sadece set bilgisi varsa
      }
    }

    // Zorluk Çarpanı
    if (difficulty != null) {
      switch (difficulty.toLowerCase()) {
        case 'easy':
        case 'beginner':
          xp = xp * 1.0;
          break;
        case 'medium':
        case 'intermediate':
          xp = xp * 1.2;
          break;
        case 'hard':
        case 'advanced':
        case 'expert':
          xp = xp * 1.5;
          break;
        case 'routine':
          xp = xp * 1.1; // Rutinler için bonus
          break;
      }
    }

    // Hiçbir şey yapılmadıysa bile motive etmek için 10 XP
    if (xp < 10) xp = 10;

    return xp.round();
  }

  /// 2. Toplam XP'den şu anki seviyeyi bulur
  /// Formül: Level = karekök(XP / 100) + 1
  /// Örnek: 0-99 XP = Level 1, 100 XP = Level 2, 400 XP = Level 3
  LevelInfo levelFromTotalXp(int totalXp) {
    if (totalXp < 0) return LevelInfo(level: 1, currentXp: 0);
    
    // Karesel artış (Oyunlaştırma için daha zevklidir)
    final int level = (sqrt(totalXp / 100)).floor() + 1;
    
    return LevelInfo(level: level, currentXp: totalXp);
  }

  /// 3. Bir seviyenin BAŞLAMASI için gereken toplam XP (Alt Sınır)
  /// Profil sayfasındaki progress bar'ın başlangıcı için lazım.
  /// Formül: XP = (Level - 1)^2 * 100
  double totalXpForLevel(int level) {
    if (level <= 1) return 0.0;
    return pow((level - 1), 2) * 100.0;
  }

  /// 4. Bir sonraki seviyeye geçmek için gereken HEDEF XP (Üst Sınır)
  /// Profil sayfasındaki progress bar'ın sonu için lazım.
  double xpForNextLevel(int currentLevel) {
    return totalXpForLevel(currentLevel + 1);
  }
}