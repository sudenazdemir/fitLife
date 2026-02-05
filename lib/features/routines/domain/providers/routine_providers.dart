import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlife/features/routines/domain/models/routine.dart';
import 'package:fitlife/features/routines/domain/repositories/routine_repository.dart';
import 'package:fitlife/features/auth/domain/user_provider.dart'; // Kullanıcı kontrolü için

// 1. Repository Provider
final routineRepositoryProvider = Provider<RoutineRepository>((ref) {
  return RoutineRepository();
});

// 2. Routines List Provider (Stream)
// AutoDispose: Ekrandan çıkınca dinlemeyi durdurur (Performans için).
final routinesListProvider = StreamProvider.autoDispose<List<Routine>>((ref) {
  
  // 🔥 Kritik: Kullanıcı değişirse (Logout/Login) bu stream yeniden başlar.
  final user = ref.watch(userProvider);
  
  if (user == null) {
    // Kullanıcı yoksa boş liste dön
    return const Stream.empty();
  }

  final repo = ref.watch(routineRepositoryProvider);
  return repo.getRoutinesStream();
});