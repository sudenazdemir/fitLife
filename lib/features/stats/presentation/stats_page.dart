import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fitlife/features/workouts/domain/models/workout_session.dart';
import 'package:fitlife/features/workouts/domain/providers/workout_session_providers.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(workoutSessionsProvider);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: sessionsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(
            child: Text('Error loading stats: $e'),
          ),
          data: (sessions) {
            if (sessions.isEmpty) {
              return Center(
                child: Text(
                  'No workouts logged yet.\nFinish a workout to see your XP stats.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium,
                ),
              );
            }

            final xpByDay = _groupXpPerDay(sessions);
            final days = xpByDay.keys.toList(); // DateTime list
            final values = xpByDay.values.toList(); // int list

            final spots = <FlSpot>[];
            for (var i = 0; i < values.length; i++) {
              spots.add(FlSpot(i.toDouble(), values[i].toDouble()));
            }

            final totalXp = sessions.fold<int>(0, (sum, s) => sum + s.xpEarned);
            final totalSessions = sessions.length;

// Tarihi en yeni olanı bul (liste sırasına güvenme)
            final lastSession = sessions.reduce(
              (a, b) => a.date.isAfter(b.date) ? a : b,
            );

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'XP Progress',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Track how much XP you earned from your workouts.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // KPI kartları
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Total XP',
                          value: totalXp.toString(),
                          icon: Icons.bolt_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'Sessions',
                          value: totalSessions.toString(),
                          icon: Icons.fitness_center_outlined,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // XP line chart
                  SizedBox(
                    height: 220,
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: LineChart(
                          LineChartData(
                            minY: 0,
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(
                                color:
                                    colorScheme.outline.withValues(alpha: 0.3),
                              ),
                            ),
                            titlesData: FlTitlesData(
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 36,
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.toInt();
                                    if (index < 0 || index >= days.length) {
                                      return const SizedBox.shrink();
                                    }
                                    final d = days[index];
                                    final label = '${d.day}/${d.month}';
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        label,
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: spots,
                                isCurved: true,
                                barWidth: 3,
                                dotData: const FlDotData(show: true),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Last Session',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${lastSession.name} • '
                    '${lastSession.durationMinutes} min • '
                    '${lastSession.xpEarned} XP',
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Aynı gün içindeki tüm session’ların XP’sini toplayıp
  /// gün bazında map döner: { 2025-12-02: 320, ... }
  Map<DateTime, int> _groupXpPerDay(List<WorkoutSession> sessions) {
    final Map<DateTime, int> xpByDay = {};

    for (final s in sessions) {
      final d = s.date;
      final dayKey = DateTime(d.year, d.month, d.day);

      xpByDay.update(
        dayKey,
        (prev) => prev + s.xpEarned,
        ifAbsent: () => s.xpEarned,
      );
    }

    // Tarihe göre sırala (eski → yeni)
    final sortedKeys = xpByDay.keys.toList()..sort();
    final Map<DateTime, int> sorted = {};
    for (final k in sortedKeys) {
      sorted[k] = xpByDay[k]!;
    }
    return sorted;
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withAlpha(179),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
