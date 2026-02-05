import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlife/features/profile/domain/models/user_profile.dart';
import 'package:fitlife/features/profile/domain/repositories/user_profile_repository.dart';

// Repository Provider
final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return UserProfileRepository();
});

// 1. Future Provider (Tek seferlik okuma - Splash screen vb. için)
// THIS WAS MISSING OR CAUSING THE ERROR
final userProfileFutureProvider = FutureProvider<UserProfile?>((ref) async {
  // Auth state değişimini izlemezsek, logout/login sonrası eski veri kalabilir.
  // Basit çözüm: Repo her çağrıldığında o anki user'a bakar.
  // Kullanıcı giriş yapmamışsa null dön
  if (FirebaseAuth.instance.currentUser == null) {
    return null;
  }
  
  final repo = ref.read(userProfileRepositoryProvider);
  return repo.loadProfile();
});

// 2. Stream Provider (CANLI TAKİP - Önerilen)
// Profil sayfasında ve Home sayfasında bunu kullanmak daha sağlıklıdır.
final userProfileStreamProvider = StreamProvider.autoDispose<UserProfile?>((ref) {
  // Kullanıcı giriş yapmamışsa null dön
  if (FirebaseAuth.instance.currentUser == null) {
    return const Stream.empty();
  }
  
  final repo = ref.watch(userProfileRepositoryProvider);
  return repo.getProfileStream();
});