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

    // 🔹 Mock XP datası (7 günlük örnek)
    final mockXpPerDay = <double>[50, 80, 40, 100, 70, 120, 90];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Weekly XP',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: XpLineChart(xpValues: mockXpPerDay),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: sessionsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (sessions) {
                    return _SessionsList(sessions: sessions);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class XpLineChart extends StatelessWidget {
  const XpLineChart({
    super.key,
    required this.xpValues,
  });

  final List<double> xpValues;

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];
    for (var i = 0; i < xpValues.length; i++) {
      spots.add(FlSpot(i.toDouble(), xpValues[i]));
    }

    final double maxY = ((xpValues.reduce((a, b) => a > b ? a : b) * 1.2).clamp(10, 9999)).toDouble();

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (xpValues.length - 1).toDouble(),
        minY: 0,
        maxY: maxY,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: maxY / 4,
            ),
          ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final dayIndex = value.toInt();
                if (dayIndex < 0 || dayIndex >= xpValues.length) {
                  return const SizedBox.shrink();
                }
                // örnek: D1, D2, ...
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('D${dayIndex + 1}',
                      style: const TextStyle(fontSize: 10)),
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
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              applyCutOffY: false,
              cutOffY: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionsList extends StatelessWidget {
  const _SessionsList({
    required this.sessions,
  });

  final List<WorkoutSession> sessions;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            // Bu butonu istersen sonra kaldırırız,
            // şimdilik Hive persist testine devam edebilir.
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Workout sessions list below'),
              ),
            );
          },
          child: const Text('Workout history info'),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, i) {
              final s = sessions[i];
              return ListTile(
                title: Text(s.name),
                subtitle: Text(
                  '${s.durationMinutes} min - ${s.category}',
                ),
                trailing: Text('${s.calories} kcal'),
              );
            },
          ),
        ),
      ],
    );
  }
}
