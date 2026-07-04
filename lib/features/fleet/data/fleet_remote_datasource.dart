import 'package:dio/dio.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:wheelspe_provider/core/constants/api_constants.dart';
import 'package:wheelspe_provider/core/network/dio_client.dart';
import 'package:wheelspe_provider/features/auth/data/auth_models.dart';
import 'package:wheelspe_provider/features/fleet/data/reservation_model.dart';
import 'package:wheelspe_provider/features/fleet/data/vehicle_model.dart';

class FleetRemoteDataSource {
  final Dio _dio;

  const FleetRemoteDataSource(this._dio);

  Future<List<VehicleModel>> getVehicles(String ownerId) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiConstants.vehicles,
        queryParameters: {'ownerId': ownerId},
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

  /// Cambia el estado del vehículo: PATCH /vehicles/{id} con {status}.
  Future<void> updateVehicleStatus(String id, VehicleStatus status) async {
    try {
      await _dio.patch<dynamic>(
        ApiConstants.vehicleById(id),
        data: {'status': status.apiValue},
      );
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  /// Rangos de fechas ocupados del vehículo (para bloquear calendario).
  Future<List<DateTimeRange>> getAvailability(String vehicleId) async {
    try {
      final response = await _dio
          .get<dynamic>(ApiConstants.vehicleAvailability(vehicleId));
      final data = response.data;
      final raw = data is Map
          ? (data['busyRanges'] ?? data['busy'] ?? data['ranges'])
          : data;
      if (raw is! List) return const [];
      return raw
          .cast<Map<String, dynamic>>()
          .map((r) {
            final start = DateTime.tryParse(
                (r['start'] ?? r['startDate'] ?? '').toString());
            final end = DateTime.tryParse(
                (r['end'] ?? r['endDate'] ?? '').toString());
            if (start == null || end == null) return null;
            return DateTimeRange(start: start, end: end);
          })
          .whereType<DateTimeRange>()
          .toList();
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  /// Reservas de un vehículo: GET /rentals?vehicleId=
  Future<List<ReservationModel>> getReservationsByVehicle(
    String vehicleId,
  ) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiConstants.rentals,
        queryParameters: {'vehicleId': vehicleId},
      );
      return _asList(response.data).map(ReservationModel.fromJson).toList();
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  /// Reservas de todos los vehículos del proveedor: GET /rentals?ownerId=
  Future<List<ReservationModel>> getReservationsByOwner(String ownerId) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiConstants.rentals,
        queryParameters: {'ownerId': ownerId},
      );
      return _asList(response.data).map(ReservationModel.fromJson).toList();
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  /// Perfil de un usuario (para resolver los datos del arrendatario,
  /// que /rentals solo referencia por `renterId`).
  Future<UserModel> getUser(String id) async {
    try {
      final response =
          await _dio.get<Map<String, dynamic>>(ApiConstants.userById(id));
      return UserModel.fromJson(response.data ?? {});
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  Future<ReservationModel> getReservation(String id) async {
    try {
      final response =
          await _dio.get<Map<String, dynamic>>(ApiConstants.rentalById(id));
      return ReservationModel.fromJson(response.data ?? {});
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  // Transición de estados vía PATCH /rentals/{id} {status}.
  Future<void> confirmReservation(String id) =>
      _patchStatus(id, ReservationStatus.confirmed);

  Future<void> startReservation(String id) =>
      _patchStatus(id, ReservationStatus.inProgress);

  Future<void> completeReservation(String id) =>
      _patchStatus(id, ReservationStatus.completed);

  Future<void> cancelReservation(String id) =>
      _patchStatus(id, ReservationStatus.cancelled);

  Future<void> _patchStatus(String id, ReservationStatus status) async {
    try {
      await _dio.patch<dynamic>(
        ApiConstants.rentalById(id),
        data: {'status': status.apiValue},
      );
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
    if (data is Map && data['data'] is List) {
      return (data['data'] as List).cast<Map<String, dynamic>>();
    }
    return const [];
  }
}
