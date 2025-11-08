import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fitlife/core/constants.dart';
import 'package:fitlife/features/shell/presentation/shell_page.dart';
import 'package:fitlife/features/home/presentation/home_page.dart';
import 'package:fitlife/features/workouts/presentation/workouts_page.dart';

final _rootKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.home,
    routes: [
      ShellRoute(
        // 👇 state.uri.toString() ile geçerli konumu ShellPage'e veriyoruz
        builder: (context, state, child) =>
            ShellPage(location: state.uri.toString(), child: child),
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
        ],
      ),
    ],
  );
});
