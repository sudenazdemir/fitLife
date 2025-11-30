import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fitlife/features/workouts/domain/models/workout.dart';
import 'package:fitlife/features/workouts/domain/models/workout_session.dart';
import 'package:fitlife/features/workouts/domain/providers/workout_session_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:fitlife/core/constants.dart';

class WorkoutSessionLoggerPage extends ConsumerStatefulWidget {
  final Workout? workout;

  const WorkoutSessionLoggerPage({
    super.key,
    this.workout,
  });

  @override
  ConsumerState<WorkoutSessionLoggerPage> createState() =>
      _WorkoutSessionLoggerPageState();
}

class _WorkoutSessionLoggerPageState
    extends ConsumerState<WorkoutSessionLoggerPage> {
  final _formKey = GlobalKey<FormState>();

  final _durationController = TextEditingController();
  final _setsController = TextEditingController();
  final _repsController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _durationController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workout = widget.workout;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    final title = workout?.title ?? 'Workout Session';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('Session • $title'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Log your session',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter either duration or sets & reps for this workout.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 24),

                // Duration field
                Text(
                  'Duration (minutes)',
                  style: textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'e.g. 30',
                    prefixIcon: Icon(Icons.timer_outlined),
                  ),
                ),
                const SizedBox(height: 24),

                // Sets / reps row
                Text(
                  'Sets & Reps (optional)',
                  style: textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _setsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Sets',
                          hintText: 'e.g. 4',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _repsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Reps',
                          hintText: 'e.g. 10',
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                SafeArea(
                  top: false,
                  minimum: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isSaving ? null : _onFinishPressed,
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Finish Workout'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onFinishPressed() async {
    // ---- async ÖNCESİ: context'e bağlı her şeyi burada alıyoruz ----
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    final durationMinutes = int.tryParse(_durationController.text.trim());
    final sets = int.tryParse(_setsController.text.trim());
    final reps = int.tryParse(_repsController.text.trim());

    final hasDuration = durationMinutes != null && durationMinutes > 0;
    final hasRepsInfo =
        (sets != null && sets > 0) && (reps != null && reps > 0);

    if (!hasDuration && !hasRepsInfo) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Please enter duration or sets & reps.'),
        ),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isSaving = true);

    // XP hesabı (senin acceptance criteria’sı için önemli)
    final xp = _calculateXp(
      durationMinutes: durationMinutes,
      sets: sets,
      reps: reps,
    );

    // XP bilgisini kullanıcıya hemen gösteriyoruz (async öncesi)
    messenger.showSnackBar(
      SnackBar(
        content: Text('You earned $xp XP for this session!'),
      ),
    );

    final workout = widget.workout;
    final now = DateTime.now();

    final session = WorkoutSession(
      id: now.millisecondsSinceEpoch.toString(),
      workoutId: workout?.id ?? 'unknown',
      name: workout?.title ?? workout?.name ?? 'Workout',
      category: workout?.category ?? 'General',
      durationMinutes: durationMinutes ?? 0,
      calories: workout?.calories ?? 0,
      date: now,
    );

    final repo = ref.read(workoutSessionRepositoryProvider);

    try {
      // ---- ASYNC GAP: burada context kullanmıyoruz ----
      await repo.addSession(session);

      // Kaydettikten sonra Workouts ekranına dön
      router.goNamed(RouteNames.workouts);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to save session: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  int _calculateXp({
    int? durationMinutes,
    int? sets,
    int? reps,
  }) {
    int xp = 0;

    if (durationMinutes != null && durationMinutes > 0) {
      xp += durationMinutes * 5; // dakika başına 5 XP
    }

    if (sets != null && sets > 0 && reps != null && reps > 0) {
      xp += sets * reps; // her rep için 1 XP
    }

    if (xp == 0) {
      xp = 10; // minimum XP
    }

    return xp;
  }
}
