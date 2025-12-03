import 'package:flutter/material.dart';

final class AppConstants {
  static const appName = 'FitLife';

  // Ana renk: gradientteki sarı
  static const brandColor = Color(0xFFF2C24F);

  // İkinci renk: gradientteki mor
  static const accentColor = Color(0xFF5A5CEB);

  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF5A5CEB),
      Color(0xFFF2C24F),
    ],
  );
   static const xpPerMinute = 10;
}


final class Routes {
  static const home = '/';
  static const workouts = '/workouts';
  static const stats = '/stats';
   static const workoutDetail = '/workouts/:id';
  static const workoutSessionLogger = '/workouts/:id/session';
  static const exerciseLibrary = '/exercises';
}

final class RouteNames {
  static const home = 'home';
  static const workouts = 'workouts';
  static const stats = 'stats';
  static const workoutDetail = 'workout-detail';
  static const workoutSessionLogger = 'workout-session-logger';
  static const exerciseLibrary = 'exerciseLibrary';
}

final class WorkoutCategories {
  static const all = 'all'; // özel değer (UI’de All yazacağız)

  static const fullBody = 'Full Body';
  static const upperBody = 'Upper Body';
  static const cardio = 'Cardio';
  static const strength = 'Strength';
  static const mobility = 'Mobility';

  static const values = <String>[
    fullBody,
    upperBody,
    cardio,
    strength,
    mobility,
  ];
}