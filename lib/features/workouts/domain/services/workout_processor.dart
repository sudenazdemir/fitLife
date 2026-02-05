import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

// Modeller
import 'package:fitlife/features/workouts/domain/models/workout_session.dart';

// Servisler
import 'package:fitlife/core/services/ai_workout_service.dart';

// Provider'lar (Repository'lere erişmek için şart)
import 'package:fitlife/features/workouts/domain/providers/workout_session_providers.dart';
import 'package:fitlife/features/auth/domain/user_provider.dart';
import 'package:fitlife/features/workouts/domain/providers/xp_engine_provider.dart';

// Bu sınıfı Provider ile sarmalıyoruz ki diğer provider'lara (Repository, User) erişebilsin
final workoutProcessorProvider = Provider((ref) => WorkoutProcessor(ref));

class WorkoutProcessor {
  final Ref _ref;
  final AiWorkoutService _aiService = AiWorkoutService();
  final Uuid _uuid = const Uuid();

  WorkoutProcessor(this._ref);

  /// Bu fonksiyon UI'dan çağrılır.
  /// Metni alır -> AI Analizi -> XP Hesabı -> Firebase Kaydı -> Profil Güncelleme
  Future<Map<String, dynamic>> processAndSave(String rawText) async {
    try {
      // 1. ADIM: AI Analizi
      debugPrint("WorkoutProcessor: AI Analizi başlıyor...");
      
      final AiParsedWorkout parsed = await _aiService.parseWorkoutText(rawText);
      final String feedback = await _aiService.generateFeedback(rawText, parsed);

      // 2. ADIM: İstatistik Tahmini
      int estimatedDuration = 0;
      int totalSets = 0;
      int totalReps = 0;

      for (var ex in parsed.exercises) {
        final int s = ex.sets ?? 3;  // Varsayılan 3 set
        final int r = ex.reps ?? 10; // Varsayılan 10 tekrar
        
        totalSets += s;
        totalReps += r;
        estimatedDuration += (s * 4); // Set başı ortalama 4 dk
      }
      
      if (estimatedDuration == 0) estimatedDuration = 10;

      // 3. ADIM: XP Hesaplama (Provider'dan Engine çekiyoruz)
      final xpEngine = _ref.read(xpEngineProvider);
      final int xpEarned = xpEngine.calculateXp(
        durationMinutes: estimatedDuration,
        sets: totalSets,
        reps: totalReps,
        difficulty: 'medium', 
      );

      // 4. ADIM: WorkoutSession Kaydı (FIREBASE)
      final newSession = WorkoutSession(
        id: _uuid.v4(),
        workoutId: "ai_generated",
        name: "AI Workout (${DateTime.now().day}/${DateTime.now().month})",
        category: "Smart Log",
        durationMinutes: estimatedDuration,
        calories: estimatedDuration * 7,
        date: DateTime.now(),
        xpEarned: xpEarned,
      );

      // 🔥 Repository Provider'ını kullanarak Firebase'e kaydet
      await _ref.read(workoutSessionRepositoryProvider).addSession(newSession);
      debugPrint("WorkoutProcessor: Antrenman Firebase'e kaydedildi. ID: ${newSession.id}");

      // 5. ADIM: Kullanıcı Profilini Güncelle (FIREBASE)
      // UserProvider'ın içindeki addXp metodu zaten Firebase'i güncelliyor.
      await _ref.read(userProvider.notifier).addXp(xpEarned);
      debugPrint("WorkoutProcessor: Profil XP güncellendi! Kazanılan: $xpEarned");

      // 6. ADIM: UI'a Sonuç Döndür
      return {
        'success': true,
        'xpEarned': xpEarned,
        'feedback': feedback,
        'parsed': parsed,
      };

    } catch (e) {
      debugPrint("WorkoutProcessor Hatası: $e");
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}