import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlife/app/app.dart';

void main() {
  testWidgets('Initial route loads HomePage', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: FitlifeApp()),
    );

    // HomePage'deki "Home" yazısını veya widget'ını bulalım
    expect(find.text('Home'), findsWidgets);
  });
}
