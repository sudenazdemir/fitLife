import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:fitlife/features/workouts/domain/models/workout_session.dart';

class WorkoutSessionRepository {
  // Kullanıcının veritabanı referansı: users/{uid}/sessions
  DatabaseReference _getUserRef() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }
    
    // 🔥 ÖNEMLİ: Avrupa sunucusu URL'i
    return FirebaseDatabase.instanceFor(
      app: FirebaseAuth.instance.app,
      databaseURL: 'https://fitlife-d53c3-default-rtdb.europe-west1.firebasedatabase.app',
    ).ref().child('users/$uid/sessions');
  }

  // 1. Oturumu Kaydet
  Future<void> addSession(WorkoutSession session) async {
    try {
      final ref = _getUserRef();
      // ID'yi session.id olarak kullanıyoruz
      await ref.child(session.id).set(session.toMap());
    } catch (e) {
      debugPrint("Antrenman kaydetme hatası: $e");
      rethrow;
    }
  }

  // 2. Kullanıcının Tüm Oturumlarını Getir (getUserSessions olarak adlandırdık)
  Future<List<WorkoutSession>> getUserSessions() async {
    try {
      final ref = _getUserRef();
      final snapshot = await ref.get();

      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        
        final list = data.values.map((e) {
          final map = Map<String, dynamic>.from(e as Map);
          return WorkoutSession.fromMap(map); 
        }).toList();

        // Tarihe göre sırala (Yeniden eskiye)
        list.sort((a, b) => b.date.compareTo(a.date));
        
        return list;
      }
      return [];
    } catch (e) {
      debugPrint("Antrenman geçmişi çekme hatası: $e");
      return [];
    }
  }

  // 3. Tüm Geçmişi Temizle (Opsiyonel)
  Future<void> clearAll() async {
    final ref = _getUserRef();
    await ref.remove();
  }
}