import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fitlife/features/measurements/domain/models/body_measurement.dart';

class MeasurementRepository {
  // Kullanıcıya özel veritabanı yolu: users/{uid}/measurements
  DatabaseReference _getUserRef() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }

    // Avrupa sunucusu ayarı (Senin proje ayarlarına göre)
    return FirebaseDatabase.instanceFor(
      app: FirebaseAuth.instance.app,
      databaseURL: 'https://fitlife-d53c3-default-rtdb.europe-west1.firebasedatabase.app',
    ).ref().child(
      'users/$uid/measurements',
    );
  }

  // 1. Ölçümleri Getir (Firebase'den)
  Future<List<BodyMeasurement>> getAllMeasurements() async {
    try {
      final ref = _getUserRef();
      final snapshot = await ref.get();

      if (snapshot.exists && snapshot.value != null) {
        // Firebase'den gelen veri Map<dynamic, dynamic> olur
        final data = snapshot.value as Map<dynamic, dynamic>;
        
        final list = data.values.map((e) {
          // JSON -> Model çevirimi
          final map = Map<String, dynamic>.from(e as Map);
          return BodyMeasurement.fromMap(map); 
        }).toList();

        // Tarihe göre sırala (Yeniden eskiye)
        list.sort((a, b) => b.date.compareTo(a.date));
        return list;
      }
      return [];
    } catch (e) {
      // Hata durumunda veya veri yoksa boş liste dön
      return [];
    }
  }

  // 2. Ölçüm Ekle (Firebase'e)
  Future<void> addMeasurement(BodyMeasurement measurement) async {
    final ref = _getUserRef();
    
    // Eğer ID yoksa yeni bir key oluştur
    final String key = measurement.id.isNotEmpty ? measurement.id : ref.push().key!;
    
    // ID'yi modele de ekleyip map olarak kaydediyoruz
    final dataToSave = measurement.toMap();
    dataToSave['id'] = key;

    await ref.child(key).set(dataToSave);
  }

  // 3. Ölçüm Sil
  Future<void> deleteMeasurement(String id) async {
    final ref = _getUserRef();
    await ref.child(id).remove();
  }
}