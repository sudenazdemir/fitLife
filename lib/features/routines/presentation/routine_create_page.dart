import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fitlife/core/services/notification_service.dart';
import 'package:fitlife/features/routines/domain/models/routine.dart';
import 'package:fitlife/features/routines/domain/providers/routine_providers.dart';
// Egzersizleri çekmek için gerekli provider:
import 'package:fitlife/features/exercise_library/domain/providers/exercise_providers.dart';

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
  // ARTIK EGZERSİZ ID'LERİNİ TUTUYORUZ
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
      _selectedExerciseIds.addAll(r.exerciseIds); // <--- DEĞİŞTİ
      
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

  String _dayLabel(int day) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return (day >= 1 && day <= 7) ? days[day - 1] : '$day';
  }

  Future<void> _pickTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: _selectedTime ?? now);
    if (picked != null) {
      setState(() => _selectedTime = picked);
    } else {
      if (_selectedTime == null) setState(() => _isReminderEnabled = false);
    }
  }

  Future<void> _onSavePressed() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one day.')));
      return;
    }
    if (_selectedExerciseIds.isEmpty) { // <--- DEĞİŞTİ
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one exercise.')));
      return;
    }
    if (_isReminderEnabled && _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please pick a time for the reminder.')));
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
        exerciseIds: _selectedExerciseIds.toList(), // <--- DEĞİŞTİ
        createdAt: widget.routineToEdit?.createdAt ?? DateTime.now(),
        isReminderEnabled: _isReminderEnabled,
        reminderHour: _selectedTime?.hour,
        reminderMinute: _selectedTime?.minute,
      );

      await repo.saveRoutine(routine);
      await NotificationService().scheduleRoutineNotifications(routine);

      if (!mounted) return;
      context.pop(); // Sayfayı kapat
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ARTIK EXERCISE LIST PROVIDER'I DİNLİYORUZ
    final exercisesAsync = ref.watch(exerciseListProvider);
    final isEditing = widget.routineToEdit != null;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Routine' : 'New Routine')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Routine Name', style: theme.textTheme.titleSmall),
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

              Text('Days', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: List.generate(7, (i) {
                  final day = i + 1;
                  final isSelected = _selectedDays.contains(day);
                  return FilterChip(
                    label: Text(_dayLabel(day)),
                    selected: isSelected,
                    onSelected: (v) => setState(() => v ? _selectedDays.add(day) : _selectedDays.remove(day)),
                  );
                }),
              ),
              const SizedBox(height: 24),

              Text('Reminders', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Enable Reminder'),
                      subtitle: Text(_isReminderEnabled && _selectedTime != null 
                          ? 'Alarm set for ${_selectedTime!.format(context)}' 
                          : 'Get notified on workout days'),
                      value: _isReminderEnabled,
                      onChanged: (val) {
                        setState(() {
                          _isReminderEnabled = val;
                          if (val && _selectedTime == null) _pickTime();
                        });
                      },
                    ),
                    if (_isReminderEnabled)
                      ListTile(
                        leading: const Icon(Icons.access_time),
                        title: const Text('Set Time'),
                        trailing: Chip(
                          label: Text(_selectedTime?.format(context) ?? '--:--'),
                        ),
                        onTap: _pickTime,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- EGZERSİZ SEÇİM LİSTESİ ---
              Text('Select Exercises', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              
              exercisesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Text('Error: $e'),
                data: (exercises) {
                  if (exercises.isEmpty) return const Text("Library is empty.");
                  
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final ex = exercises[index];
                      final isChecked = _selectedExerciseIds.contains(ex.id);
                      return CheckboxListTile(
                        title: Text(ex.name),
                        subtitle: Text(ex.muscleGroup),
                        value: isChecked,
                        onChanged: (v) {
                          setState(() {
                            v == true 
                              ? _selectedExerciseIds.add(ex.id) 
                              : _selectedExerciseIds.remove(ex.id);
                          });
                        },
                      );
                    },
                  );
                },
              ),

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
        ),
      ),
    );
  }
}