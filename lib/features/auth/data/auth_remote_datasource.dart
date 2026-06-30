import 'package:dio/dio.dart';
import 'package:wheelspe_provider/core/constants/api_constants.dart';
import 'package:wheelspe_provider/core/network/dio_client.dart';
import 'package:wheelspe_provider/features/auth/data/auth_models.dart';

class AuthRemoteDataSource {
  final Dio _dio;

  const AuthRemoteDataSource(this._dio);

  Future<LoginResult> login(String email, String password) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      return LoginResult.fromJson(response.data ?? {});
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  /// Registra al proveedor con rol `owner` (lo que espera el backend).
  /// Devuelve el usuario creado (sin token).
  Future<LoginResult> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.register,
        data: {
          'email': email,
          'password': password,
          'fullName': fullName,
          'phone': phone,
          'role': 'owner',
        },
      );
      return LoginResult.fromJson(response.data ?? {});
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post<dynamic>(ApiConstants.logout);
    } on DioException catch (_) {
      // Logout simbólico en el backend; ignorar fallos de red.
    }
  }

  Future<void> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.post<dynamic>(
        ApiConstants.changePassword,
        data: {
          'userId': userId,
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  Future<UserModel> getUser(String id) async {
    try {
      final response =
          await _dio.get<Map<String, dynamic>>(ApiConstants.userById(id));
      return UserModel.fromJson(response.data ?? {});
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    try {
      await _dio.patch<dynamic>(ApiConstants.userById(id), data: data);
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  /// KYC best-effort: el backend NO tiene flujo KYC ni subida de imágenes.
  /// Registramos la intención de verificación vía PATCH /users/{id}
  /// (estado IN_REVIEW + tipo de documento). Las imágenes no se suben
  /// porque no existe endpoint de almacenamiento.
  Future<void> submitKyc({
    required String userId,
    required String documentType,
  }) async {
    try {
      await _dio.patch<dynamic>(
        ApiConstants.userById(userId),
        data: {
          'verificationStatus': 'IN_REVIEW',
          'documentType': documentType,
        },
      );
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  /// Estado de verificación derivado del usuario.
  Future<KycStatusResult> getKycStatus(String userId) async {
    final user = await getUser(userId);
    return KycStatusResult.fromUser(user);
  }
}
