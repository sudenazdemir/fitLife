import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlife/features/workouts/domain/models/workout_session.dart';
import 'package:fitlife/features/workouts/domain/repositories/workout_session_repository.dart';
import 'package:fitlife/features/auth/domain/user_provider.dart'; // Kullanıcı durumunu kontrol etmek için

/// Repository provider
final workoutSessionRepositoryProvider = Provider<WorkoutSessionRepository>((ref) {
  return WorkoutSessionRepository();
});

/// Tüm session’ları çeken provider
/// autoDispose: Ekran kapanınca belleği temizler.
final workoutSessionsProvider = FutureProvider.autoDispose<List<WorkoutSession>>((ref) async {
  
  // 🔥 Kritik Adım: Kullanıcı değişimini izle.
  // Eğer kullanıcı Logout olursa veya hesap değiştirirse bu provider kendini yeniden çalıştırır.
  final user = ref.watch(userProvider);

  // Kullanıcı giriş yapmamışsa (null ise) boş liste dön, hata almayı engelle.
  if (user == null) {
    return [];
  }

  final repo = ref.watch(workoutSessionRepositoryProvider);
  
  // Repository'deki yeni metot ismini kullanıyoruz
  return repo.getUserSessions();
});