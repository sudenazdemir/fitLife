// test/widget_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:fitlife/app/app.dart';

void main() {
  testWidgets('App boots and shows Shell', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: FitlifeApp()));
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    // Ana sayfadaki bir metni kontrol etmek istersen:
    // expect(find.textContaining('FitLife'), findsWidgets);
  });
}
