// lib/app/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ⬇️ Router provider’ı paket importuyla çağır
import 'package:fitlife/app/router.dart';
import 'package:fitlife/core/theme_provider.dart';

class FitlifeApp extends ConsumerWidget {
  const FitlifeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ⬇️ GoRouter instance’ını provider’dan al
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'FitLife',
      routerConfig: router,          // ⬅️ artık tanımlı
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: const Color.fromARGB(255, 148, 11, 148),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color.fromARGB(255, 110, 64, 20)
      ),
      themeMode: themeMode,
    );
  }
}
