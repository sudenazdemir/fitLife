import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fitlife/core/theme_provider.dart';
import 'package:fitlife/core/constants.dart';

class ShellPage extends ConsumerWidget {
  final Widget child;

  const ShellPage({
    super.key,
    required this.child,
  });

  int _indexFromLocation(BuildContext context) {
    final state = GoRouterState.of(context);
    final loc = state.uri.toString();
    // debugPrint('Current location: $loc');

    // 0: Home
    if (loc == Routes.home || loc == '/') return 0;

    // 1: Library (Eski Workouts yerine Egzersiz Kütüphanesi)
    if (loc.startsWith(Routes.exerciseLibrary)) return 1;

    // 2: Routines (Rutin Planları)
    if (loc.startsWith(Routes.routines)) return 2;

    // 3: Stats (İstatistikler)
    if (loc.startsWith(Routes.stats)) return 3;

    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(Routes.home);
        break;
      case 1:
        // ARTIK 'Workouts' DEĞİL, 'Library' EKRANINA GİDİYORUZ
        context.go(Routes.exerciseLibrary);
        break;
      case 2:
        context.go(Routes.routines);
        break;
      case 3:
        context.go(Routes.stats);
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final selected = _indexFromLocation(context);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.monitor_heart, color: Colors.redAccent),

            // 👇 BURAYI DÜZELT:
            SizedBox(width: 8),

            Text('FitLife'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push(Routes.profile),
          ),
          IconButton(
            icon: Icon(
                mode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
            onPressed: () {
              ref.read(themeModeProvider.notifier).state =
                  mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected,
        onDestinationSelected: (i) => _onTap(context, i),
        destinations: const [
          // 0. HOME
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),

          // 1. EXERCISES (LIBRARY) - DEĞİŞTİ
          NavigationDestination(
            icon: Icon(
                Icons.fitness_center_outlined), // Dambıl ikonu buraya yakışır
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Exercises', // Kullanıcı burada egzersiz listesini görecek
          ),

          // 2. ROUTINES
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Routines',
          ),

          // 3. STATS
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
        ],
      ),
    );
  }
}
