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

  /// KYC real: sube los documentos (multipart) del usuario autenticado.
  /// Devuelve el nuevo estado de verificación (`pending` tras enviarlos).
  Future<KycStatus> submitKyc({
    String? dniFrontPath,
    String? dniBackPath,
    String? selfiePath,
  });

  /// Estado de verificación del usuario autenticado.
  Future<KycStatusResult> getKycStatus();

  /// Recuperación de contraseña (paso 1): solicita el token de reseteo.
  Future<ForgotPasswordResult> forgotPassword(String email);

  /// Recuperación de contraseña (paso 2): aplica la nueva clave con el token.
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  });

  Future<UserModel> getUser(String id);

  Future<void> updateUser(String id, Map<String, dynamic> changes);

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Baja voluntaria: elimina la cuenta en el backend y limpia la sesión.
  Future<void> deleteAccount();

  /// Logout simbólico + limpieza de secure storage.
  Future<void> logout();

  Future<String?> getStoredUserId();
}
