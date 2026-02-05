import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fitlife/core/constants.dart';
import 'package:fitlife/features/profile/domain/models/user_profile.dart';
import 'package:fitlife/features/profile/domain/providers/user_profile_providers.dart';
import 'package:fitlife/features/stats/domain/providers/stats_provider.dart'; 

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
    // 1. Profil bilgilerini (İsim, Hedef vs.) çekiyoruz
    final profileAsync = ref.watch(userProfileFutureProvider);
    // 2. İstatistik verilerini (XP, Level) çekiyoruz -> StatsPage ile aynı kaynak!
    final statsAsync = ref.watch(statsProvider);
    
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final firebaseUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () => _openOnboarding(context, profile: profileAsync.value),
            icon: const Icon(Icons.edit_outlined),
            tooltip: "Edit Profile",
          )
        ],
      ),
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Failed to load profile: $e')),
          data: (profile) {
            // PROFİL YOKSA
            if (profile == null) {
              return _buildNoProfileView(context, colorScheme, firebaseUser);
            }

            // --- XP VERİSİNİ STATS PROVIDER'DAN ALIYORUZ ---
            return statsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => const SizedBox(), // Hata olursa sessiz kal veya göster
              data: (stats) {
                // StatsPage'deki mantığın aynısı:
                // Level = (TotalXP / 1000) + 1
                final int totalXp = stats.totalXp;
                final int level = (totalXp / 1000).floor() + 1;
                final int currentLevelXp = totalXp % 1000; // Bu levelda kazanılan
                final int nextLevelTarget = 1000; // Her level 1000 puan
                
                // Progress Bar (0.0 ile 1.0 arası)
                final double xpProgress = (currentLevelXp / nextLevelTarget).clamp(0.0, 1.0);

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // --- 1. PROFIL KARTI ---
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [colorScheme.primary, colorScheme.tertiary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withAlpha(77),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 32,
                                  backgroundColor: Colors.white,
                                  child: Text(
                                    profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                                    style: TextStyle(
                                      fontSize: 24, 
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        profile.name,
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      if (profile.goal != null)
                                        Text(
                                          profile.goal!,
                                          style: TextStyle(
                                            color: Colors.white.withAlpha(230),
                                            fontSize: 14,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            
                            // XP Bar & Level (StatsPage ile BİREBİR AYNI)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Level $level", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                Text("$currentLevelXp / 1000 XP", style: TextStyle(color: Colors.white.withAlpha(204), fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: xpProgress,
                                minHeight: 8,
                                backgroundColor: Colors.black.withAlpha(51),
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // --- 2. İSTATİSTİK KARTLARI (GRID) ---
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              label: "Total XP",
                              value: "$totalXp", // Stats verisi
                              icon: Icons.bolt,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _StatCard(
                              label: "Streak",
                              value: "${stats.currentStreak} Days", // Stats verisi
                              icon: Icons.local_fire_department,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // --- 3. MENÜ LİSTESİ ---
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Tracking & Settings',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Body Measurements
                      _MenuTile(
                        icon: Icons.straighten,
                        title: 'Body Measurements',
                        subtitle: 'Log weight, body fat & stats',
                        color: Colors.blue,
                        onTap: () => context.push(Routes.measurements),
                      ),
                      
                      const SizedBox(height: 12),

                      // Edit Profile
                      _MenuTile(
                        icon: Icons.edit,
                        title: 'Edit Profile Details',
                        subtitle: 'Update name, goal and gender',
                        color: Colors.teal,
                        onTap: () => _openOnboarding(context, profile: profile),
                      ),

                      const SizedBox(height: 40),

                      // --- 4. ÇIKIŞ YAP ---
                      if (firebaseUser != null)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _logout(context),
                            icon: const Icon(Icons.logout),
                            label: const Text('Log Out'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colorScheme.error,
                              side: BorderSide(color: colorScheme.error),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        
                      const SizedBox(height: 20),
                      Text(
                        "Logged in as: ${firebaseUser?.email}",
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // Profil Yoksa Gösterilecek Ekran
  Widget _buildNoProfileView(BuildContext context, ColorScheme colorScheme, User? firebaseUser) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_circle_outlined, size: 80, color: colorScheme.primary.withAlpha(128)),
          const SizedBox(height: 24),
          Text(
            'Complete Your Profile',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create a profile to start tracking your progress and leveling up!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => _openOnboarding(context, profile: null),
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Create Profile'),
            ),
          ),
          if (firebaseUser != null) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _logout(context),
              child: const Text('Log Out'),
            ),
          ]
        ],
      ),
    );
  }
}

// --- YARDIMCI WIDGETLAR ---

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(77),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant.withAlpha(128)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      tileColor: theme.colorScheme.surfaceContainerHighest.withAlpha(77),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
      trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
    );
  }
}