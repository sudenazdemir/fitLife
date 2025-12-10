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
    debugPrint('Current location: $loc');

    if (loc == Routes.home || loc == '/') return 0;
    if (loc.startsWith(Routes.workouts)) return 1;
    if (loc.startsWith(Routes.stats)) return 2;

    return 0;
  }

  void _onTap(BuildContext context, int index) {
    debugPrint('Tapped index: $index');

    switch (index) {
      case 0:
        context.go(Routes.home);
        break;
      case 1:
        context.go(Routes.workouts);
        break;
      case 2:
        context.go(Routes.stats);
        break;
      case 3:
        context.go(Routes.routines);
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final selected = _indexFromLocation(context);
    debugPrint('Selected nav index: $selected');

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/icons/fitlife_logo_transperent.png',
              height: 28,
            ),
            const SizedBox(width: 8),
            const Text('FitLife'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              context.push(Routes.profile);
            },
          ),
          IconButton(
            icon: Icon(
              mode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
            ),
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
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Workouts',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month),
            label: 'Routines',
          ),
        ],
      ),
    );
  }
}
