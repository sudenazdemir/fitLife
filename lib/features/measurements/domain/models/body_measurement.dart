import 'package:hive_flutter/hive_flutter.dart';

part 'body_measurement.g.dart';

@HiveType(typeId: 3)
class BodyMeasurement {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final double weight;

  @HiveField(3)
  final double? bodyFat;

  @HiveField(4)
  final double? waist;

  @HiveField(5)
  final double? hip;

  BodyMeasurement({
    required this.id,
    required this.date,
    required this.weight,
    this.bodyFat,
    this.waist,
    this.hip,
  });

  // --- 🔥 FIREBASE İÇİN EKLENEN KISIMLAR ---

  // 1. Modeli JSON'a (Map) çevirir (Firebase'e gönderirken)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(), // Tarihi String olarak kaydederiz
      'weight': weight,
      'bodyFat': bodyFat,
      'waist': waist,
      'hip': hip,
    };
  }

  // 2. JSON'dan (Map) Modele çevirir (Firebase'den çekerken)
  factory BodyMeasurement.fromMap(Map<String, dynamic> map) {
    return BodyMeasurement(
      id: map['id']?.toString() ?? '',
      // Tarih null gelirse "şu an"ı al ki uygulama çökmesin
      date: map['date'] != null 
          ? DateTime.parse(map['date']) 
          : DateTime.now(),
      // Sayıların int/double karışıklığını önlemek için (num) olarak alıp çeviriyoruz
      weight: (map['weight'] as num?)?.toDouble() ?? 0.0,
      bodyFat: (map['bodyFat'] as num?)?.toDouble(),
      waist: (map['waist'] as num?)?.toDouble(),
      hip: (map['hip'] as num?)?.toDouble(),
    );
  }
}