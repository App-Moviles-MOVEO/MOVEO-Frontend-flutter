import 'package:flutter/material.dart' show DateTimeRange;
import 'package:wheelspe_provider/features/fleet/data/reservation_model.dart';
import 'package:wheelspe_provider/features/fleet/data/vehicle_model.dart';

/// Contrato de la flota del proveedor.
abstract class FleetRepository {
  Future<List<VehicleModel>> getMyVehicles(String ownerId);

  Future<VehicleModel> getVehicle(String id);

  Future<VehicleModel> publishVehicle(VehicleModel vehicle, String ownerId);

  Future<void> updateVehicle(String id, Map<String, dynamic> changes);

  Future<void> changeStatus(String id, VehicleStatus status);

  Future<List<DateTimeRange>> getAvailability(String vehicleId);

  Future<List<ReservationModel>> getVehicleReservations(String vehicleId);

  Future<List<ReservationModel>> getOwnerReservations(String ownerId);

  Future<ReservationModel> getReservation(String id);

  Future<void> confirmReservation(String id);

  Future<void> startRental(String id);

  Future<void> completeRental(String id);

  Future<void> cancelReservation(String id);
}
