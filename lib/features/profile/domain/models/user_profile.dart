import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 2) // 🔴 DİKKAT: WorkoutSession hangi id’yi kullanıyorsa bundan FARKLI olsun
class UserProfile {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String? avatar; // ileride emoji / asset vs.

  @HiveField(2)
  final String? goal;

  const UserProfile({
    required this.name,
    this.avatar,
    this.goal,
  });

  UserProfile copyWith({
    String? name,
    String? avatar,
    String? goal,
  }) {
    return UserProfile(
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      goal: goal ?? this.goal,
    );
  }
}
