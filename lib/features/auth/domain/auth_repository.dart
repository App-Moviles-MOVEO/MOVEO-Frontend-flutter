import 'package:wheelspe_provider/features/auth/data/auth_models.dart';

/// Contrato de autenticación del dominio.
abstract class AuthRepository {
  /// Inicia sesión y persiste el JWT + userId en secure storage.
  Future<LoginResult> login(String email, String password);

  /// Registra al proveedor. Si el backend no devuelve token,
  /// hace login automáticamente con las credenciales dadas.
  Future<LoginResult> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  });

  Future<void> uploadKyc({
    required String documentType,
    required String frontImagePath,
    required String backImagePath,
  });

  Future<KycStatusResult> getKycStatus();

  Future<UserModel> getUser(String id);

  /// Limpia el secure storage por completo.
  Future<void> logout();

  Future<String?> getStoredToken();

  Future<String?> getStoredUserId();
}
