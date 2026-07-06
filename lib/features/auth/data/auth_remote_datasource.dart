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
  ///
  /// El backend exige `firstName` + `lastName` separados, así que partimos el
  /// nombre completo. También enviamos `fullName`/`name` por tolerancia.
  Future<LoginResult> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    final firstName = parts.isNotEmpty ? parts.first : fullName.trim();
    final lastName =
        parts.length > 1 ? parts.sublist(1).join(' ') : '';
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.register,
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'fullName': fullName.trim(),
          'name': fullName.trim(),
          'email': email,
          'password': password,
          'phone': phone,
          'role': 'owner',
        },
      );
      return LoginResult.fromJson(response.data ?? {});
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  /// Paso 1 de recuperación: solicita el enlace/token de reseteo.
  /// El backend responde SIEMPRE 200; en desarrollo incluye `resetToken`.
  Future<ForgotPasswordResult> forgotPassword(String email) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.forgotPassword,
        data: {'email': email},
      );
      return ForgotPasswordResult.fromJson(response.data ?? {});
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  /// Paso 2 de recuperación: aplica la nueva contraseña con el token.
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await _dio.post<dynamic>(
        ApiConstants.resetPassword,
        data: {'token': token, 'newPassword': newPassword},
      );
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

  /// Baja voluntaria y eliminación de datos (US45): DELETE /users/{id}.
  /// Es inmediata (sin aprobación de admin).
  Future<void> deleteUser(String id) async {
    try {
      await _dio.delete<dynamic>(ApiConstants.userById(id));
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  /// KYC real: sube los documentos vía `POST /auth/kyc` (multipart/form-data).
  /// Requiere `userId` y al menos uno de los documentos. Devuelve el nuevo
  /// estado (`pending` tras enviarlos).
  Future<KycStatus> submitKyc({
    required String userId,
    String? dniFrontPath,
    String? dniBackPath,
    String? selfiePath,
  }) async {
    Future<MapEntry<String, MultipartFile>?> entry(
      String field,
      String? path,
    ) async {
      if (path == null || path.isEmpty) return null;
      return MapEntry(
        field,
        await MultipartFile.fromFile(path, filename: '$field.jpg'),
      );
    }

    try {
      final files = <MapEntry<String, MultipartFile>>[];
      for (final e in await Future.wait([
        entry('dniFront', dniFrontPath),
        entry('dniBack', dniBackPath),
        entry('selfie', selfiePath),
      ])) {
        if (e != null) files.add(e);
      }
      final form = FormData.fromMap({'userId': userId})..files.addAll(files);
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.kyc,
        data: form,
        options: Options(contentType: 'multipart/form-data'),
      );
      return KycStatus.fromString(response.data?['status'] as String?);
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
