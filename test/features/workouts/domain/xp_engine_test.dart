import 'package:flutter_test/flutter_test.dart';
import 'package:fitlife/features/workouts/domain/services/xp_engine.dart';

void main() {
  group('XpEngine.calculateXp', () {
    final engine = XpEngine();

    test('gives minimum XP (10) when no input provided', () {
      final xp = engine.calculateXp();
      expect(xp, 10);
    });

    test('calculates XP based on duration only', () {
      // 30 dk * 5 = 150
      final xp = engine.calculateXp(durationMinutes: 30);
      expect(xp, 150);
    });

    test('calculates XP based on sets & reps only', () {
      // (Sets 4 * Reps 10) * 0.5 = 20
      final xp = engine.calculateXp(sets: 4, reps: 10);
      expect(xp, 20);
    });

    test('calculates XP based on sets only (Routine style)', () {
      // Sets 4 * 10 = 40
      final xp = engine.calculateXp(sets: 4);
      expect(xp, 40);
    });

    test('applies HARD difficulty multiplier (x1.5)', () {
      // base: 20 * 5 = 100
      // hard multiplier: 1.5
      // total: 150
      final xp = engine.calculateXp(
        durationMinutes: 20,
        difficulty: 'hard',
      );
      expect(xp, 150);
    });

    test('applies EASY difficulty multiplier (x1.0)', () {
      // base: 20 * 5 = 100
      // easy multiplier: 1.0 (değişiklik yok)
      // total: 100
      final xp = engine.calculateXp(
        durationMinutes: 20,
        difficulty: 'easy',
      );
      expect(xp, 100);
    });
    
    test('applies INTERMEDIATE difficulty multiplier (x1.2)', () {
      // base: 10 * 5 = 50
      // medium multiplier: 1.2
      // total: 60
      final xp = engine.calculateXp(
        durationMinutes: 10,
        difficulty: 'intermediate',
      );
      expect(xp, 60);
    });
  });

  group('XpEngine.levelFromTotalXp (Quadratic System)', () {
    final engine = XpEngine();

    // Formül: Level = floor(sqrt(XP / 100)) + 1

    test('Level 1: 0 XP', () {
      final info = engine.levelFromTotalXp(0);
      expect(info.level, 1);
    });

    test('Level 1: 99 XP (Sınır)', () {
      // sqrt(0.99) -> 0 + 1 = 1
      final info = engine.levelFromTotalXp(99);
      expect(info.level, 1);
    });

    test('Level 2: 100 XP', () {
      // sqrt(1) -> 1 + 1 = 2
      final info = engine.levelFromTotalXp(100);
      expect(info.level, 2);
    });

    test('Level 3: 400 XP', () {
      // sqrt(4) -> 2 + 1 = 3
      final info = engine.levelFromTotalXp(400);
      expect(info.level, 3);
    });
    
    test('Level 11: 10,000 XP', () {
      // sqrt(100) -> 10 + 1 = 11
      final info = engine.levelFromTotalXp(10000);
      expect(info.level, 11);
    });
  });

  group('XpEngine Helper Methods', () {
    final engine = XpEngine();

    test('totalXpForLevel returns correct threshold', () {
      // Level 1 için 0 gerekir
      expect(engine.totalXpForLevel(1), 0);
      // Level 2 için 100 gerekir ((2-1)^2 * 100)
      expect(engine.totalXpForLevel(2), 100);
      // Level 3 için 400 gerekir ((3-1)^2 * 100)
      expect(engine.totalXpForLevel(3), 400);
    });

    test('xpForNextLevel returns correct target', () {
      // Level 1 isen hedef Level 2 sınırıdır (100)
      expect(engine.xpForNextLevel(1), 100);
      // Level 2 isen hedef Level 3 sınırıdır (400)
      expect(engine.xpForNextLevel(2), 400);
    });
  });
}