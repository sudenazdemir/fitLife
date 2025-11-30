import 'package:flutter/material.dart';
import 'package:fitlife/features/workouts/domain/models/workout.dart';

class WorkoutSessionLoggerPage extends StatelessWidget {
  final Workout? workout;

  const WorkoutSessionLoggerPage({
    super.key,
    this.workout,
  });

  @override
  Widget build(BuildContext context) {
    final title = workout?.title ?? 'Workout Session';

    return Scaffold(
      appBar: AppBar(
        title: Text('Session • $title'),
      ),
      body: const Center(
        child: Text(
          'Workout Session Logger (MVP coming in Issue #12)',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
