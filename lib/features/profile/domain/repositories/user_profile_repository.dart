import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fitlife/features/profile/domain/models/user_profile.dart';

class UserProfileRepository {
  // Kullanıcının veritabanı referansı: users/{uid}
  DatabaseReference _getUserRef() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      // Kullanıcı yoksa hata fırlat veya null dön (Duruma göre)
      throw Exception("User not logged in");
    }

    return FirebaseDatabase.instanceFor(
      app: FirebaseAuth.instance.app,
      databaseURL: 'https://fitlife-d53c3-default-rtdb.europe-west1.firebasedatabase.app',
    ).ref().child(
      'users/$uid',
    );
  }

  // 1. Profili Yükle (Tek seferlik çekme)
  Future<UserProfile?> loadProfile() async {
    try {
      final ref = _getUserRef();
      final snapshot = await ref.get();

      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        return UserProfile.fromMap(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // 1.b Profili Canlı İzle (Stream) - Anlık güncellemeler için (XP artınca vs.)
  Stream<UserProfile?> getProfileStream() {
    try {
      final ref = _getUserRef();
      return ref.onValue.map((event) {
        final data = event.snapshot.value;
        if (data == null) return null;
        return UserProfile.fromMap(Map<String, dynamic>.from(data as Map));
      });
    } catch (e) {
      return Stream.value(null);
    }
  }

  // 2. Profili Kaydet / Güncelle
  Future<void> saveProfile(UserProfile profile) async {
    final ref = _getUserRef();
    // update kullanıyoruz ki 'email', 'uid', 'createdAt' gibi alanlar silinmesin.
    await ref.update(profile.toMap());
  }
}