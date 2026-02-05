import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fitlife/features/routines/domain/models/routine.dart';

class RoutineRepository {
  // Kullanıcının veritabanı referansı: users/{uid}/routines
  DatabaseReference _getUserRef() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }

    return FirebaseDatabase.instanceFor(
      app: FirebaseAuth.instance.app,
      databaseURL: 'https://fitlife-d53c3-default-rtdb.europe-west1.firebasedatabase.app',
    ).ref().child('users/$uid/routines');
  }

  // 1. Rutinleri Getir (Stream - Canlı Takip)
  // Veritabanına bir rutin eklendiğinde veya silindiğinde bu stream tetiklenir.
  Stream<List<Routine>> getRoutinesStream() {
    try {
      final ref = _getUserRef();
      
      return ref.onValue.map((event) {
        final data = event.snapshot.value;
        if (data == null) return [];

        // Firebase verisi Map<Key, Value> olarak gelir
        final Map<dynamic, dynamic> map = data as Map<dynamic, dynamic>;
        
        final routines = map.values.map((e) {
          return Routine.fromMap(Map<String, dynamic>.from(e));
        }).toList();

        // Oluşturulma tarihine göre sırala (Eskiden yeniye)
        routines.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        
        return routines;
      });
    } catch (e) {
      // Hata durumunda boş stream dön
      return Stream.value([]);
    }
  }

  // 2. Rutin Kaydet veya Güncelle
  Future<void> saveRoutine(Routine routine) async {
    final ref = _getUserRef();
    // Rutin ID'si ile kaydediyoruz, böylece güncelleme de yapabiliriz
    await ref.child(routine.id).set(routine.toMap());
  }

  // 3. Rutin Sil
  Future<void> deleteRoutine(String routineId) async {
    final ref = _getUserRef();
    await ref.child(routineId).remove();
  }
}