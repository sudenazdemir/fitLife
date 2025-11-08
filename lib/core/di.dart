import 'package:flutter_riverpod/flutter_riverpod.dart';

final diProvider = Provider<DiContainer>((ref) {
  return DiContainer(ref);
});

class DiContainer {
  final Ref ref;
  DiContainer(this.ref);

  // Örnek: future repo/provider kayıtları
  // final authRepo = Provider<AuthRepository>((_) => AuthRepositoryImpl());
}
