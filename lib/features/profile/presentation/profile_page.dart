import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fitlife/core/constants.dart';
import 'package:fitlife/features/profile/domain/models/user_profile.dart';
import 'package:fitlife/features/profile/domain/providers/user_profile_providers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  void _openOnboarding(BuildContext context, {UserProfile? profile}) {
    context.push(
      Routes.onboarding,
      extra: profile,
    );
  }

  void _logout(BuildContext context) {
    FirebaseAuth.instance.signOut();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Signed out')),
    );

    context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileFutureProvider);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme; // Renkleri kullanmak için
    final firebaseUser = FirebaseAuth.instance.currentUser;

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
              // HENÜZ local profile yoksa:
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
                    const SizedBox(height: 16),
                    if (firebaseUser != null) ...[
                      Text(
                        'Logged in as: ${firebaseUser.email}',
                        style: textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                    ],
                    const Spacer(),
                    SafeArea(
                      top: false,
                      minimum: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FilledButton(
                            onPressed: () =>
                                _openOnboarding(context, profile: null),
                            child: const Text('Create Profile'),
                          ),
                          const SizedBox(height: 8),
                          if (firebaseUser != null)
                            OutlinedButton(
                              onPressed: () => _logout(context),
                              child: const Text('Logout'),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              }

              // Local profile VAR:
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER ---
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
                          if (firebaseUser != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              firebaseUser.email ?? '',
                              style: textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),

                  // --- 🆕 TRACKING MENU SECTION ---
                  Text(
                    'Tracking & Stats',
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Body Measurements Tile
                  Material(
                    color: Colors.transparent,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.straighten, color: colorScheme.primary),
                      ),
                      title: const Text('Body Measurements'),
                      subtitle: const Text('Log weight, body fat & measurements'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                         // 🚀 Measurements sayfasına yönlendirme
                         context.push(Routes.measurements);
                      },
                    ),
                  ),
                  // Çizgi ekleyerek ayırabiliriz
                  Divider(color: colorScheme.outlineVariant.withOpacity(0.3)),

                  const Spacer(),
                  
                  // --- BOTTOM ACTIONS ---
                  SafeArea(
                    top: false,
                    minimum: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FilledButton(
                          onPressed: () =>
                              _openOnboarding(context, profile: profile),
                          child: const Text('Edit Profile'),
                        ),
                        const SizedBox(height: 8),
                        if (firebaseUser != null)
                          OutlinedButton(
                            onPressed: () => _logout(context),
                            child: const Text('Logout'),
                          ),
                      ],
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