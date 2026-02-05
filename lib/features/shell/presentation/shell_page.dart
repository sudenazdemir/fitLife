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

    // 0: Home
    if (loc == Routes.home || loc == '/') return 0;

    // 1: Library
    if (loc.startsWith(Routes.exerciseLibrary)) return 1;

    // 2: Routines
    if (loc.startsWith(Routes.routines)) return 2;

    // 3: Stats
    if (loc.startsWith(Routes.stats)) return 3;

    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(Routes.home);
        break;
      case 1:
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent, // Kaydırınca renk değişmesin
        title: Row(
          mainAxisSize: MainAxisSize.min, // Sola yasla ama gereksiz yer kaplama
          children: [
            // Logo İkonu
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.redAccent.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.monitor_heart, color: Colors.redAccent, size: 24),
            ),
            const SizedBox(width: 12),
            // Marka İsmi
            Text(
              'FitLife',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          // Tema Değiştirme Butonu
          IconButton(
            icon: Icon(
              mode == ThemeMode.dark ? Icons.light_mode_rounded : Icons.dark_mode_outlined,
              color: colorScheme.onSurfaceVariant,
            ),
            tooltip: 'Toggle Theme',
            onPressed: () {
              ref.read(themeModeProvider.notifier).state =
                  mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
          
          // Profil Butonu (Avatar Görünümlü)
          Padding(
            padding: const EdgeInsets.only(right: 12, left: 4),
            child: InkWell(
              onTap: () => context.push(Routes.profile),
              borderRadius: BorderRadius.circular(20),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(Icons.person, size: 20, color: colorScheme.primary),
              ),
            ),
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: colorScheme.primary.withAlpha(25),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.primary);
            }
            return TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colorScheme.onSurfaceVariant);
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return IconThemeData(color: colorScheme.primary);
            }
            return IconThemeData(color: colorScheme.onSurfaceVariant);
          }),
        ),
        child: NavigationBar(
          selectedIndex: selected,
          onDestinationSelected: (i) => _onTap(context, i),
          backgroundColor: colorScheme.surface,
          elevation: 2,
          shadowColor: Colors.black12,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.fitness_center_outlined),
              selectedIcon: Icon(Icons.fitness_center),
              label: 'Library',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: 'Routines',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: 'Stats',
            ),
          ],
        ),
      ),
    );
  }
}