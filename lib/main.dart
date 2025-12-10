import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:fitlife/app/app.dart';

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


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // 1. Hive Başlat
  await Hive.initFlutter();

  // 2. Adapter'ları Kaydet (Sıra önemli değil ama typeId çakışmamalı)
  // Mevcutlar:
  Hive.registerAdapter(WorkoutSessionAdapter()); // Muhtemelen TypeId: 0
  Hive.registerAdapter(UserProfileAdapter());    // TypeId: 2
  Hive.registerAdapter(RoutineAdapter());        // TypeId: 1
  
  // Yeni Eklediklerimiz:
  Hive.registerAdapter(ExerciseAdapter());       // TypeId: 4
  Hive.registerAdapter(WorkoutAdapter());        // TypeId: 5
  Hive.registerAdapter(DailyXpAdapter());        // TypeId: 6
  Hive.registerAdapter(StatsDataAdapter());      // TypeId: 7
  Hive.registerAdapter(BodyMeasurementAdapter()); // TypeId: 3
// main.dart içinde adapter kayıtlarından sonra:
await Hive.deleteBoxFromDisk('routines'); // ⚠️ Sadece bir kereliğine bozuk veriyi silmek için
  // 3. Kutuları (Boxes) Aç
  // Kullanıcı verileri:
  await Hive.openBox<WorkoutSession>('workout_sessions_v3');
  await Hive.openBox<UserProfile>('user_profile');
  await Hive.openBox<Routine>('routines');

  // Kütüphane verileri (Egzersiz ve Hazır Antrenman listesi):
  await Hive.openBox<Exercise>('exercises');
  await Hive.openBox<Workout>('workouts');

  // Not: 'StatsData' için genellikle bir kutu açmana gerek yoktur, 
  // çünkü o anlık hesaplanıp gösterilen bir veridir. 
  // Ancak Adapter'ını yukarıda kaydettik ki hata almayalım.

  runApp(const ProviderScope(child: FitlifeApp()));
}