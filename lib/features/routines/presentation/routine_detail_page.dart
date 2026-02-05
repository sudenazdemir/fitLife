import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fitlife/core/constants.dart';
import 'package:fitlife/features/routines/domain/models/routine.dart';
import 'package:fitlife/features/exercise_library/domain/providers/exercise_providers.dart';

class RoutineDetailPage extends ConsumerWidget {
  final Routine routine;

  const RoutineDetailPage({
    super.key,
    required this.routine,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final exercisesAsync = ref.watch(exerciseListProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Routine Details'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- BAŞLIK KARTI ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colorScheme.primary, colorScheme.primaryContainer],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          routine.name,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.fitness_center, color: colorScheme.onPrimary.withAlpha(204), size: 16),
                            const SizedBox(width: 8),
                            Text(
                              '${routine.exerciseIds.length} Exercises',
                              style: TextStyle(color: colorScheme.onPrimary.withAlpha(230)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),

                  // --- PROGRAM GÜNLERİ ---
                  Text(
                    'Schedule',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildDaysRow(context, routine.daysOfWeek),

                  const SizedBox(height: 24),

                  // --- EGZERSİZ LİSTESİ ---
                  Text(
                    'Workout Plan',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  exercisesAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, s) => const Text("Could not load exercises details."),
                    data: (allExercises) {
                      // Sadece bu rutine ait egzersizleri filtrele
                      final routineExercises = allExercises
                          .where((e) => routine.exerciseIds.contains(e.id))
                          .toList();

                      if (routineExercises.isEmpty) {
                        return const Text("No exercises added to this routine yet.");
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: routineExercises.length,
                        separatorBuilder: (c, i) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final exercise = routineExercises[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest.withAlpha(77),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: colorScheme.outlineVariant.withAlpha(77)),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: colorScheme.primary.withAlpha(25),
                                child: Text(
                                  exercise.muscleGroup.isNotEmpty ? exercise.muscleGroup[0].toUpperCase() : 'E',
                                  style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(exercise.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text(exercise.muscleGroup),
                              trailing: Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // --- BAŞLAT BUTONU (ALT BAR) ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: () {
                    // Runner'a rutini gönderiyoruz
                    context.push(Routes.routineRunner, extra: routine);
                  },
                  icon: const Icon(Icons.play_circle_fill, size: 28),
                  label: const Text(
                    "Start Workout",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Yuvarlak gün gösterimi (Read-only)
  Widget _buildDaysRow(BuildContext context, List<int> days) {
    const weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final dayIndex = index + 1;
        final isActive = days.contains(dayIndex);

        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? colorScheme.primary : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? colorScheme.primary : colorScheme.outlineVariant,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              weekDays[index],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isActive ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      }),
    );
  }
}