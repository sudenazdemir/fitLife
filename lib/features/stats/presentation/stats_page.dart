import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:fitlife/features/stats/domain/models/stats_data.dart';
import 'package:fitlife/features/stats/domain/providers/stats_provider.dart';
import 'package:fitlife/features/profile/domain/providers/user_profile_providers.dart'; // İsim bilgisini almak için

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);
    final userProfileAsync = ref.watch(userProfileFutureProvider); // Kullanıcı adını çekmek için
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: statsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Error: $e')),
          data: (stats) {
            // İstatistik yoksa boş ekran göster
            if (stats.totalSessions == 0) {
              return _buildEmptyState(theme.textTheme, colorScheme);
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. HEADER: LEVEL & XP (Gradient ile güzelleştirildi)
                  // İsim bilgisini profil provider'ından alıp gönderiyoruz
                  _buildProfileHeader(
                    context, 
                    stats, 
                    userProfileAsync.value?.name ?? "Fitness Hunter"
                  ),

                  const SizedBox(height: 24),

                  // 2. HABIT TRACKER CHART
                  Text(
                    "Weekly Activity", 
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 12),
                  _buildChartSection(context, stats.weeklyXp),

                  const SizedBox(height: 24),

                  // 3. SKILL TRACKER & GOALS
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sol: Skill Tracker
                      Expanded(
                        flex: 3,
                        child: _buildSkillTracker(context, stats),
                      ),
                      const SizedBox(width: 12),
                      // Sağ: Goal Completion
                      Expanded(
                        flex: 2,
                        child: _buildCircularGoal(context, stats),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 4. LAST ACTIVITY
                  if (stats.lastSession != null)
                    _buildLastActivity(context, stats),
                    
                  const SizedBox(height: 40), // Alt boşluk
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. PROFILE HEADER (MODERN GRADIENT)
  // ---------------------------------------------------------------------------
  Widget _buildProfileHeader(BuildContext context, StatsData stats, String userName) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Level Hesaplama: 1000 XP = 1 Level
    final int level = (stats.totalXp / 1000).floor() + 1;
    final int currentLevelXp = stats.totalXp % 1000;
    final double progress = (currentLevelXp / 1000).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.surfaceContainerHighest,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                padding: const EdgeInsets.all(2), // Border efekti
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.primary, width: 2),
                ),
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: colorScheme.primary,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : "F",
                    style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // İsim ve Level
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withAlpha(26),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Level $level",
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Toplam XP (Sağda)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${stats.totalXp}",
                    style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900, color: colorScheme.primary),
                  ),
                  Text(
                    "Total XP",
                    style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.outline),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Next Level Progress", style: theme.textTheme.labelSmall),
                  Text("$currentLevelXp / 1000 XP", style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: Colors.white.withAlpha(128),
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. CHART SECTION
  // ---------------------------------------------------------------------------
  Widget _buildChartSection(BuildContext context, List<DailyXp> weeklyData) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final maxY = weeklyData.isEmpty
        ? 100.0
        : weeklyData.map((e) => e.xp).reduce((a, b) => a > b ? a : b).toDouble();
    final targetMaxY = maxY == 0 ? 100.0 : maxY * 1.2;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      height: 220,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(77),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant.withAlpha(128)),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: targetMaxY,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => colorScheme.inverseSurface,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.toInt()} XP',
                  TextStyle(
                    color: colorScheme.onInverseSurface,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= weeklyData.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('E').format(weeklyData[index].date)[0],
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: weeklyData.asMap().entries.map((entry) {
            final isToday = entry.key == 6; // Son eleman bugündür (liste sıralıysa)
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.xp.toDouble(),
                  // Bugünü farklı renkte göster
                  color: isToday ? colorScheme.primary : colorScheme.primary.withAlpha(153),
                  width: 14,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: targetMaxY,
                    color: colorScheme.surfaceDim.withAlpha(128),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. SKILL TRACKER
  // ---------------------------------------------------------------------------
  Widget _buildSkillTracker(BuildContext context, StatsData stats) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_graph, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text("Stats", style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          _buildSkillRow(
            context,
            label: "Streak",
            valueText: "${stats.currentStreak} Days",
            progress: (stats.currentStreak / 30).clamp(0.0, 1.0),
            icon: Icons.local_fire_department_rounded,
            color: Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildSkillRow(
            context,
            label: "Sessions",
            valueText: "${stats.totalSessions}",
            progress: (stats.totalSessions / 100).clamp(0.0, 1.0),
            icon: Icons.fitness_center_rounded,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildSkillRow(
    BuildContext context, {
    required String label,
    required String valueText,
    required double progress,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(label, style: theme.textTheme.bodySmall),
            const Spacer(),
            Text(valueText, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.colorScheme.surfaceDim,
            color: color,
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 4. CIRCULAR GOAL
  // ---------------------------------------------------------------------------
  Widget _buildCircularGoal(BuildContext context, StatsData stats) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Basit bir hedef mantığı: Haftada 3 antrenman (Örnek)
    final weeklySessions = stats.weeklyXp.where((d) => d.xp > 0).length;
    final weeklyGoal = 3;
    final progress = (weeklySessions / weeklyGoal).clamp(0.0, 1.0);

    return Container(
      height: 160, // Yüksekliği sabitledik
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text("Weekly Goal", style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const Spacer(),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: colorScheme.surfaceDim,
                  color: colorScheme.tertiary,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${(progress * 100).toInt()}%",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Text("$weeklySessions / $weeklyGoal workouts", style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. LAST ACTIVITY
  // ---------------------------------------------------------------------------
  Widget _buildLastActivity(BuildContext context, StatsData stats) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final session = stats.lastSession!; 

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Last Activity",
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant.withAlpha(128)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(5),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.history_toggle_off, color: colorScheme.onSecondaryContainer),
            ),
            title: Text(
              session.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              DateFormat('MMM d, y • H:mm').format(session.date),
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withAlpha(51)),
              ),
              child: Text(
                '+${session.xpEarned} XP',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Boş Durum Ekranı
  Widget _buildEmptyState(TextTheme textTheme, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withAlpha(77),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.bar_chart_rounded, size: 64, color: colorScheme.primary.withAlpha(128)),
          ),
          const SizedBox(height: 24),
          Text(
            'No Data Yet',
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete your first workout to\nunlock detailed insights!',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}