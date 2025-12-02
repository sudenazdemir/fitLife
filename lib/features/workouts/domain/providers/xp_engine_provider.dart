import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlife/features/workouts/domain/services/xp_engine.dart';

final xpEngineProvider = Provider<XpEngine>((ref) {
  return XpEngine();
});