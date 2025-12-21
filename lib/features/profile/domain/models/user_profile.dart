import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 2)
class UserProfile extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String? avatar;

  @HiveField(2)
  final String? goal;

  // 👇 YENİ ALANLAR
  @HiveField(3)
  final int totalXp;

  @HiveField(4)
  final int level;

  UserProfile({
    required this.name,
    this.avatar,
    this.goal,
    this.totalXp = 0, // Varsayılan 0
    this.level = 1,   // Varsayılan Level 1
  });

  UserProfile copyWith({
    String? name,
    String? avatar,
    String? goal,
    int? totalXp,
    int? level,
  }) {
    return UserProfile(
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      goal: goal ?? this.goal,
      totalXp: totalXp ?? this.totalXp,
      level: level ?? this.level,
    );
  }
}