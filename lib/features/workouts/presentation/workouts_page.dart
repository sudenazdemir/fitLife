import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fitlife/core/constants.dart';
import 'package:fitlife/features/workouts/domain/providers/workouts_provider.dart';
import 'package:go_router/go_router.dart';

class WorkoutsPage extends ConsumerWidget {
  const WorkoutsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final filteredAsync = ref.watch(filteredWorkoutsProvider);
    final selectedCategory = ref.watch(selectedWorkoutCategoryProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Text(
              'Workouts',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pick a category and start training.',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  context.push(Routes.exerciseLibrary);
                },
                icon: const Icon(Icons.menu_book_outlined),
                label: const Text('Open Exercise Library'),
              ),
            ),
            const SizedBox(height: 16),

            // 🔹 KATEGORİ CHIP BAR
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _CategoryChip(
                    label: 'All',
                    value: WorkoutCategories.all,
                    selected: selectedCategory == null ||
                        selectedCategory == WorkoutCategories.all,
                    onSelected: () {
                      ref.read(selectedWorkoutCategoryProvider.notifier).state =
                          WorkoutCategories.all;
                    },
                  ),
                  const SizedBox(width: 8),
                  for (final c in WorkoutCategories.values) ...[
                    _CategoryChip(
                      label: c,
                      value: c,
                      selected: selectedCategory == c,
                      onSelected: () {
                        ref
                            .read(selectedWorkoutCategoryProvider.notifier)
                            .state = c;
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 🔹 LİSTE
            Expanded(
              child: filteredAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(
                  child: Text('Failed to load workouts: $e'),
                ),
                data: (workouts) {
                  if (workouts.isEmpty) {
                    return const Center(
                      child: Text('No workouts in this category yet.'),
                    );
                  }

                  return ListView.separated(
                    itemCount: workouts.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final w = workouts[index];
                      return ListTile(
                        title: Text(w.title),
                        subtitle: Text(
                          '${w.durationMinutes} min • ${w.category}',
                        ),
                        trailing: Text('${w.calories} kcal'),
                        onTap: () {
                          // Detay sayfasına git
                          context.push(
                            Routes.workoutDetail, // sende hangi route ise
                            extra: w,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onSelected;

  const _CategoryChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: colorScheme.primary.withValues(alpha: 0.15),
      labelStyle: theme.textTheme.labelMedium?.copyWith(
        color: selected ? colorScheme.primary : colorScheme.onSurface,
      ),
    );
  }
}
