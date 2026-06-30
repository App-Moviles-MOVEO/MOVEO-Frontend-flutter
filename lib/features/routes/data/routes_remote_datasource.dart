import 'package:dio/dio.dart';
import 'package:wheelspe_provider/core/constants/api_constants.dart';
import 'package:wheelspe_provider/core/errors/exceptions.dart';
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

  /// Cambia el estado de la ruta vía PUT /adventure-routes/{id}
  /// (el backend no expone un PATCH/transición dedicado).
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

  // El backend NO tiene gestión de pasajeros (aprobar/rechazar/listar):
  // `/adventure-routes/{id}/book` solo descuenta cupos. Se expone un error
  // claro para que la UI lo informe en vez de fallar silenciosamente.
  Future<void> acceptPassenger(String routeId, String passengerId) async =>
      throw const ServerException(
        'El backend aún no soporta aprobar pasajeros (solo reservar asiento).',
      );

  Future<void> removePassenger(String routeId, String passengerId) async =>
      throw const ServerException(
        'El backend aún no soporta quitar pasajeros.',
      );
}