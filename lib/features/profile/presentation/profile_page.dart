import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlife/features/profile/domain/models/user_profile.dart';
import 'package:fitlife/features/profile/domain/providers/user_profile_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:fitlife/core/constants.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  void _openOnboarding(BuildContext context, {UserProfile? profile}) {
    context.push(
      Routes.onboarding,
      extra: profile,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileFutureProvider);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: profileAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (e, st) => Center(
              child: Text('Failed to load profile: $e'),
            ),
            data: (profile) {
              if (profile == null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No profile yet',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create a profile to personalize your FitLife experience.',
                      style: textTheme.bodyMedium,
                    ),
                    const Spacer(),
                    SafeArea(
                      top: false,
                      minimum: const EdgeInsets.only(bottom: 8),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () =>
                              _openOnboarding(context, profile: null),
                          child: const Text('Create Profile'),
                        ),
                      ),
                    ),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        child: Text(
                          profile.name.isNotEmpty
                              ? profile.name[0].toUpperCase()
                              : '?',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.name,
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (profile.goal != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              profile.goal!,
                              style: textTheme.bodyMedium,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Your Profile',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This profile is stored locally on your device and works fully offline.',
                    style: textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  SafeArea(
                    top: false,
                    minimum: const EdgeInsets.only(bottom: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () =>
                            _openOnboarding(context, profile: profile),
                        child: const Text('Edit Profile'),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
