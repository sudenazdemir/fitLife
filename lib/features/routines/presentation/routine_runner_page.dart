// lib/features/routines/presentation/routine_runner_page.dart

import 'dart:async';
// DÜZELTME 1: dart:ui import'u kaldırıldı, artık gerekli değil.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Mevcut importların
import 'package:fitlife/core/constants.dart';
import 'package:fitlife/features/workouts/domain/models/workout_session.dart';
import 'package:fitlife/features/workouts/domain/repositories/workout_session_repository.dart';
import 'package:fitlife/features/workouts/domain/providers/xp_engine_provider.dart';
import 'package:fitlife/features/routines/domain/models/routine.dart';

// -----------------------------------------------------------------------------
// 🔹 DATA MODELS (Local State Logic)
// -----------------------------------------------------------------------------

enum ExerciseType { weighted, duration }

class RunnerSet {
  final int index;
  double? weight;
  int? reps;
  int? durationSeconds;
  bool isCompleted;

  RunnerSet({
    required this.index,
    this.weight,
    this.reps,
    this.durationSeconds,
    this.isCompleted = false,
  });
}

class RunnerExercise {
  final String id;
  final String name;
  final ExerciseType type;
  final int targetRestSeconds;
  final List<RunnerSet> sets;

  RunnerExercise({
    required this.id,
    required this.name,
    required this.type,
    required this.targetRestSeconds,
    required this.sets,
  });

  double get totalVolume => sets
      .where((s) => s.isCompleted && s.weight != null && s.reps != null)
      .fold(0, (sum, s) => sum + (s.weight! * s.reps!));
}

// -----------------------------------------------------------------------------
// 🔹 MAIN PAGE
// -----------------------------------------------------------------------------

class RoutineRunnerPage extends ConsumerStatefulWidget {
  final Routine? routine;

  const RoutineRunnerPage({super.key, this.routine});

  @override
  ConsumerState<RoutineRunnerPage> createState() => _RoutineRunnerPageState();
}

class _RoutineRunnerPageState extends ConsumerState<RoutineRunnerPage> {
  final Stopwatch _globalStopwatch = Stopwatch();
  Timer? _globalTimerTicker;
  String _globalFormattedTime = "00:00";

  late List<RunnerExercise> _exercises;
  
  Timer? _restTimer;
  int _restRemaining = 0;
  bool _isResting = false;

  @override
  void initState() {
    super.initState();
    _initData();
    _startGlobalTimer();
  }

  void _initData() {
    _exercises = [
      RunnerExercise(
        id: '1',
        name: 'Warm-up Jog',
        type: ExerciseType.duration,
        targetRestSeconds: 0,
        sets: [
          RunnerSet(index: 0, durationSeconds: 60),
        ],
      ),
      RunnerExercise(
        id: '2',
        name: 'Push Ups',
        type: ExerciseType.weighted,
        targetRestSeconds: 30,
        sets: List.generate(3, (i) => RunnerSet(index: i)),
      ),
      RunnerExercise(
        id: '3',
        name: 'Squats',
        type: ExerciseType.weighted,
        targetRestSeconds: 45,
        sets: List.generate(3, (i) => RunnerSet(index: i)),
      ),
    ];
  }

  void _startGlobalTimer() {
    _globalStopwatch.start();
    _globalTimerTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final elapsed = _globalStopwatch.elapsed;
      final m = elapsed.inMinutes.toString().padLeft(2, '0');
      final s = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
      setState(() {
        _globalFormattedTime = "$m:$s";
      });
    });
  }

  @override
  void dispose() {
    _globalTimerTicker?.cancel();
    _globalStopwatch.stop();
    _restTimer?.cancel();
    super.dispose();
  }

  int get _totalSetsCompleted {
    return _exercises.fold(0, (sum, ex) => sum + ex.sets.where((s) => s.isCompleted).length);
  }

  double get _totalVolume {
    return _exercises.fold(0, (sum, ex) => sum + ex.totalVolume);
  }

  void _toggleSetCompletion(RunnerExercise exercise, RunnerSet set, bool? value) {
    setState(() {
      set.isCompleted = value ?? false;
    });

    if (set.isCompleted && exercise.targetRestSeconds > 0) {
      _startRest(exercise.targetRestSeconds);
    }
  }

  void _startRest(int seconds) {
    _restTimer?.cancel();
    setState(() {
      _isResting = true;
      _restRemaining = seconds;
    });

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_restRemaining > 0) {
          _restRemaining--;
        } else {
          _skipRest();
        }
      });
    });
  }

  void _skipRest() {
    _restTimer?.cancel();
    setState(() {
      _isResting = false;
    });
  }

  Future<void> _finishWorkout() async {
    _globalStopwatch.stop();
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    
    final totalMinutes = _globalStopwatch.elapsed.inMinutes;
    final xpEngine = ref.read(xpEngineProvider);
    final xp = xpEngine.calculateXp(
      durationMinutes: totalMinutes == 0 ? 1 : totalMinutes,
      difficulty: 'Routine',
      sets: _totalSetsCompleted,
      reps: null,
    );

    final session = WorkoutSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      workoutId: 'routine_runner',
      name: 'Completed Routine',
      category: 'Routine',
      durationMinutes: totalMinutes,
      calories: 0,
      date: DateTime.now(),
      xpEarned: xp,
    );

    try {
      final repo = WorkoutSessionRepository();
      await repo.addSession(session);
      
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Awesome! Earned $xp XP')));
      
      if (router.canPop()) {
        router.pop();
      } else {
        router.go(Routes.stats); 
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      resizeToAvoidBottomInset: true, 
      appBar: AppBar(
        title: const Text('Routine Runner'),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer, size: 16),
                const SizedBox(width: 6),
                Text(
                  _globalFormattedTime,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      body: Column(
        children: [
          _buildStatsHeader(theme),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: _exercises.length,
              separatorBuilder: (c, i) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final exercise = _exercises[index];
                return _ExerciseCard(
                  exercise: exercise,
                  onSetChanged: (set, val) => _toggleSetCompletion(exercise, set, val),
                );
              },
            ),
          ),
        ],
      ),
      bottomSheet: _isResting 
        ? _buildRestOverlay(theme)
        : Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              // DÜZELTME 2 & 3: const eklendi
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _finishWorkout,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('FINISH WORKOUT'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildStatsHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, 
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(theme, 'Sets', '$_totalSetsCompleted'),
          _buildStatItem(theme, 'Volume', '${_totalVolume.toInt()} kg'),
        ],
      ),
    );
  }

  Widget _buildStatItem(ThemeData theme, String label, String value) {
    return Column(
      children: [
        Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
        Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildRestOverlay(ThemeData theme) {
    return Container(
      color: theme.colorScheme.inverseSurface,
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Resting...', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onInverseSurface)),
            const SizedBox(height: 8),
            Text(
              "00:${_restRemaining.toString().padLeft(2, '0')}",
              style: theme.textTheme.displayMedium?.copyWith(
                color: theme.colorScheme.tertiary, 
                fontWeight: FontWeight.bold,
                fontFeatures: [const FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _skipRest,
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.onInverseSurface,
                side: BorderSide(color: theme.colorScheme.onInverseSurface),
              ),
              child: const Text('SKIP REST'),
            )
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 🔹 SUB-WIDGETS
// -----------------------------------------------------------------------------

class _ExerciseCard extends StatelessWidget {
  final RunnerExercise exercise;
  final Function(RunnerSet, bool?) onSetChanged;

  const _ExerciseCard({
    required this.exercise,
    required this.onSetChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  exercise.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Icon(
                  exercise.type == ExerciseType.duration ? Icons.timer_outlined : Icons.fitness_center,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (exercise.type == ExerciseType.weighted)
              const Padding(
                padding: EdgeInsets.only(bottom: 8, right: 40), 
                // DÜZELTME 4 & 5: const eklendi
                child: Row(
                  children: [
                    SizedBox(width: 30, child: Text('Set', textAlign: TextAlign.center)),
                    Expanded(child: Text('kg', textAlign: TextAlign.center)),
                    Expanded(child: Text('Reps', textAlign: TextAlign.center)),
                  ],
                ),
              ),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: exercise.sets.length,
              separatorBuilder: (c, i) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final set = exercise.sets[index];
                if (exercise.type == ExerciseType.duration) {
                  return _DurationSetRow(set: set, onCompleted: (val) => onSetChanged(set, val));
                } else {
                  return _WeightedSetRow(set: set, onCompleted: (val) => onSetChanged(set, val));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _WeightedSetRow extends StatefulWidget {
  final RunnerSet set;
  final ValueChanged<bool?> onCompleted;

  const _WeightedSetRow({required this.set, required this.onCompleted});

  @override
  State<_WeightedSetRow> createState() => _WeightedSetRowState();
}

class _WeightedSetRowState extends State<_WeightedSetRow> {
  late TextEditingController _kgController;
  late TextEditingController _repsController;

  @override
  void initState() {
    super.initState();
    _kgController = TextEditingController(text: widget.set.weight?.toString() ?? '');
    _repsController = TextEditingController(text: widget.set.reps?.toString() ?? '');
  }

  @override
  void dispose() {
    _kgController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  void _updateModel() {
    final weight = double.tryParse(_kgController.text);
    final reps = int.tryParse(_repsController.text);
    widget.set.weight = weight;
    widget.set.reps = reps;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDone = widget.set.isCompleted;

    // DÜZELTME 6 & 7: withOpacity -> withValues, surfaceVariant -> surfaceContainerHighest
    final bgColor = isDone 
      ? colorScheme.primaryContainer.withValues(alpha: 0.3) 
      : colorScheme.surfaceContainerHighest;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        children: [
          SizedBox(
            width: 30, 
            child: Text(
              '${widget.set.index + 1}', 
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, color: isDone ? colorScheme.primary : null),
            )
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              height: 40,
              child: TextField(
                controller: _kgController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                enabled: !isDone,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(bottom: 8),
                  hintText: '-',
                  border: InputBorder.none,
                ),
                onChanged: (_) => _updateModel(),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              height: 40,
              child: TextField(
                controller: _repsController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                enabled: !isDone,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(bottom: 8),
                  hintText: '-',
                  border: InputBorder.none,
                ),
                 onChanged: (_) => _updateModel(),
              ),
            ),
          ),
          Checkbox(
            value: isDone,
            activeColor: colorScheme.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onChanged: (val) {
              _updateModel();
              widget.onCompleted(val);
            },
          ),
        ],
      ),
    );
  }
}

class _DurationSetRow extends StatefulWidget {
  final RunnerSet set;
  final ValueChanged<bool?> onCompleted;

  const _DurationSetRow({required this.set, required this.onCompleted});

  @override
  State<_DurationSetRow> createState() => _DurationSetRowState();
}

class _DurationSetRowState extends State<_DurationSetRow> {
  Timer? _timer;
  late int _remaining;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _remaining = widget.set.durationSeconds ?? 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) return;
        setState(() {
          if (_remaining > 0) {
            _remaining--;
          } else {
            _timer?.cancel();
            _isRunning = false;
            widget.onCompleted(true);
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDone = widget.set.isCompleted;

    // DÜZELTME 8 & 9: withOpacity -> withValues, surfaceVariant -> surfaceContainerHighest
    final bgColor = isDone 
      ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3) 
      : theme.colorScheme.surfaceContainerHighest;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Set ${widget.set.index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
          
          FilledButton.icon(
            onPressed: isDone ? null : _toggleTimer,
            icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
            label: Text(
              '${(_remaining ~/ 60).toString().padLeft(2, '0')}:${(_remaining % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: _isRunning ? theme.colorScheme.error : theme.colorScheme.primary,
            ),
          ),

          Checkbox(
            value: isDone,
            onChanged: widget.onCompleted,
          )
        ],
      ),
    );
  }
}