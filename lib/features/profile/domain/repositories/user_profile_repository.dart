import 'package:hive/hive.dart';
import 'package:fitlife/features/profile/domain/models/user_profile.dart';

class UserProfileRepository {
  static const _boxName = 'user_profile_v2';
  static const _profileKey = 'profile';

  Future<Box<UserProfile>> _openBox() async {
    return Hive.openBox<UserProfile>(_boxName);
  }

  Future<UserProfile?> loadProfile() async {
    final box = await _openBox();
    return box.get(_profileKey);
  }

  Future<void> saveProfile(UserProfile profile) async {
    final box = await _openBox();
    await box.put(_profileKey, profile);
  }

  Future<bool> hasProfile() async {
    final box = await _openBox();
    return box.containsKey(_profileKey);
  }

  Future<void> clearProfile() async {
    final box = await _openBox();
    await box.delete(_profileKey);
  }
}
