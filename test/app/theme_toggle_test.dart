import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitlife/app/app.dart';

void main() {
  testWidgets('Theme toggle switches between light and dark mode',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: FitlifeApp()),
    );

    // Initially: light mode button should be visible
    expect(find.byIcon(Icons.light_mode), findsOneWidget);

    // Tap toggle
    await tester.tap(find.byIcon(Icons.light_mode));
    await tester.pumpAndSettle();

    // Now dark mode button should be visible
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);
  });
}
