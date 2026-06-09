import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheelspe_provider/core/storage/secure_storage.dart';
import 'package:wheelspe_provider/features/auth/data/auth_models.dart';
import 'package:wheelspe_provider/features/auth/presentation/auth_providers.dart';

/// userId del usuario autenticado (desde secure storage).
final currentUserIdProvider = FutureProvider<String?>(
  (ref) => ref.watch(secureStorageProvider).getUserId(),
);

/// Perfil completo del usuario autenticado (GET /users/{id}).
final currentUserProvider = FutureProvider<UserModel>((ref) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  if (userId == null || userId.isEmpty) {
    throw StateError('No hay sesión activa');
  }
  return ref.watch(authRepositoryProvider).getUser(userId);
});
