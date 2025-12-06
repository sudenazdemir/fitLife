import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fitlife/core/constants.dart';
import 'package:fitlife/features/workouts/domain/models/workout_session.dart';
import 'package:fitlife/features/workouts/domain/repositories/workout_session_repository.dart';
import 'package:fitlife/features/workouts/domain/providers/xp_engine_provider.dart';

enum _RoutinePhase {
  idle,
  inSet,
  inRest,
  finished,
}

class RoutineExercise {
  final String name;
  final int sets;
  final int workSeconds;
  final int restSeconds;

  const RoutineExercise({
    required this.name,
    required this.sets,
    required this.workSeconds,
    required this.restSeconds,
  });
}

class RoutineRunnerPage extends ConsumerStatefulWidget {
  const RoutineRunnerPage({super.key});

  @override
  ConsumerState<RoutineRunnerPage> createState() => _RoutineRunnerPageState();
}

class _RoutineRunnerPageState extends ConsumerState<RoutineRunnerPage> {
  // Basit, hard-coded bir demo rutin (Routine Creator ayrı issue’da gelecek)
  late final List<RoutineExercise> _routine = [
    const RoutineExercise(
      name: 'Warm-up Jog',
      sets: 1,
      workSeconds: 60,
      restSeconds: 20,
    ),
    const RoutineExercise(
      name: 'Push Ups',
      sets: 3,
      workSeconds: 30,
      restSeconds: 20,
    ),
    const RoutineExercise(
      name: 'Squats',
      sets: 3,
      workSeconds: 30,
      restSeconds: 20,
    ),
  ];

  int _currentExerciseIndex = 0;
  int _currentSetIndex = 0; // 0-based
  int _remainingSeconds = 0;

  _RoutinePhase _phase = _RoutinePhase.idle;
  Timer? _timer;

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }

  RoutineExercise get _currentExercise => _routine[_currentExerciseIndex];

  int get _totalExercises => _routine.length;

  int get _displaySetNumber => _currentSetIndex + 1;

  int get _totalWorkSeconds {
    var total = 0;
    for (final ex in _routine) {
      total += ex.sets * ex.workSeconds;
    }
    return total;
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _startWorkTimer() {
    _cancelTimer();
    final ex = _currentExercise;
    setState(() {
      _phase = _RoutinePhase.inSet;
      _remainingSeconds = ex.workSeconds;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _cancelTimer();
          _onWorkFinished();
        }
      });
    });
  }

  void _startRestTimer() {
    final ex = _currentExercise;
    if (ex.restSeconds <= 0) {
      _goNextExerciseOrSet();
      return;
    }

    _cancelTimer();
    setState(() {
      _phase = _RoutinePhase.inRest;
      _remainingSeconds = ex.restSeconds;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _cancelTimer();
          _goNextExerciseOrSet();
        }
      });
    });
  }

  void _onWorkFinished() {
    // Her set bittikten sonra otomatik dinlenmeye geç
    _startRestTimer();
  }

  void _goNextExerciseOrSet() {
    final ex = _currentExercise;

    // Aynı egzersizde başka set var mı?
    if (_currentSetIndex + 1 < ex.sets) {
      setState(() {
        _currentSetIndex++;
        _phase = _RoutinePhase.idle;
        _remainingSeconds = 0;
      });
      // Kullanıcı tekrar "Start Set" diyecek
      return;
    }

    // Egzersiz bitti, sonraki egzersize geçelim mi?
    if (_currentExerciseIndex + 1 < _routine.length) {
      setState(() {
        _currentExerciseIndex++;
        _currentSetIndex = 0;
        _phase = _RoutinePhase.idle;
        _remainingSeconds = 0;
      });
      return;
    }

    // Rutin tamamen bitti
    setState(() {
      _phase = _RoutinePhase.finished;
      _remainingSeconds = 0;
    });
  }

  Future<void> _onPrimaryButtonPressed() async {
    if (_phase == _RoutinePhase.finished) {
      await _onSaveAndExit();
      return;
    }

    if (_phase == _RoutinePhase.idle) {
      _startWorkTimer();
    }
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  Future<void> _onSaveAndExit() async {
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    final totalSeconds = _totalWorkSeconds;
    final totalMinutes = (totalSeconds / 60).ceil();

    final xpEngine = ref.read(xpEngineProvider);
    final xp = xpEngine.calculateXp(
      durationMinutes: totalMinutes,
      difficulty: 'Routine',
      sets: null,
      reps: null,
    );

    final now = DateTime.now();
    final session = WorkoutSession(
      id: now.millisecondsSinceEpoch.toString(),
      workoutId: 'routine_demo',
      name: 'Guided Routine',
      category: 'Routine',
      durationMinutes: totalMinutes,
      calories: 0,
      date: now,
      xpEarned: xp,
    );

    final repo = WorkoutSessionRepository();

    try {
      await repo.addSession(session);

      messenger.showSnackBar(
        SnackBar(
          content: Text('Routine finished! You earned $xp XP.'),
        ),
      );

      router.go(Routes.stats);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to save routine session: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    final ex = _currentExercise;

   

    String phaseLabel;
   switch (_phase) {
  case _RoutinePhase.inSet:
    phaseLabel = 'Work';
    break;
  case _RoutinePhase.inRest:
    phaseLabel = 'Rest';
    break;
  case _RoutinePhase.finished:
    phaseLabel = 'Done';
    break;
  case _RoutinePhase.idle:
    phaseLabel = 'Ready';
    break;
}


    String buttonLabel;
    if (_phase == _RoutinePhase.finished) {
      buttonLabel = 'Save & Finish';
    } else if (_phase == _RoutinePhase.idle) {
      buttonLabel = _currentExerciseIndex == 0 && _currentSetIndex == 0
          ? 'Start Routine'
          : 'Start Next Set';
    } else {
      buttonLabel = 'Running...';
    }

    final timeText =
        _remainingSeconds > 0 ? _formatTime(_remainingSeconds) : '--:--';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Routine Runner'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Exercise',
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                ex.name,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Exercise ${_currentExerciseIndex + 1} of $_totalExercises',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Set $_displaySetNumber of ${ex.sets}',
                style: textTheme.bodyMedium,
              ),

              const SizedBox(height: 24),

              // Timer kartı
              Expanded(
                child: Center(
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 32,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            phaseLabel,
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            timeText,
                            style: textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _phase == _RoutinePhase.inRest
                                ? 'Rest before the next set'
                                : _phase == _RoutinePhase.inSet
                                    ? 'Keep going!'
                                    : _phase == _RoutinePhase.finished
                                        ? 'Routine complete'
                                        : 'Press start to begin this set.',
                            textAlign: TextAlign.center,
                            style: textTheme.bodyMedium?.copyWith(
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Alt aksiyon butonu
              SafeArea(
                top: false,
                minimum: const EdgeInsets.only(top: 8, bottom: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed:
                        (_phase == _RoutinePhase.idle || _phase == _RoutinePhase.finished)
                            ? _onPrimaryButtonPressed
                            : null,
                    child: Text(buttonLabel),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
