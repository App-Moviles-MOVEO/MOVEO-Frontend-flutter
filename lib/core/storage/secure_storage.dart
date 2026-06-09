import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Claves de almacenamiento seguro.
class SecureStorageKeys {
  SecureStorageKeys._();

  static const String jwt = 'wheelspe_jwt';
  static const String userId = 'wheelspe_user_id';
}

/// Wrapper sobre flutter_secure_storage para el token JWT y el userId.
/// El JWT nunca debe loguearse en consola.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  const SecureStorageService([this._storage = const FlutterSecureStorage()]);

  Future<void> saveToken(String token) =>
      _storage.write(key: SecureStorageKeys.jwt, value: token);

  Future<String?> getToken() => _storage.read(key: SecureStorageKeys.jwt);

  Future<void> saveUserId(String userId) =>
      _storage.write(key: SecureStorageKeys.userId, value: userId);

  Future<String?> getUserId() => _storage.read(key: SecureStorageKeys.userId);

  /// Limpia toda la sesión (logout o 401 definitivo).
  Future<void> clearSession() async {
    await _storage.delete(key: SecureStorageKeys.jwt);
    await _storage.delete(key: SecureStorageKeys.userId);
  }
}

final secureStorageProvider = Provider<SecureStorageService>(
  (ref) => const SecureStorageService(),
);
