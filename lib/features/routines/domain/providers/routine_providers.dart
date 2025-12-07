import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlife/features/routines/domain/models/routine.dart';
import 'package:fitlife/features/routines/domain/repositories/routine_repository.dart';

final routineRepositoryProvider = Provider<RoutineRepository>((ref) {
  return RoutineRepository();
});

final routinesProvider = FutureProvider<List<Routine>>((ref) async {
  final repo = ref.read(routineRepositoryProvider);
  return repo.getAllRoutines();
});
