import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheelspe_provider/core/constants/api_constants.dart';
import 'package:wheelspe_provider/core/errors/exceptions.dart';

/// Notifica a la app (router) cuando la sesión deja de ser válida.
///
/// Sin JWT no hay expiración por token, pero mantenemos el mecanismo para
/// forzar el regreso a login si el backend responde 401 en algún endpoint.
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
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
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
      String? message;
      if (data is Map) {
        message = (data['message'] ?? data['error'] ?? data['title'])
            ?.toString();
      }
      throw ServerException(message ?? 'Error del servidor', statusCode: status);
  }
}
