import 'package:dio/dio.dart';
import 'package:wheelspe_provider/core/constants/api_constants.dart';
import 'package:wheelspe_provider/core/network/dio_client.dart';
import 'package:wheelspe_provider/features/fleet/data/reservation_model.dart';
import 'package:wheelspe_provider/features/fleet/data/vehicle_model.dart';

class FleetRemoteDataSource {
  final Dio _dio;

  const FleetRemoteDataSource(this._dio);

  Future<List<VehicleModel>> getVehicles(String providerId) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiConstants.vehicles,
        queryParameters: {'providerId': providerId},
      );
      return _asList(response.data).map(VehicleModel.fromJson).toList();
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  Future<VehicleModel> getVehicle(String id) async {
    try {
      final response =
          await _dio.get<Map<String, dynamic>>(ApiConstants.vehicleById(id));
      return VehicleModel.fromJson(response.data ?? {});
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  Future<VehicleModel> createVehicle(Map<String, dynamic> body) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.vehicles,
        data: body,
      );
      return VehicleModel.fromJson(response.data ?? {});
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  Future<void> updateVehicle(String id, Map<String, dynamic> body) async {
    try {
      await _dio.put<dynamic>(ApiConstants.vehicleById(id), data: body);
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  Future<void> updateVehicleStatus(String id, VehicleStatus status) async {
    try {
      await _dio.patch<dynamic>(
        ApiConstants.vehicleStatus(id),
        data: {'status': status.apiValue},
      );
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  Future<List<ReservationModel>> getReservationsByVehicle(
    String vehicleId,
  ) async {
    try {
      final response = await _dio
          .get<dynamic>(ApiConstants.reservationsByVehicle(vehicleId));
      return _asList(response.data).map(ReservationModel.fromJson).toList();
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  Future<ReservationModel> getReservation(String id) async {
    try {
      final response = await _dio
          .get<Map<String, dynamic>>(ApiConstants.reservationById(id));
      return ReservationModel.fromJson(response.data ?? {});
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  Future<void> confirmReservation(String id) =>
      _patch(ApiConstants.reservationConfirm(id));

  Future<void> startReservation(String id) =>
      _patch(ApiConstants.reservationStart(id));

  Future<void> completeReservation(String id) =>
      _patch(ApiConstants.reservationComplete(id));

  Future<void> cancelReservation(String id) =>
      _patch(ApiConstants.reservationCancel(id));

  Future<void> _patch(String path) async {
    try {
      await _dio.patch<dynamic>(path);
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  static List<Map<String, dynamic>> _asList(dynamic data) {
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map && data['content'] is List) {
      return (data['content'] as List).cast<Map<String, dynamic>>();
    }
    if (data is Map && data['items'] is List) {
      return (data['items'] as List).cast<Map<String, dynamic>>();
    }
    return const [];
  }
}
