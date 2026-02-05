import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:fitlife/core/constants.dart';
import 'package:fitlife/features/workouts/domain/models/workout_session.dart';
import 'package:fitlife/features/workouts/domain/repositories/workout_session_repository.dart';
import 'package:fitlife/features/workouts/domain/providers/xp_engine_provider.dart';
import 'package:fitlife/features/routines/domain/models/routine.dart';
import 'package:fitlife/features/exercise_library/domain/models/exercise.dart';
import 'package:fitlife/features/auth/domain/user_provider.dart';

// --- DATA MODELS ---
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
  final String muscleGroup; // Eklendi: Görsellik için
  final ExerciseType type;
  final int targetRestSeconds;
  final List<RunnerSet> sets;

  RunnerExercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.type,
    required this.targetRestSeconds,
    required this.sets,
  });

  double get totalVolume => sets
      .where((s) => s.isCompleted && s.weight != null && s.reps != null)
      .fold(0, (sum, s) => sum + (s.weight! * s.reps!));
}

// --- PAGE ---
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
  
  Timer? _restTimer;
  int _restRemaining = 0;
  bool _isResting = false;

  List<RunnerExercise> _exercises = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _startGlobalTimer();
    _loadExercises();
  }

  void _loadExercises() {
    if (widget.routine == null || widget.routine!.exerciseIds.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    final exerciseBox = Hive.box<Exercise>('exercises');
    final List<RunnerExercise> loaded = [];

    for (String id in widget.routine!.exerciseIds) {
      try {
        // Egzersizi Hive'dan buluyoruz
        final exercise = exerciseBox.values.firstWhere(
          (e) => e.id == id,
          orElse: () => Exercise(
            id: id, 
            name: 'Unknown Exercise', 
            muscleGroup: 'General', 
            description: '',
            equipment: '',
            difficulty: '',

          ),
        );

        loaded.add(RunnerExercise(
          id: exercise.id,
          name: exercise.name,
          muscleGroup: exercise.muscleGroup, // Yeni alan
          type: ExerciseType.weighted, // Varsayılan tip
          targetRestSeconds: 60, // Varsayılan dinlenme
          sets: List.generate(3, (i) => RunnerSet(index: i)),
        ));
      } catch (e) {
        debugPrint("Egzersiz yüklenirken hata (ID: $id): $e");
      }
    }

    setState(() {
      _exercises = loaded;
      _isLoading = false;
    });
  }

  void _startGlobalTimer() {
    _globalStopwatch.start();
    _globalTimerTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final elapsed = _globalStopwatch.elapsed;
      setState(() {
        _globalFormattedTime =
            "${elapsed.inMinutes.toString().padLeft(2, '0')}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}";
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

  int get _totalSetsCompleted => _exercises.fold(
      0, (sum, ex) => sum + ex.sets.where((s) => s.isCompleted).length);
  
  double get _totalVolume =>
      _exercises.fold(0, (sum, ex) => sum + ex.totalVolume);

  void _toggleSetCompletion(
      RunnerExercise exercise, RunnerSet set, bool? value) {
    setState(() => set.isCompleted = value ?? false);
    
    // Set tamamlandıysa ve dinlenme süresi varsa sayacı başlat
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
    _restTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_restRemaining > 0){
          _restRemaining--;
         } else {
          _skipRest();
        }
      });
    });
  }

  void _skipRest() {
    _restTimer?.cancel();
    setState(() => _isResting = false);
  }

  Future<void> _finishWorkout() async {
    _globalStopwatch.stop();
    final router = GoRouter.of(context);
    final totalMinutes = _globalStopwatch.elapsed.inMinutes;

    // 1. XP Hesapla (XpEngine kullanarak)
    final xp = ref.read(xpEngineProvider).calculateXp(
      durationMinutes: totalMinutes == 0 ? 1 : totalMinutes, 
      difficulty: 'Routine', // Rutin olduğu için bonus alır
      sets: _totalSetsCompleted,
    );

    // 2. Session Oluştur (Geçmiş listesi için)
    final session = WorkoutSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      workoutId: widget.routine?.id ?? 'quick_start',
      name: widget.routine?.name ?? 'Quick Workout',
      category: 'Routine',
      durationMinutes: totalMinutes,
      calories: (totalMinutes * 5), // Basit kalori hesabı
      date: DateTime.now(),
      xpEarned: xp,
    );

    try {
      // 3. Geçmişe Kaydet (Grafikler için)
      await WorkoutSessionRepository().addSession(session);

      // 4. 🔥 KULLANICI XP'SİNİ GÜNCELLE (Stats ve Profil için KRİTİK ADIM) 🔥
      // Bu satır olmazsa Level ve Total XP artmaz!
      await ref.read(userProvider.notifier).addXp(xp);

      // 5. İstatistikleri Yenile (Gerekirse)
      // statsProvider genellikle userProvider'ı dinlediği için otomatik güncellenir.
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Awesome! Earned $xp XP 🔥'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          )
        );

        if (router.canPop()) {
          router.pop();
        } else {
          router.go(Routes.stats);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving workout: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_exercises.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Routine Runner')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_amber_rounded, size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              const Text("No exercises found in this routine."),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(widget.routine?.name ?? 'Routine Runner'),
        centerTitle: false,
        actions: [
          // Timer Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colorScheme.primary.withAlpha(51)),
            ),
            child: Row(
              children: [
                Icon(Icons.timer_outlined, size: 18, color: colorScheme.onPrimaryContainer),
                const SizedBox(width: 8),
                Text(
                  _globalFormattedTime,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                    fontFamily: 'monospace'
                  ),
                )
              ],
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // İstatistik Başlığı
          _buildStatsHeader(theme),
          
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // Alt kısımda butona yer bırak
              itemCount: _exercises.length,
              separatorBuilder: (c, i) => const SizedBox(height: 20),
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
      // Dinlenme Modu veya Bitir Butonu
      bottomSheet: _isResting
          ? _buildRestOverlay(theme)
          : Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: _finishWorkout,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('FINISH WORKOUT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildStatsHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor.withAlpha(128))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(theme, '$_totalSetsCompleted', 'Sets Completed'),
          Container(width: 1, height: 30, color: theme.dividerColor),
          _buildStatItem(theme, '${_totalVolume.toInt()} kg', 'Total Volume'),
        ],
      ),
    );
  }

  Widget _buildStatItem(ThemeData theme, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildRestOverlay(ThemeData theme) {
    return Container(
      color: const Color(0xFF1A1A1A), // Koyu tema dinlenme modu
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Rest & Recover',
              style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            Text(
              "00:${_restRemaining.toString().padLeft(2, '0')}",
              style: theme.textTheme.displayLarge?.copyWith(
                color: const Color(0xFFF2C24F), // Sarı vurgu
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace'
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _skipRest,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white30),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('SKIP REST'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 🔹 ALT BİLEŞENLER (SUB-WIDGETS)
// -----------------------------------------------------------------------------

class _ExerciseCard extends StatelessWidget {
  final RunnerExercise exercise;
  final Function(RunnerSet, bool?) onSetChanged;

  const _ExerciseCard({required this.exercise, required this.onSetChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withAlpha(25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.outlineVariant.withAlpha(25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Egzersiz Başlığı ve Kas Grubu
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    exercise.muscleGroup.isNotEmpty ? exercise.muscleGroup[0].toUpperCase() : 'E',
                    style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        exercise.muscleGroup,
                        style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {}, // Gelecekte info modalı açılabilir
                  icon: Icon(Icons.info_outline, color: colorScheme.onSurfaceVariant, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Başlıklar (Set, kg, Reps)
            if (exercise.type == ExerciseType.weighted)
              Padding(
                padding: const EdgeInsets.only(bottom: 8, right: 40),
                child: Row(
                  children: [
                    const SizedBox(width: 40, child: Text('SET', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                    Expanded(child: Text('KG', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colorScheme.primary))),
                    Expanded(child: Text('REPS', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colorScheme.primary))),
                  ],
                ),
              ),

            // Set Listesi
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDone = widget.set.isCompleted;

    // Tamamlanmışsa yeşilimsi, değilse gri
    final bgColor = isDone
        ? const Color(0xFF4CAF50).withAlpha(25) 
        : colorScheme.surface;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: isDone ? Border.all(color: Colors.green.withAlpha(25)) : null,
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        children: [
          // Set Numarası
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isDone ? Colors.green : colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${widget.set.index + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDone ? Colors.white : colorScheme.onSurface,
                ),
              ),
            ),
          ),
          
          // KG Input
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _kgController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                enabled: !isDone,
                style: const TextStyle(fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(bottom: 8), // Metni ortalar
                  hintText: '-',
                  border: InputBorder.none,
                ),
                onChanged: (_) => _updateModel(),
              ),
            ),
          ),

          // Reps Input
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _repsController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                enabled: !isDone,
                style: const TextStyle(fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(bottom: 8),
                  hintText: '-',
                  border: InputBorder.none,
                ),
                onChanged: (_) => _updateModel(),
              ),
            ),
          ),

          // Checkbox
          Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: isDone,
              activeColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              onChanged: (val) {
                // Focus'u kaldır ki klavye kapansın
                FocusScope.of(context).unfocus();
                _updateModel();
                widget.onCompleted(val);
              },
            ),
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

    return Container(
      decoration: BoxDecoration(
        color: isDone ? Colors.green.withAlpha(25) : theme.colorScheme.surfaceContainerHighest.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Set ${widget.set.index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
          
          FilledButton.icon(
            onPressed: isDone ? null : _toggleTimer,
            icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
            label: Text(
              '${(_remaining ~/ 60).toString().padLeft(2, '0')}:${(_remaining % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: _isRunning ? theme.colorScheme.error : theme.colorScheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),

          Checkbox(
            value: isDone,
            activeColor: Colors.green,
            onChanged: widget.onCompleted,
          )
        ],
      ),
    );
  }
}