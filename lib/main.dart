import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fitlife/app/app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// --- MEVCUT MODELLERİN ---
import 'package:fitlife/features/workouts/domain/models/workout_session.dart';
import 'package:fitlife/features/profile/domain/models/user_profile.dart';
import 'package:fitlife/features/routines/domain/models/routine.dart';
// --- YENİ EKLEDİĞİMİZ MODELLER ---
// (Dosya yollarının senin projendeki klasör yapısına uygun olduğundan emin ol)
import 'package:fitlife/features/exercise_library/domain/models/exercise.dart';
import 'package:fitlife/features/workouts/domain/models/workout.dart'; // Workout sınıfının olduğu dosya
import 'package:fitlife/features/stats/domain/models/stats_data.dart';
import 'package:fitlife/features/measurements/domain/models/body_measurement.dart';
import 'package:fitlife/core/services/notification_service.dart';
import 'package:fitlife/core/init/data_seeder.dart'; // Yeni oluşturduğun dosya

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();

  // 1. Hive Başlat
  await Hive.initFlutter();

  // 2. Adapter'ları Kaydet
  Hive.registerAdapter(WorkoutSessionAdapter());
  Hive.registerAdapter(UserProfileAdapter());
  Hive.registerAdapter(RoutineAdapter());
  Hive.registerAdapter(ExerciseAdapter());
  Hive.registerAdapter(WorkoutAdapter());
  Hive.registerAdapter(DailyXpAdapter());
  Hive.registerAdapter(StatsDataAdapter());
  Hive.registerAdapter(BodyMeasurementAdapter());

  await NotificationService().init();

  // 3. Kutuları (Boxes) Aç
  await Hive.openBox<WorkoutSession>('workout_sessions_v3');
  await Hive.openBox<UserProfile>('user_profile');
  await Hive.openBox<Routine>('routines');

  // ÖNEMLİ: Seeding yapmadan önce bu kutunun açılmış olması şarttır.
  await Hive.openBox<Exercise>('exercises');
  await Hive.openBox<Workout>('workouts');

  // --- YENİ EKLENEN KISIM: SEEDING ---
  // Kutular açıldıktan sonra seeding'i çalıştırıyoruz.
  //await DataSeeder.seedDefaultExercises();
  await DataSeeder.seedFromApi(); // Yeni kod satırı
  // ------------------------------------
  // Test için geçici satır:
  final box = Hive.box<Exercise>('exercises');
  debugPrint("KUTUDAKİ TOPLAM EGZERSİZ: ${box.length}");
  debugPrint("İLK EGZERSİZ: ${box.values.first.name}");

  runApp(const ProviderScope(child: FitlifeApp()));
}
