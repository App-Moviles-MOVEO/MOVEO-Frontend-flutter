/// Excepciones de la capa de datos.
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;

  const NetworkException([this.message = 'Sin conexión a internet']);

  @override
  String toString() => message;
}

class AuthException implements Exception {
  final String message;

  const AuthException([this.message = 'Sesión expirada']);

  @override
  String toString() => message;
}

class CacheException implements Exception {
  final String message;

  const CacheException([this.message = 'Error de almacenamiento local']);

  @override
  String toString() => message;
}
