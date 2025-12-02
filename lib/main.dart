import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:fitlife/app/app.dart';
import 'package:fitlife/features/workouts/domain/models/workout_session.dart';

// main.dart içinde main()’de:
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(WorkoutSessionAdapter());

  // ❗ İSİM BURADA AYNI OLMALI
  await Hive.openBox<WorkoutSession>('workout_sessions_v3');

  runApp(const ProviderScope(child: FitlifeApp()));
}
