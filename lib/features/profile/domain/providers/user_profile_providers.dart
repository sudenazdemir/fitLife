import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlife/features/profile/domain/models/user_profile.dart';
import 'package:fitlife/features/profile/domain/repositories/user_profile_repository.dart';

final userProfileRepositoryProvider =
    Provider<UserProfileRepository>((ref) {
  return UserProfileRepository();
});

final userProfileFutureProvider =
    FutureProvider<UserProfile?>((ref) async {
  final repo = ref.read(userProfileRepositoryProvider);
  return repo.loadProfile();
});
