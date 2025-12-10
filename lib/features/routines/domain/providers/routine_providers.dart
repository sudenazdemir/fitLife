import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlife/features/routines/domain/models/routine.dart';
import 'package:fitlife/features/routines/domain/repositories/routine_repository.dart';

final routineRepositoryProvider = Provider((ref) => RoutineRepository());

final routinesFutureProvider = FutureProvider<List<Routine>>((ref) async {
  final repo = ref.watch(routineRepositoryProvider);
  return repo.getAllRoutines();
});