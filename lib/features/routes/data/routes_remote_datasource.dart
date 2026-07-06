import 'package:dio/dio.dart';
import 'package:wheelspe_provider/core/constants/api_constants.dart';
import 'package:wheelspe_provider/core/network/dio_client.dart';
import 'package:wheelspe_provider/features/routes/data/route_model.dart';

class RoutesRemoteDataSource {
  final Dio _dio;

  const RoutesRemoteDataSource(this._dio);

  Future<List<RouteModel>> getDriverRoutes(String ownerId) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiConstants.routes,
        queryParameters: {'ownerId': ownerId},
      );
      final data = response.data;
      final list = data is List
          ? data.cast<Map<String, dynamic>>()
          : (data is Map && data['content'] is List)
              ? (data['content'] as List).cast<Map<String, dynamic>>()
              : (data is Map && data['data'] is List)
                  ? (data['data'] as List).cast<Map<String, dynamic>>()
                  : const <Map<String, dynamic>>[];
      return list.map(RouteModel.fromJson).toList();
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  Future<RouteModel> getRoute(String id) async {
    try {
      final response =
          await _dio.get<Map<String, dynamic>>(ApiConstants.routeById(id));
      return RouteModel.fromJson(response.data ?? {});
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  Future<RouteModel> createRoute(Map<String, dynamic> body) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.routes,
        data: body,
      );
      return RouteModel.fromJson(response.data ?? {});
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  /// Transiciones de estado dedicadas del backend. Si el endpoint aún no
  /// existe (404/405), cae al PUT genérico con `status`.
  Future<void> startRoute(String id, String ownerId) =>
      _transition(ApiConstants.routeStart(id), ownerId, id, 'in_progress');

  Future<void> completeRoute(String id, String ownerId) =>
      _transition(ApiConstants.routeComplete(id), ownerId, id, 'completed');

  Future<void> cancelRoute(String id, String ownerId) =>
      _transition(ApiConstants.routeCancel(id), ownerId, id, 'cancelled');

  Future<void> _transition(
    String path,
    String ownerId,
    String id,
    String fallbackStatus,
  ) async {
    try {
      await _dio.post<dynamic>(
        path,
        queryParameters: {'ownerId': ownerId},
      );
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      if (code == 404 || code == 405) {
        await setStatus(id, fallbackStatus);
        return;
      }
      throwAsAppException(e);
    }
  }

  /// Cambia el estado de la ruta vía PUT /adventure-routes/{id}
  /// (respaldo cuando no hay endpoint de transición dedicado).
  Future<void> setStatus(String id, String status) async {
    try {
      await _dio
          .put<dynamic>(ApiConstants.routeById(id), data: {'status': status});
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  Future<void> deleteRoute(String id) async {
    try {
      await _dio.delete<dynamic>(ApiConstants.routeById(id));
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  /// Califica a un pasajero al finalizar la ruta: POST /user-reviews.
  Future<void> rateUser(Map<String, dynamic> body) async {
    try {
      await _dio.post<dynamic>(ApiConstants.userReviews, data: body);
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  /// Lista los pasajeros/solicitudes de una ruta (requiere `ownerId`).
  /// Endpoint dedicado; el detalle de la ruta también embebe `passengers`.
  Future<List<RoutePassenger>> getPassengers(
    String routeId,
    String ownerId,
  ) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.routePassengers(routeId),
        queryParameters: {'ownerId': ownerId},
      );
      final list = (response.data?['passengers'] as List?)
              ?.cast<Map<String, dynamic>>() ??
          const <Map<String, dynamic>>[];
      return list.map(RoutePassenger.fromJson).toList();
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  /// Acepta una solicitud → CONFIRMED (descuenta cupo).
  Future<void> acceptPassenger(
    String routeId,
    String passengerId,
    String ownerId,
  ) async {
    try {
      await _dio.post<dynamic>(
        ApiConstants.routePassengerAccept(routeId, passengerId),
        queryParameters: {'ownerId': ownerId},
      );
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  /// Rechaza una solicitud pendiente → REJECTED (libera cupo tentativo).
  Future<void> rejectPassenger(
    String routeId,
    String passengerId,
    String ownerId,
  ) async {
    try {
      await _dio.post<dynamic>(
        ApiConstants.routePassengerReject(routeId, passengerId),
        queryParameters: {'ownerId': ownerId},
      );
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  /// Quita a un pasajero confirmado → CANCELLED (libera cupo).
  Future<void> removePassenger(
    String routeId,
    String passengerId,
    String ownerId,
  ) async {
    try {
      await _dio.delete<dynamic>(
        ApiConstants.routePassenger(routeId, passengerId),
        queryParameters: {'ownerId': ownerId},
      );
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }
}