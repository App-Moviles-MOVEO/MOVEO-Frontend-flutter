import 'package:flutter/material.dart' show DateTimeRange;
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
  Future<VehicleModel> publishVehicle(VehicleModel vehicle) =>
      _remote.createVehicle(vehicle.toCreateJson());

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
      _remote.getReservationsByVehicle(vehicleId);

  @override
  Future<List<ReservationModel>> getOwnerReservations(String ownerId) =>
      _remote.getReservationsByOwner(ownerId);

  @override
  Future<ReservationModel> getReservation(String id) =>
      _remote.getReservation(id);

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
