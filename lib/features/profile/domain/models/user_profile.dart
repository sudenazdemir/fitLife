import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 2)
class UserProfile {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String? avatar;

  @HiveField(2)
  final String? goal;

  @HiveField(3)
  final int totalXp;

  @HiveField(4)
  final int level;

  @HiveField(5)
  final String? gender;

  UserProfile({
    required this.name,
    this.avatar,
    this.goal,
    this.totalXp = 0,
    this.level = 1,
    this.gender,
  });

  UserProfile copyWith({
    String? name,
    String? avatar,
    String? goal,
    int? totalXp,
    int? level,
    String? gender,
  }) {
    return UserProfile(
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      goal: goal ?? this.goal,
      totalXp: totalXp ?? this.totalXp,
      level: level ?? this.level,
      gender: gender ?? this.gender,
    );
  }

  // --- 🔥 FIREBASE İÇİN EKLENEN KISIMLAR ---

  // 1. Firebase'e gönderirken (Map'e çevir)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'avatar': avatar,
      'goal': goal,
      'totalXp': totalXp,
      'level': level,
      'gender': gender,
    };
  }

  // 2. Firebase'den çekerken (Model'e çevir)
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] ?? '',
      avatar: map['avatar'],
      goal: map['goal'],
      // Sayısal değerleri güvenli çevir (int/double hatası olmasın)
      totalXp: (map['totalXp'] as num?)?.toInt() ?? 0,
      level: (map['level'] as num?)?.toInt() ?? 1,
      gender: map['gender'],
    );
  }
}