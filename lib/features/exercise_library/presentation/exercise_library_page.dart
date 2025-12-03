import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fitlife/features/exercise_library/domain/providers/exercise_providers.dart';
import 'package:fitlife/features/exercise_library/domain/models/exercise.dart';

class ExerciseLibraryPage extends ConsumerWidget {
  const ExerciseLibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final exercisesAsync = ref.watch(filteredExercisesProvider);
    final muscleFilter = ref.watch(exerciseMuscleFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Library'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 🔎 Arama kutusu
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Search exercises...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) => ref
                    .read(exerciseSearchQueryProvider.notifier)
                    .state = value,
              ),
              const SizedBox(height: 12),

              // Muscle filter chip bar
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _MuscleChip(
                      label: 'All',
                      value: null,
                      selected: muscleFilter == null,
                      onTap: () => ref
                          .read(exerciseMuscleFilterProvider.notifier)
                          .state = null,
                    ),
                    const SizedBox(width: 8),
                    for (final m in ['Chest', 'Back', 'Legs', 'Core'])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _MuscleChip(
                          label: m,
                          value: m,
                          selected: muscleFilter == m,
                          onTap: () => ref
                              .read(exerciseMuscleFilterProvider.notifier)
                              .state = m,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Liste
              Expanded(
                child: exercisesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Center(
                    child: Text('Failed to load exercises: $e'),
                  ),
                  data: (exercises) {
                    if (exercises.isEmpty) {
                      return Center(
                        child: Text(
                          'No exercises found.\nTry a different search or filter.',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium,
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: exercises.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final ex = exercises[index];
                        return _ExerciseTile(exercise: ex);
                      },
                    );
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

class _MuscleChip extends StatelessWidget {
  final String label;
  final String? value;
  final bool selected;
  final VoidCallback onTap;

  const _MuscleChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: colorScheme.primary.withValues(alpha: 0.15),
      labelStyle: theme.textTheme.labelMedium?.copyWith(
        color: selected ? colorScheme.primary : colorScheme.onSurface,
      ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  final Exercise exercise;

  const _ExerciseTile({required this.exercise});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return ListTile(
      title: Text(
        exercise.name,
        style: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        '${exercise.muscleGroup} • ${exercise.equipment} • ${exercise.difficulty}',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // ileride Exercise Detail sayfasına gideriz
      },
    );
  }
}
