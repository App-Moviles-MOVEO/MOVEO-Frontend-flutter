import 'package:dio/dio.dart';
import 'package:wheelspe_provider/core/constants/api_constants.dart';
import 'package:wheelspe_provider/core/network/dio_client.dart';
import 'package:wheelspe_provider/features/routes/data/route_model.dart';

class RoutesRemoteDataSource {
  final Dio _dio;

  const RoutesRemoteDataSource(this._dio);

  Future<List<RouteModel>> getDriverRoutes(String driverId) async {
    try {
      final response =
          await _dio.get<dynamic>(ApiConstants.routesByDriver(driverId));
      final data = response.data;
      final list = data is List
          ? data.cast<Map<String, dynamic>>()
          : (data is Map && data['content'] is List)
              ? (data['content'] as List).cast<Map<String, dynamic>>()
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

  Future<void> acceptPassenger(String routeId, String passengerId) async {
    try {
      await _dio.post<dynamic>(
        ApiConstants.routePassengers(routeId),
        data: {'passengerId': passengerId},
      );
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  Future<void> removePassenger(String routeId, String passengerId) async {
    try {
      await _dio.delete<dynamic>(
        ApiConstants.routePassengerById(routeId, passengerId),
      );
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  Future<void> completeRoute(String id) async {
    try {
      await _dio.patch<dynamic>(ApiConstants.routeComplete(id));
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  Future<void> cancelRoute(String id) async {
    try {
      await _dio.patch<dynamic>(ApiConstants.routeCancel(id));
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }
}
