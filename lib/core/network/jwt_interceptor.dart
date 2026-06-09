import 'package:dio/dio.dart';
import 'package:wheelspe_provider/core/constants/api_constants.dart';
import 'package:wheelspe_provider/core/storage/secure_storage.dart';

/// Interceptor JWT:
/// 1. Agrega `Authorization: Bearer {token}` a cada request.
/// 2. Ante un 401 intenta refrescar el token y reintenta UNA sola vez.
/// 3. Si el refresh falla, limpia la sesión y notifica para redirigir a Login.
class JwtInterceptor extends Interceptor {
  final SecureStorageService _storage;
  final Dio _dio;
  final void Function() _onSessionExpired;

  static const _retriedKey = 'jwt_retried';
  static const _publicPaths = {ApiConstants.login, ApiConstants.register};

  JwtInterceptor({
    required SecureStorageService storage,
    required Dio dio,
    required void Function() onSessionExpired,
  })  : _storage = storage,
        _dio = dio,
        _onSessionExpired = onSessionExpired;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_publicPaths.contains(options.path)) {
      final token = await _storage.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final is401 = err.response?.statusCode == 401;
    final alreadyRetried = options.extra[_retriedKey] == true;
    final isPublic = _publicPaths.contains(options.path);

    if (!is401 || alreadyRetried || isPublic) {
      handler.next(err);
      return;
    }

    final newToken = await _tryRefreshToken();
    if (newToken == null) {
      await _storage.clearSession();
      _onSessionExpired();
      handler.next(err);
      return;
    }

    // Reintento único con el token refrescado.
    options.extra[_retriedKey] = true;
    options.headers['Authorization'] = 'Bearer $newToken';
    try {
      final response = await _dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (retryError) {
      if (retryError.response?.statusCode == 401) {
        await _storage.clearSession();
        _onSessionExpired();
      }
      handler.next(retryError);
    }
  }

  Future<String?> _tryRefreshToken() async {
    final currentToken = await _storage.getToken();
    if (currentToken == null) return null;

    try {
      // Cliente "limpio" para evitar recursión del interceptor.
      final bare = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
      final response = await bare.post<Map<String, dynamic>>(
        ApiConstants.refresh,
        options: Options(headers: {'Authorization': 'Bearer $currentToken'}),
      );
      final newToken = response.data?['token'] as String?;
      if (newToken == null || newToken.isEmpty) return null;
      await _storage.saveToken(newToken);
      return newToken;
    } catch (_) {
      return null;
    }
  }
}
