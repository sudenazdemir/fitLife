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
import 'package:fitlife/features/profile/presentation/profile_page.dart';
import 'package:fitlife/features/profile/presentation/onboarding_page.dart';
import 'package:fitlife/features/profile/domain/models/user_profile.dart';
import 'package:fitlife/features/routines/presentation/routine_create_page.dart';

// 🔹 Firebase + yeni ekranlar
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitlife/features/intro/presentation/intro_page.dart';
import 'package:fitlife/features/auth/presentation/auth_page.dart';
import 'package:fitlife/features/routines/presentation/routine_list_page.dart';
import 'package:fitlife/features/routines/presentation/routine_detail_page.dart';
import 'package:fitlife/features/routines/domain/models/routine.dart';
import 'package:fitlife/features/routines/presentation/routine_runner_page.dart';
import 'package:fitlife/features/measurements/presentation/measurements_page.dart';
import 'package:fitlife/features/exercise_library/presentation/exercise_detail_screen.dart';
import 'package:fitlife/features/exercise_library/domain/models/exercise.dart';

final _rootKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.home,

    // 🔹 AUTH REDIRECT
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final isLoggedIn = user != null;

      final loggingIn = state.matchedLocation == Routes.auth;
      final onIntro = state.matchedLocation == Routes.intro;

      // Kullanıcı login değil → intro/auth dışında bir yere gidiyorsa intro’ya at
      if (!isLoggedIn && !loggingIn && !onIntro) {
        return Routes.intro;
      }

      // Kullanıcı login olduysa ve hâlâ intro veya auth’teyse → home’a at
      if (isLoggedIn && (loggingIn || onIntro)) {
        return Routes.home;
      }

      return null; // hiçbir şey değiştirme
    },

    routes: [
      // 🔹 Intro / onboarding slider
      GoRoute(
        path: Routes.intro,
        name: RouteNames.intro,
        builder: (context, state) => const IntroPage(),
      ),

      // 🔹 Auth (login / register)
      GoRoute(
        path: Routes.auth,
        name: RouteNames.auth,
        builder: (context, state) => const AuthPage(),
      ),

      // 🔹 Asıl uygulama shell’i
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
            builder: (context, state) => const ExerciseLibraryScreen(),
          ),
          GoRoute(
            path: Routes.routineRunner,
            name: RouteNames.routineRunner,
            builder: (context, state) {
              final extra = state.extra;
              final routine = extra is Routine ? extra : null;
              return RoutineRunnerPage(routine: routine);
            },
          ),
          GoRoute(
            path: Routes.profile,
            name: RouteNames.profile,
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: Routes.onboarding,
            name: RouteNames.onboarding,
            builder: (context, state) {
              final extra = state.extra;
              return OnboardingPage(
                initialProfile: extra is UserProfile ? extra : null,
              );
            },
          ),
          GoRoute(
            path: Routes.routineCreate, // '/create-routine' gibi bir şeydir
            builder: (context, state) {
              // State.extra'dan rutini alıp sayfaya veriyoruz
              final routineToEdit = state.extra as Routine?;
              return RoutineCreatePage(routineToEdit: routineToEdit);
            },
          ),
          GoRoute(
            path: Routes.routines,
            name: RouteNames.routines,
            builder: (context, state) => const RoutineListPage(),
          ),
          GoRoute(
            path: Routes.routineDetail,
            name: RouteNames.routineDetail,
            builder: (context, state) {
              final extra = state.extra;
              if (extra is! Routine) {
                return const Scaffold(
                  body: Center(child: Text('Routine not found')),
                );
              }
              return RoutineDetailPage(routine: extra);
            },
          ),
          GoRoute(
            path: Routes.measurements,
            builder: (context, state) => const MeasurementsPage(),
          ),
          GoRoute(
            path: Routes.exerciseDetail,
            builder: (context, state) {
              // Listeden gönderdiğimiz 'exercise' objesini burada yakalıyoruz
              final exercise = state.extra as Exercise;
              return ExerciseDetailScreen(exercise: exercise);
            },
          ),
        ],
      ),
    ],
  );
});
