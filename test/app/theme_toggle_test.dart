// test/app/theme_toggle_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitlife/core/theme_provider.dart';

void main() {
  test('themeModeProvider toggles between light and dark', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // initial value
    final initial = container.read(themeModeProvider);
    expect(initial, isA<ThemeMode>());

    // toggle once
    container.read(themeModeProvider.notifier).state =
        initial == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;

    final afterToggle = container.read(themeModeProvider);
    expect(afterToggle, isA<ThemeMode>());
    expect(afterToggle == initial, isFalse);
  });
}
