import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fitlife/features/workouts/domain/services/xp_engine.dart';
import 'package:fitlife/features/profile/domain/models/user_profile.dart';

// 👇 1. DOĞRU IMPORT BU: Mevcut XP motorunu buradan çekiyoruz
import 'package:fitlife/features/workouts/domain/providers/xp_engine_provider.dart';

// ❌ SİLİNEN SATIR: final xpEngineProvider = Provider((ref) => XpEngine()); (Bunu sildik çünkü zaten yukarıdaki importta var)

class UserNotifier extends StateNotifier<UserProfile?> {
  final XpEngine _xpEngine;

  UserNotifier(this._xpEngine) : super(null) {
    _loadUser();
  }

  // 1. Kullanıcıyı Hive'dan Yükle
  Future<void> _loadUser() async {
    // Kutu ismini 'user_profile_box' yaptık, hata olmasın diye openBox ile garantiye alıyoruz
    final box = await Hive.openBox<UserProfile>('user_profile_box');
    
    if (box.isNotEmpty) {
      state = box.getAt(0);
    } else {
      // Kutu boşsa varsayılan bir kullanıcı oluştur
      final newUser = UserProfile(name: "New Athlete", totalXp: 0, level: 1);
      await box.add(newUser);
      state = newUser;
    }
  }

  // 2. XP Ekleme ve Level Hesaplama
  Future<void> addXp(int amount) async {
    if (state == null) return;

    final currentXp = state!.totalXp;
    final newTotalXp = currentXp + amount;

    // Level hesapla
    final levelInfo = _xpEngine.levelFromTotalXp(newTotalXp);

    // State'i güncelle
    final updatedUser = state!.copyWith(
      totalXp: newTotalXp,
      level: levelInfo.level,
    );

    // Hive'a kaydet
    final box = Hive.box<UserProfile>('user_profile_box');
    await box.putAt(0, updatedUser);
    
    // UI güncelle
    state = updatedUser;
  }
}

// Global User Provider
final userProvider = StateNotifierProvider<UserNotifier, UserProfile?>((ref) {
  // Mevcut xpEngineProvider'ı kullanıyoruz
  final xpEngine = ref.watch(xpEngineProvider);
  return UserNotifier(xpEngine);
});