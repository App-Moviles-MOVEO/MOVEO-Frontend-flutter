import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheelspe_provider/core/constants/api_constants.dart';
import 'package:wheelspe_provider/core/errors/exceptions.dart';
import 'package:wheelspe_provider/core/network/jwt_interceptor.dart';
import 'package:wheelspe_provider/core/storage/secure_storage.dart';

/// Notifica a la app (router) cuando la sesión expira definitivamente.
class SessionNotifier extends ChangeNotifier {
  bool _expired = false;

  bool get expired => _expired;

  void expire() {
    if (_expired) return;
    _expired = true;
    notifyListeners();
  }

  void reset() {
    if (!_expired) return;
    _expired = false;
    notifyListeners();
  }
}

final sessionNotifierProvider =
    ChangeNotifierProvider<SessionNotifier>((ref) => SessionNotifier());

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(secureStorageProvider);
  final session = ref.watch(sessionNotifierProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(
    JwtInterceptor(
      storage: storage,
      dio: dio,
      onSessionExpired: session.expire,
    ),
  );

  return dio;
});

/// Traduce errores de Dio a excepciones de la capa de datos.
Never throwAsAppException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      throw const NetworkException();
    default:
      final status = e.response?.statusCode;
      if (status == 401) throw const AuthException();
      final data = e.response?.data;
      final message = (data is Map && data['message'] != null)
          ? data['message'].toString()
          : 'Error del servidor';
      throw ServerException(message, statusCode: status);
  }
}
