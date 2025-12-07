import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fitlife/features/routines/domain/models/routine.dart';
import 'package:fitlife/features/routines/domain/providers/routine_providers.dart';
import 'package:fitlife/features/workouts/domain/providers/workouts_provider.dart';

class RoutineCreatePage extends ConsumerStatefulWidget {
  const RoutineCreatePage({super.key});

  @override
  ConsumerState<RoutineCreatePage> createState() => _RoutineCreatePageState();
}

class _RoutineCreatePageState extends ConsumerState<RoutineCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  /// 1–7 (Mon–Sun)
  final Set<int> _selectedDays = {};
  final Set<String> _selectedWorkoutIds = {};

  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _dayLabel(int day) {
    switch (day) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '$day';
    }
  }

  Future<void> _onSavePressed() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one day of the week.'),
        ),
      );
      return;
    }

    if (_selectedWorkoutIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one workout.'),
        ),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    setState(() {
      _isSaving = true;
    });

    final repo = ref.read(routineRepositoryProvider);

    final id =
        '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}';

    final routine = Routine(
      id: id,
      name: _nameController.text.trim(),
      daysOfWeek: _selectedDays.toList()..sort(),
      workoutIds: _selectedWorkoutIds.toList(),
      createdAt: DateTime.now(),
    );

    try {
      await repo.saveRoutine(routine); // ← DOĞRU METHOD
      ref.invalidate(routinesFutureProvider); // ← DOĞRU PROVIDER

      messenger.showSnackBar(
        SnackBar(
          content: Text('Routine "${routine.name}" created!'),
        ),
      );

      router.pop();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to save routine: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final workoutsAsync = ref.watch(filteredWorkoutsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Weekly Routine'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: workoutsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(
              child: Text('Failed to load workouts: $e'),
            ),
            data: (workouts) {
              if (workouts.isEmpty) {
                return Center(
                  child: Text(
                    'You don’t have any workouts yet.\nCreate a workout first.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium,
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Routine name',
                    style: textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Push / Pull / Legs',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a routine name.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Days of the week',
                    style: textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(7, (index) {
                      final day = index + 1;
                      final selected = _selectedDays.contains(day);
                      return ChoiceChip(
                        label: Text(_dayLabel(day)),
                        selected: selected,
                        onSelected: (value) {
                          setState(() {
                            if (value) {
                              _selectedDays.add(day);
                            } else {
                              _selectedDays.remove(day);
                            }
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Workouts in this routine',
                    style: textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: workouts.length,
                      itemBuilder: (context, index) {
                        final w = workouts[index];
                        final selected = _selectedWorkoutIds.contains(w.id);

                        return CheckboxListTile(
                          value: selected,
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                _selectedWorkoutIds.add(w.id);
                              } else {
                                _selectedWorkoutIds.remove(w.id);
                              }
                            });
                          },
                          title: Text(w.title),
                          subtitle: Text(
                            '${w.category} • ${w.durationMinutes} min',
                          ),
                        );
                      },
                    ),
                  ),
                  SafeArea(
                    top: false,
                    minimum: const EdgeInsets.only(top: 8, bottom: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _isSaving ? null : _onSavePressed,
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Save Routine'),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
