import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fitlife/features/routines/domain/models/routine.dart';
import 'package:fitlife/features/routines/domain/providers/routine_providers.dart';
import 'package:fitlife/features/exercise_library/domain/providers/exercise_providers.dart'; // Exercise modeli için

class RoutineCreatePage extends ConsumerStatefulWidget {
  final Routine? routineToEdit;
  const RoutineCreatePage({super.key, this.routineToEdit});

  @override
  ConsumerState<RoutineCreatePage> createState() => _RoutineCreatePageState();
}

class _RoutineCreatePageState extends ConsumerState<RoutineCreatePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  final Set<int> _selectedDays = {};
  final Set<String> _selectedExerciseIds = {};
  
  bool _isReminderEnabled = false;
  TimeOfDay? _selectedTime;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.routineToEdit != null) {
      final r = widget.routineToEdit!;
      _nameController = TextEditingController(text: r.name);
      _selectedDays.addAll(r.daysOfWeek);
      _selectedExerciseIds.addAll(r.exerciseIds);
      
      _isReminderEnabled = r.isReminderEnabled;
      if (r.reminderHour != null && r.reminderMinute != null) {
        _selectedTime = TimeOfDay(hour: r.reminderHour!, minute: r.reminderMinute!);
      }
    } else {
      _nameController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Günleri yuvarlak baloncuk içinde göstermek için
  Widget _buildDaySelector(ColorScheme colorScheme) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final dayIndex = index + 1;
        final isSelected = _selectedDays.contains(dayIndex);
        
        return GestureDetector(
          onTap: () {
            setState(() {
              isSelected ? _selectedDays.remove(dayIndex) : _selectedDays.add(dayIndex);
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected ? colorScheme.primary : colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? colorScheme.primary : colorScheme.outline,
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                days[index],
                style: TextStyle(
                  color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Future<void> _pickTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context, 
      initialTime: _selectedTime ?? now,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _isReminderEnabled = true; // Saat seçildiyse otomatik aktif et
      });
    }
  }

  Future<void> _onSavePressed() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one day.')));
      return;
    }
    if (_selectedExerciseIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one exercise.')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(routineRepositoryProvider);
      final id = widget.routineToEdit?.id ?? '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}';

      final routine = Routine(
        id: id,
        name: _nameController.text.trim(),
        daysOfWeek: _selectedDays.toList()..sort(),
        exerciseIds: _selectedExerciseIds.toList(),
        createdAt: widget.routineToEdit?.createdAt ?? DateTime.now(),
        isReminderEnabled: _isReminderEnabled,
        reminderHour: _selectedTime?.hour,
        reminderMinute: _selectedTime?.minute,
      );

      await repo.saveRoutine(routine);

      if (!mounted) return;
      context.pop(); 
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(exerciseListProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEditing = widget.routineToEdit != null;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Routine' : 'New Routine', style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- İSİM ALANI ---
                Text('Routine Name', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Full Body Workout',
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withAlpha(77),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    prefixIcon: const Icon(Icons.edit_outlined),
                  ),
                  validator: (v) => v!.trim().isEmpty ? 'Please enter a name' : null,
                ),
                
                const SizedBox(height: 24),

                // --- GÜN SEÇİMİ ---
                Text('Schedule Days', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildDaySelector(colorScheme),
                
                const SizedBox(height: 24),

                // --- ZAMAN SEÇİMİ (Opsiyonel) ---
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withAlpha(77),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colorScheme.outlineVariant.withAlpha(77)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: colorScheme.primaryContainer, shape: BoxShape.circle),
                        child: Icon(Icons.access_time_filled, color: colorScheme.primary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Workout Time", style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                            Text(
                              _selectedTime != null ? _selectedTime!.format(context) : "Not set",
                              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isReminderEnabled,
                        onChanged: (val) {
                          setState(() {
                            _isReminderEnabled = val;
                            if (val && _selectedTime == null) _pickTime();
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // --- EGZERSİZ SEÇİMİ ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Select Exercises', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withAlpha(26),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_selectedExerciseIds.length} selected',
                        style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                exercisesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Text('Error loading exercises: $e', style: const TextStyle(color: Colors.red)),
                  data: (exercises) {
                    if (exercises.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(20),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: colorScheme.outlineVariant),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text("No exercises found in library."),
                      );
                    }
                    
                    // Egzersizleri KAS GRUBUNA göre sırala
                    // (İsteğe bağlı: Gruplayarak göstermek daha şık olur ama basit liste de yeterli)
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: exercises.length,
                      separatorBuilder: (c, i) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final ex = exercises[index];
                        final isSelected = _selectedExerciseIds.contains(ex.id);
                        
                        return InkWell(
                          onTap: () {
                            setState(() {
                              isSelected 
                                ? _selectedExerciseIds.remove(ex.id) 
                                : _selectedExerciseIds.add(ex.id);
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected ? colorScheme.primaryContainer.withAlpha(102) : colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? colorScheme.primary : colorScheme.outlineVariant.withAlpha(77),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Kas Grubu İkonu/Baş harfi
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: isSelected ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                                  child: Text(
                                    ex.muscleGroup.isNotEmpty ? ex.muscleGroup[0].toUpperCase() : "?",
                                    style: TextStyle(
                                      color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(ex.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                      Text(ex.muscleGroup, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(Icons.check_circle, color: colorScheme.primary),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 40),

                // --- KAYDET BUTONU ---
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: _isSaving ? null : _onSavePressed,
                    icon: _isSaving 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.save_outlined),
                    label: Text(_isSaving ? "Saving..." : (isEditing ? 'Update Routine' : 'Create Routine')),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}