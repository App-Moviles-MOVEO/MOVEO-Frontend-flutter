import 'package:wheelspe_provider/features/auth/data/auth_models.dart';

/// Contrato de autenticación del dominio.
///
/// El backend es SIN JWT: la sesión es el `userId` persistido.
abstract class AuthRepository {
  /// Inicia sesión y persiste el `userId` + `role` en secure storage.
  Future<LoginResult> login(String email, String password);

  /// Registra al proveedor (rol `owner`) y persiste la sesión.
  Future<LoginResult> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  });

  /// KYC best-effort (sin endpoint dedicado): marca verificación en el usuario.
  Future<void> submitKyc({required String documentType});

  /// Estado de verificación del usuario autenticado.
  Future<KycStatusResult> getKycStatus();

  Future<UserModel> getUser(String id);

  Future<void> updateUser(String id, Map<String, dynamic> changes);

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Logout simbólico + limpieza de secure storage.
  Future<void> logout();

  Future<String?> getStoredUserId();
}
