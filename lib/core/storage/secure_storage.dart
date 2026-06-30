import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Claves de almacenamiento seguro.
class SecureStorageKeys {
  SecureStorageKeys._();

  static const String userId = 'wheelspe_user_id';
  static const String role = 'wheelspe_role';
}

/// Wrapper sobre flutter_secure_storage.
///
/// El backend es SIN JWT: la "sesión" es únicamente el `userId` del usuario
/// logueado (y su `role`). No se guarda ningún token.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  const SecureStorageService([this._storage = const FlutterSecureStorage()]);

  Future<void> saveUserId(String userId) =>
      _storage.write(key: SecureStorageKeys.userId, value: userId);

  Future<String?> getUserId() => _storage.read(key: SecureStorageKeys.userId);

  Future<void> saveRole(String role) =>
      _storage.write(key: SecureStorageKeys.role, value: role);

  Future<String?> getRole() => _storage.read(key: SecureStorageKeys.role);

  /// Limpia toda la sesión (logout).
  Future<void> clearSession() async {
    await _storage.delete(key: SecureStorageKeys.userId);
    await _storage.delete(key: SecureStorageKeys.role);
  }
}

final secureStorageProvider = Provider<SecureStorageService>(
  (ref) => const SecureStorageService(),
);
