import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart'; // flutter pub add uuid yaptığından emin ol

// Modeller
import 'package:fitlife/features/workouts/domain/models/workout_session.dart';
import 'package:fitlife/features/profile/domain/models/user_profile.dart';

// Servisler
import 'package:fitlife/features/workouts/domain/services/xp_engine.dart';
import 'package:fitlife/core/services/ai_workout_service.dart';

class WorkoutProcessor {
  final AiWorkoutService _aiService = AiWorkoutService();
  final XpEngine _xpEngine = XpEngine();
  final Uuid _uuid = const Uuid();


  /// Bu fonksiyon UI'dan çağrılır.
  /// Metni alır -> AI Analizi -> XP Hesabı -> Hive Kaydı -> Profil Güncelleme
  Future<Map<String, dynamic>> processAndSave(String rawText) async {
    try {

      //await _aiService.checkAvailableModels();
      // 1. ADIM: AI Analizi
      debugPrint("WorkoutProcessor: AI Analizi başlıyor...");
      
      // Parse işlemini yap
      final AiParsedWorkout parsed = await _aiService.parseWorkoutText(rawText);
      
      // Feedback al (Düzeltilen kısım: Hem text hem parsed veriyi gönderiyoruz)
      final String feedback = await _aiService.generateFeedback(rawText, parsed);

      // 2. ADIM: İstatistik Tahmini
      int estimatedDuration = 0;
      int totalSets = 0;
      int totalReps = 0;

      for (var ex in parsed.exercises) {
        int s = ex.sets ?? 3;  // Varsayılan 3 set
        int r = ex.reps ?? 10; // Varsayılan 10 tekrar
        
        totalSets += s;
        totalReps += r;
        estimatedDuration += (s * 4); // Set başı ortalama 4 dk (hareket + dinlenme)
      }
      
      // Hiç egzersiz yoksa bile en az 10 dk sayalım
      if (estimatedDuration == 0) estimatedDuration = 10;

      // 3. ADIM: XP Hesaplama
      final int xpEarned = _xpEngine.calculateXp(
        durationMinutes: estimatedDuration,
        sets: totalSets,
        reps: totalReps,
        difficulty: 'medium', 
      );

      // 4. ADIM: WorkoutSession Kaydı (Hive)
      final newSession = WorkoutSession(
        id: _uuid.v4(),
        workoutId: "ai_generated",
        name: "AI Workout (${DateTime.now().day}/${DateTime.now().month})",
        category: "Smart Log",
        durationMinutes: estimatedDuration,
        calories: estimatedDuration * 7, // Tahmini kalori
        date: DateTime.now(),
        xpEarned: xpEarned,
      );

      final sessionBox = Hive.box<WorkoutSession>('workout_sessions_v3');
      await sessionBox.add(newSession);
      debugPrint("WorkoutProcessor: Antrenman kaydedildi. ID: ${newSession.id}");

      // 5. ADIM: Kullanıcı Profilini Güncelle (Level & XP)
      final profileBox = Hive.box<UserProfile>('user_profile');
      
      if (profileBox.isNotEmpty) {
        // Kutudaki ilk (ve tek) kullanıcıyı al
        final currentUser = profileBox.values.first;
        
        // Yeni toplam XP
        final newTotalXp = currentUser.totalXp + xpEarned;
        
        // Yeni Level hesabı (XpEngine kullanarak)
        final levelInfo = _xpEngine.levelFromTotalXp(newTotalXp);
        
        // Kullanıcıyı güncelle (copyWith ile yeni kopya oluştur)
        final updatedUser = currentUser.copyWith(
          totalXp: newTotalXp,
          level: levelInfo.level,
        );
        
        // Hive'daki veriyi güncelle (index 0'a yazıyoruz)
        await profileBox.putAt(0, updatedUser);
        
        debugPrint("WorkoutProcessor: Profil Güncellendi! Yeni XP: $newTotalXp, Level: ${levelInfo.level}");
      }

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