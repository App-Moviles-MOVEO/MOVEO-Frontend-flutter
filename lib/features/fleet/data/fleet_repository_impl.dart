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

  /// Publica en tres pasos: crea el vehículo, sube las fotos locales por
  /// multipart y luego los documentos de propiedad (US05). Si la subida de
  /// archivos falla, el vehículo ya creado se devuelve igualmente.
  @override
  Future<VehicleModel> publishVehicle(
    VehicleModel vehicle,
    String ownerId,
  ) async {
    var created = await _remote.createVehicle(vehicle.toCreateJson(ownerId));
    if (created.id.isEmpty) return created;

    final localPhotos =
        vehicle.photos.where((p) => !p.startsWith('http')).toList();
    if (localPhotos.isNotEmpty) {
      try {
        await _remote.uploadVehicleImages(created.id, localPhotos);
      } catch (_) {
        // El vehículo existe; las fotos podrán reintentarse después.
      }
    }
    if (vehicle.documents.isNotEmpty) {
      try {
        created = await _remote.uploadVehicleDocuments(
          created.id,
          vehicle.documents,
        );
      } catch (_) {
        // Ídem: los documentos se pueden completar desde el detalle.
      }
    }
    return created;
  }

  @override
  Future<void> updateVehicle(String id, Map<String, dynamic> changes) =>
      _remote.updateVehicle(id, changes);

  @override
  Future<VehicleModel> uploadOwnershipDocuments(
    String id,
    Map<String, String> docPaths,
  ) =>
      _remote.uploadVehicleDocuments(id, docPaths);

  @override
  Future<void> submitInspection({
    required String rentalId,
    required String type,
    required Map<String, String> photosByPoint,
    String? createdById,
  }) =>
      _remote.uploadInspection(
        rentalId: rentalId,
        type: type,
        photosByPoint: photosByPoint,
        createdById: createdById,
      );

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

  @override
  Future<void> rateRenter({
    required String rentalId,
    required String raterId,
    required String rateeId,
    required int score,
    String comment = '',
  }) =>
      _remote.rateRenter({
        'reviewerId': raterId,
        'reviewedUserId': rateeId,
        'rating': score,
        'type': 'owner_to_renter',
        if (comment.isNotEmpty) 'comment': comment,
        // El backend espera rentalId numérico; 0 = sin FK (validado en backend).
        'rentalId': int.tryParse(rentalId) ?? 0,
      });
}
