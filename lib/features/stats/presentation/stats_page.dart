import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:fitlife/features/stats/domain/models/stats_data.dart';
import 'package:fitlife/features/stats/domain/providers/stats_provider.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: statsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Error: $e')),
          data: (stats) {
            if (stats.totalSessions == 0) {
              return _buildEmptyState(theme.textTheme, colorScheme);
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. HEADER: LEVEL & XP
                  _buildProfileHeader(context, stats),

                  const SizedBox(height: 16),

                  // 2. HABIT TRACKER CHART
                  _buildChartSection(context, stats.weeklyXp),

                  const SizedBox(height: 16),

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

                  const SizedBox(height: 16),

                  // 4. LAST ACTIVITY (Düzeltildi)
                  if (stats.lastSession != null)
                    _buildLastActivity(context, stats), // Düzeltme: stats nesnesini gönderiyoruz
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. PROFILE HEADER
  // ---------------------------------------------------------------------------
  Widget _buildProfileHeader(BuildContext context, StatsData stats) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final int level = (stats.totalXp / 1000).floor() + 1;
    final int currentLevelXp = stats.totalXp % 1000;
    final double progress = currentLevelXp / 1000;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: colorScheme.primary,
                child: Icon(Icons.person, color: colorScheme.onPrimary, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Fitness Hunter",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Level $level",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${stats.totalXp} XP",
                    style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold, color: colorScheme.primary),
                  ),
                  Text(
                    "Total Earned",
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Progress", style: theme.textTheme.labelSmall),
                  Text("$currentLevelXp / 1000 XP", style: theme.textTheme.labelSmall),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: colorScheme.surfaceDim,
                  color: colorScheme.primary,
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
      padding: const EdgeInsets.all(20),
      height: 250,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Activity (Last 7 Days)",
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Icon(Icons.bar_chart, color: colorScheme.primary),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
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
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.xp.toDouble(),
                        color: colorScheme.primary,
                        width: 16,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: targetMaxY,
                          color: colorScheme.surfaceDim.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
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
          Text("Stats Tracker", style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildSkillRow(
            context,
            label: "Streak",
            valueText: "${stats.currentStreak} Days",
            progress: (stats.currentStreak / 30).clamp(0.0, 1.0),
            icon: Icons.local_fire_department,
            color: Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildSkillRow(
            context,
            label: "Sessions",
            valueText: "${stats.totalSessions}",
            progress: (stats.totalSessions / 100).clamp(0.0, 1.0),
            icon: Icons.fitness_center,
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

    return Container(
      height: 155,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text("Daily Goal", style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const Spacer(),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: CircularProgressIndicator(
                  value: 0.75,
                  strokeWidth: 8,
                  backgroundColor: colorScheme.surfaceDim,
                  color: colorScheme.primary,
                  strokeCap: StrokeCap.round,
                ),
              ),
              const Text("75%", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. LAST ACTIVITY (DÜZELTİLDİ)
  // ---------------------------------------------------------------------------
  // Bu fonksiyon artık SessionData yerine StatsData alıyor, böylece tip hatası olmaz.
  Widget _buildLastActivity(BuildContext context, StatsData stats) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // stats.lastSession'ın null olmadığı yerde çağrıldığını biliyoruz
    final session = stats.lastSession!; 

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Last Activity",
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.history, color: colorScheme.onPrimaryContainer),
            ),
            title: Text(
              session.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              DateFormat('MMM d, y • H:mm').format(session.date),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
              ),
              child: Text(
                '+${session.xpEarned} XP',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(TextTheme textTheme, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 64, color: colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Text(
            'No Data Yet',
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete your first workout to\nunlock insights!',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}