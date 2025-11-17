import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:fitlife/app/app.dart';
import 'package:fitlife/features/workouts/domain/models/workout_session.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(WorkoutSessionAdapter());
  await Hive.openBox<WorkoutSession>('workout_sessions');

  runApp(const ProviderScope(child: FitlifeApp()));
}
