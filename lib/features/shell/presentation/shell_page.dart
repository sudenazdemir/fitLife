import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fitlife/core/theme_provider.dart';
import 'package:fitlife/core/constants.dart';

class ShellPage extends ConsumerWidget {
  final Widget child;
  final String location; // 👈 Router'dan gelen geçerli konum

  const ShellPage({
    super.key,
    required this.child,
    required this.location,
  });

  int _indexFromLocation() {
    if (location.startsWith(Routes.workouts)) return 1;
    return 0; // default: home
  }

  void _onTap(BuildContext context, int i) {
    switch (i) {
      case 0:
        context.go(Routes.home);
        break;
      case 1:
        context.go(Routes.workouts);
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FitLife'),
        actions: [
          IconButton(
            icon: Icon(mode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
            onPressed: () {
              ref.read(themeModeProvider.notifier).state =
                  mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indexFromLocation(),
        onDestinationSelected: (i) => _onTap(context, i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.fitness_center_outlined), label: 'Workouts'),
        ],
      ),
    );
  }
}
