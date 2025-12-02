import 'package:flutter_test/flutter_test.dart';
import 'package:fitlife/features/workouts/domain/services/xp_engine.dart';

void main() {
  group('XpEngine.calculateXp', () {
    final engine = XpEngine();

    test('gives minimum XP when no input provided', () {
      final xp = engine.calculateXp();
      expect(xp, 10);
    });

    test('calculates XP based on duration only', () {
      final xp = engine.calculateXp(durationMinutes: 30);
      // 30 * 5 = 150
      expect(xp, 150);
    });

    test('calculates XP based on sets & reps only', () {
      final xp = engine.calculateXp(sets: 4, reps: 10);
      // 4 * 10 = 40
      expect(xp, 40);
    });

    test('applies hard difficulty multiplier', () {
      final xp = engine.calculateXp(
        durationMinutes: 20,
        difficulty: 'hard',
      );
      // base: 20 * 5 = 100 → hard *1.2 = 120
      expect(xp, 120);
    });

    test('applies easy difficulty multiplier', () {
      final xp = engine.calculateXp(
        durationMinutes: 20,
        difficulty: 'easy',
      );
      // base: 100 → easy *0.8 = 80
      expect(xp, 80);
    });
  });

  group('XpEngine.levelFromTotalXp & didLevelUp', () {
    final engine = XpEngine();

    test('level 1 from 0 XP', () {
      final info = engine.levelFromTotalXp(0);
      expect(info.level, 1);
      expect(info.xpIntoLevel, 0);
      expect(info.xpForNextLevel, 1000);
    });

    test('still level 1 at 999 XP', () {
      final info = engine.levelFromTotalXp(999);
      expect(info.level, 1);
      expect(info.xpIntoLevel, 999);
    });

    test('level 2 from 1000 XP', () {
      final info = engine.levelFromTotalXp(1000);
      expect(info.level, 2);
      expect(info.xpIntoLevel, 0);
    });

    test('didLevelUp returns true when crossing level boundary', () {
      final didLevelUp = engine.didLevelUp(900, 1100);
      expect(didLevelUp, true);
    });

    test('didLevelUp returns false when staying in same level', () {
      final didLevelUp = engine.didLevelUp(100, 500);
      expect(didLevelUp, false);
    });
  });
}
