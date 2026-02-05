import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fitlife/app/app.dart';

// Modeller
import 'package:fitlife/features/workouts/domain/models/workout_session.dart';
import 'package:fitlife/features/profile/domain/models/user_profile.dart';
import 'package:fitlife/features/routines/domain/models/routine.dart';
import 'package:fitlife/features/exercise_library/domain/models/exercise.dart';
import 'package:fitlife/features/stats/domain/models/stats_data.dart';
import 'package:fitlife/features/measurements/domain/models/body_measurement.dart';
import 'package:fitlife/core/init/data_seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  // 1. Firebase Başlat
  await Firebase.initializeApp();

  // 2. Hive Başlat
  await Hive.initFlutter();

  // 3. Adapter'ları Kaydet
  Hive.registerAdapter(WorkoutSessionAdapter());
  Hive.registerAdapter(UserProfileAdapter());
  Hive.registerAdapter(RoutineAdapter());
  Hive.registerAdapter(ExerciseAdapter());
  Hive.registerAdapter(DailyXpAdapter());
  Hive.registerAdapter(StatsDataAdapter());
  Hive.registerAdapter(BodyMeasurementAdapter());

  // 4. SADECE Statik Veri Kutularını Aç (Egzersizler Hive'da kalıyor)
  await Hive.openBox<Exercise>('exercises');

  // NOT: 'user_profile', 'routines', 'measurements' kutularını açmıyoruz.
  // Çünkü bu veriler artık Firebase'den gelecek.

  // 5. Seeding (Egzersizleri Hive'a doldur)
  // await DataSeeder.seedDefaultExercises(); // İstersen bunu kullan
  await DataSeeder.seedFromApi(); 

  runApp(const ProviderScope(child: FitlifeApp()));
}