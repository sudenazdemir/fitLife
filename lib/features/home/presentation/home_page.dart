import 'package:flutter/material.dart';
import 'package:fitlife/core/constants.dart';
import 'package:fitlife/features/workouts/domain/models/workout.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    _debugTestWorkout(); // geçici
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF5A5CEB), // mor
            Color(0xFFF2C24F), // sarı
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Burada arka planı ŞEFFAF olan logo kullan:
            Image.asset(
              'assets/icons/fitlife_logo_transperent.png',
              width: 180,
            ),
            const SizedBox(height: 16),
            const Text(
              'Level up your body',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
void _debugTestWorkout() {
  final w = Workout(
    id: 'w1',
    name: 'Test Workout',
    category: WorkoutCategories.fullBody,
    durationMinutes: 30,
    calories: 200,
    date: DateTime.now(),
    title: 'Test Workout Title',
    difficulty: 'Beginner',
    description: 'This is a test workout description.',
  );

  final json = w.toJson();
  debugPrint('Workout JSON: $json');

  final fromJson = Workout.fromJson(json);
  debugPrint('From JSON: $fromJson');
}
