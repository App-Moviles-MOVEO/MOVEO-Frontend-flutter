import 'package:flutter/material.dart' show DateTimeRange;
import 'package:wheelspe_provider/features/auth/data/auth_models.dart';
import 'package:wheelspe_provider/features/fleet/data/fleet_remote_datasource.dart';
import 'package:wheelspe_provider/features/fleet/data/reservation_model.dart';
import 'package:wheelspe_provider/features/fleet/data/vehicle_model.dart';
import 'package:wheelspe_provider/features/fleet/domain/fleet_repository.dart';

class FleetRepositoryImpl implements FleetRepository {
  final FleetRemoteDataSource _remote;

  const FleetRepositoryImpl(this._remote);

  @override
  Future<List<VehicleModel>> getMyVehicles(String ownerId) =>
      _remote.getVehicles(ownerId);

  @override
  Future<VehicleModel> getVehicle(String id) => _remote.getVehicle(id);

  @override
  Future<VehicleModel> publishVehicle(VehicleModel vehicle, String ownerId) =>
      _remote.createVehicle(vehicle.toCreateJson(ownerId));

  @override
  Future<void> updateVehicle(String id, Map<String, dynamic> changes) =>
      _remote.updateVehicle(id, changes);

  @override
  Future<void> changeStatus(String id, VehicleStatus status) =>
      _remote.updateVehicleStatus(id, status);

  @override
  Future<List<DateTimeRange>> getAvailability(String vehicleId) =>
      _remote.getAvailability(vehicleId);

  @override
  Future<List<ReservationModel>> getVehicleReservations(String vehicleId) =>
      _remote.getReservationsByVehicle(vehicleId).then(_withRenterInfo);

  @override
  Future<List<ReservationModel>> getOwnerReservations(String ownerId) =>
      _remote.getReservationsByOwner(ownerId).then(_withRenterInfo);

  @override
  Future<ReservationModel> getReservation(String id) async {
    final enriched = await _withRenterInfo([await _remote.getReservation(id)]);
    return enriched.first;
  }

  /// El backend de /rentals solo devuelve `renterId`; resolvemos nombre,
  /// avatar y reputación del arrendatario vía GET /users/{id} (una sola
  /// petición por usuario distinto). Si falla, se muestra la reserva igual.
  Future<List<ReservationModel>> _withRenterInfo(
    List<ReservationModel> reservations,
  ) async {
    final ids = reservations
        .where((r) => r.renterName.isEmpty && r.renterId.isNotEmpty)
        .map((r) => r.renterId)
        .toSet();
    if (ids.isEmpty) return reservations;

    final users = <String, UserModel>{};
    await Future.wait(ids.map((id) async {
      try {
        users[id] = await _remote.getUser(id);
      } catch (_) {
        // Usuario no disponible: la reserva se muestra sin sus datos.
      }
    }));

    return reservations.map((r) {
      final user = users[r.renterId];
      if (user == null) return r;
      return r.copyWith(
        renterName: user.fullName,
        renterAvatar: user.avatarUrl,
        renterRating: user.reputation,
        renterVerified: user.isVerified,
      );
    }).toList();
  }

  @override
  Future<void> confirmReservation(String id) =>
      _remote.confirmReservation(id);

  @override
  Future<void> startRental(String id) => _remote.startReservation(id);

  @override
  Future<void> completeRental(String id) => _remote.completeReservation(id);

  @override
  Future<void> cancelReservation(String id) => _remote.cancelReservation(id);
}
