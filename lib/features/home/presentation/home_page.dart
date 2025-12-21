import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlife/features/auth/domain/user_provider.dart';
import 'package:fitlife/features/workouts/domain/providers/xp_engine_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Kullanıcı verisini dinliyoruz
    final user = ref.watch(userProvider);
    final xpEngine = ref.watch(xpEngineProvider);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
             Color(0xFF5A5CEB), // mor
             Color(0xFFF2C24F), // sarı
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: user == null
              ? const CircularProgressIndicator(color: Colors.white)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- LOGO ---
                    Image.asset(
                      'assets/icons/fitlife_logo_transperent.png',
                      width: 150,
                    ),
                    const SizedBox(height: 10),

                    // --- İSİM & LEVEL ---
                    Text(
                      'Hi, ${user.name}!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Level ${user.level}', // Level buradan geliyor
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- XP BAR ALANI ---
                    _buildXpBar(user, xpEngine),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildXpBar(dynamic user, dynamic xpEngine) {
    // Level detaylarını hesapla (Kalan XP, Yüzde vs.)
    final levelInfo = xpEngine.levelFromTotalXp(user.totalXp);
    
    // Progress 0.0 ile 1.0 arasında olmalı
    final double progress = levelInfo.xpIntoLevel / levelInfo.xpForNextLevel;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2), // Hafif saydam arka plan
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white30),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("XP Progress", style: TextStyle(color: Colors.white, fontSize: 12)),
              Text(
                "${levelInfo.xpIntoLevel} / ${levelInfo.xpForNextLevel} XP",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // BAR
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress, // Yüzde
              minHeight: 10,
              backgroundColor: Colors.black26,
              color: const Color(0xFFF2C24F), // Sarı renk bar
            ),
          ),
          
          const SizedBox(height: 8),
          Text(
            "${(levelInfo.xpForNextLevel - levelInfo.xpIntoLevel)} XP to Level ${user.level + 1}",
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }
}