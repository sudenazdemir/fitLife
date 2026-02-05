import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fitlife/core/constants.dart';
import 'package:fitlife/features/routines/domain/models/routine.dart';
import 'package:fitlife/features/routines/domain/providers/routine_providers.dart';

// 👇 Smart Log ekranı importu
import 'package:fitlife/features/workouts/presentation/smart_log_screen.dart';

class RoutineListPage extends ConsumerWidget {
  const RoutineListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routinesAsync = ref.watch(routinesListProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface, // Arka plan rengi
      appBar: AppBar(
        title: const Text('My Routines', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          // AI Quick Log Butonu
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withAlpha(77),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SmartLogScreen()),
                );
              },
              icon: const Icon(Icons.auto_awesome),
              color: colorScheme.primary, // Tema rengine uyumlu
              tooltip: 'AI Quick Log',
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push(Routes.routineCreate);
        },
        icon: const Icon(Icons.add),
        label: const Text("New Routine"),
        elevation: 2,
      ),
      body: routinesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
        data: (routines) {
          // --- EMPTY STATE (BOŞ DURUM) TASARIMI ---
          if (routines.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fitness_center_outlined,
                    size: 80,
                    color: colorScheme.onSurface.withAlpha(51),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No routines found',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first workout plan\nto start tracking.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          // --- LİSTE TASARIMI ---
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: routines.length,
            separatorBuilder: (c, i) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final routine = routines[index];
              return _RoutineCard(routine: routine);
            },
          );
        },
      ),
    );
  }
}

class _RoutineCard extends ConsumerWidget {
  final Routine routine;

  const _RoutineCard({required this.routine});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withAlpha(128),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.outlineVariant.withAlpha(128)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          context.push(Routes.routineDetail, extra: routine);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ÜST KISIM: İsim ve Menü
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          routine.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Egzersiz Sayısı Badge'i
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withAlpha(26),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${routine.exerciseIds.length} Exercises',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Edit/Delete Menüsü
                  _buildPopupMenu(context, ref, colorScheme),
                ],
              ),
              
              const SizedBox(height: 16),
              Divider(height: 1, color: colorScheme.outlineVariant.withAlpha(128)),
              const SizedBox(height: 12),

              // ALT KISIM: Günler (Yuvarlak Baloncuklar)
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, 
                       size: 16, 
                       color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildDaysRow(context, routine.daysOfWeek),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Günleri yuvarlak ikonlar (M, T, W...) olarak gösterir
  Widget _buildDaysRow(BuildContext context, List<int> days) {
    // 1: Mon, 7: Sun
    const weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: List.generate(7, (index) {
        final dayIndex = index + 1; // 1-based index
        final isActive = days.contains(dayIndex);

        return Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.only(left: 4),
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
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isActive ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPopupMenu(BuildContext context, WidgetRef ref, ColorScheme colorScheme) {
    return PopupMenuButton(
      icon: Icon(Icons.more_horiz, color: colorScheme.onSurfaceVariant),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) async {
        if (value == 'edit') {
          context.push(Routes.routineCreate, extra: routine);
        } else if (value == 'delete') {
          await ref.read(routineRepositoryProvider).deleteRoutine(routine.id);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 20),
              SizedBox(width: 8),
              Text('Edit Routine'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 20, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }
}