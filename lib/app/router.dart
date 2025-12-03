import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fitlife/core/constants.dart';
import 'package:fitlife/features/shell/presentation/shell_page.dart';
import 'package:fitlife/features/home/presentation/home_page.dart';
import 'package:fitlife/features/workouts/presentation/workouts_page.dart';
import 'package:fitlife/features/stats/presentation/stats_page.dart';
import 'package:fitlife/features/workouts/presentation/workout_detail_page.dart';
import 'package:fitlife/features/workouts/presentation/workout_session_logger_page.dart';
import 'package:fitlife/features/workouts/domain/models/workout.dart';
import 'package:fitlife/features/exercise_library/presentation/exercise_library_page.dart';

final _rootKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.home,
    routes: [
      ShellRoute(
        builder: (context, state, child) => ShellPage(child: child),
        routes: [
          GoRoute(
            path: Routes.home,
            name: RouteNames.home,
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: Routes.workouts,
            name: RouteNames.workouts,
            builder: (context, state) => const WorkoutsPage(),
          ),
          GoRoute(
            path: Routes.stats,
            name: RouteNames.stats,
            builder: (context, state) => const StatsPage(),
          ),
          GoRoute(
            path: Routes.workoutDetail,
            name: RouteNames.workoutDetail,
            builder: (context, state) {
              final extra = state.extra;
              if (extra is! Workout) {
                return const Scaffold(
                  body: Center(child: Text('Workout not found')),
                );
              }
              return WorkoutDetailPage(workout: extra);
            },
          ),
          GoRoute(
            path: Routes.workoutSessionLogger,
            name: RouteNames.workoutSessionLogger,
            builder: (context, state) {
              final extra = state.extra;
              final workout = extra is Workout ? extra : null;
              return WorkoutSessionLoggerPage(workout: workout);
            },
          ),
          GoRoute(
            path: Routes.exerciseLibrary,
            name: RouteNames.exerciseLibrary,
            builder: (context, state) => const ExerciseLibraryPage(),
          ),
        ],
      ),
    ],
  );
});
