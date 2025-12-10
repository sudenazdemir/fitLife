import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fitlife/features/routines/domain/models/routine.dart';
import 'package:fitlife/features/routines/domain/providers/routine_providers.dart';
import 'package:fitlife/features/workouts/domain/providers/workouts_provider.dart';

class RoutineCreatePage extends ConsumerStatefulWidget {
  final Routine? routineToEdit; // 👈 Düzenleme için bu parametreyi ekledik

  const RoutineCreatePage({super.key, this.routineToEdit});

  @override
  ConsumerState<RoutineCreatePage> createState() => _RoutineCreatePageState();
}

class _RoutineCreatePageState extends ConsumerState<RoutineCreatePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  final Set<int> _selectedDays = {};
  final Set<String> _selectedWorkoutIds = {};

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Eğer düzenleme modundaysak verileri doldur
    if (widget.routineToEdit != null) {
      final r = widget.routineToEdit!;
      _nameController = TextEditingController(text: r.name);
      _selectedDays.addAll(r.daysOfWeek);
      _selectedWorkoutIds.addAll(r.workoutIds);
    } else {
      _nameController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _dayLabel(int day) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    if (day >= 1 && day <= 7) return days[day - 1];
    return '$day';
  }

  Future<void> _onSavePressed() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one day.')),
      );
      return;
    }

    if (_selectedWorkoutIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one workout.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(routineRepositoryProvider);

      // Düzenliyorsak eski ID'yi, yeni ise rastgele ID kullan
      final id = widget.routineToEdit?.id ??
          '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}';

      final routine = Routine(
        id: id,
        name: _nameController.text.trim(),
        daysOfWeek: _selectedDays.toList()..sort(),
        workoutIds: _selectedWorkoutIds.toList(),
        createdAt: widget.routineToEdit?.createdAt ?? DateTime.now(),
      );

      await repo.saveRoutine(routine);
      ref.invalidate(routinesFutureProvider); // Listeyi yenile

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Routine "${routine.name}" saved!')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final workoutsAsync = ref.watch(filteredWorkoutsProvider);
    final isEditing = widget.routineToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Routine' : 'New Routine'),
      ),
      body: SafeArea(
        child: workoutsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error: $e')),
          data: (workouts) {
            if (workouts.isEmpty) {
              return const Center(child: Text('Create a workout first!'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // İsim Alanı
                  Text('Routine Name', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(hintText: 'e.g. Morning Cardio'),
                      validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Gün Seçimi
                  Text('Days', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: List.generate(7, (i) {
                      final day = i + 1;
                      final isSelected = _selectedDays.contains(day);
                      return FilterChip(
                        label: Text(_dayLabel(day)),
                        selected: isSelected,
                        onSelected: (v) {
                          setState(() {
                            v ? _selectedDays.add(day) : _selectedDays.remove(day);
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // Workout Seçimi
                  Text('Workouts', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  ...workouts.map((w) {
                    final isChecked = _selectedWorkoutIds.contains(w.id);
                    return CheckboxListTile(
                      title: Text(w.title),
                      subtitle: Text(w.category),
                      value: isChecked,
                      onChanged: (v) {
                        setState(() {
                          v == true
                              ? _selectedWorkoutIds.add(w.id)
                              : _selectedWorkoutIds.remove(w.id);
                        });
                      },
                    );
                  }),
                  
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isSaving ? null : _onSavePressed,
                      child: Text(isEditing ? 'Update Routine' : 'Create Routine'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}