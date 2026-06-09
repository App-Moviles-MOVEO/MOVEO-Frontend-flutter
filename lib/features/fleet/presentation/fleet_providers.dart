import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheelspe_provider/core/network/dio_client.dart';
import 'package:wheelspe_provider/features/fleet/data/fleet_remote_datasource.dart';
import 'package:wheelspe_provider/features/fleet/data/fleet_repository_impl.dart';
import 'package:wheelspe_provider/features/fleet/data/reservation_model.dart';
import 'package:wheelspe_provider/features/fleet/data/vehicle_model.dart';
import 'package:wheelspe_provider/features/fleet/domain/fleet_repository.dart';
import 'package:wheelspe_provider/shared/providers/user_provider.dart';

final fleetRepositoryProvider = Provider<FleetRepository>(
  (ref) => FleetRepositoryImpl(FleetRemoteDataSource(ref.watch(dioProvider))),
);

/// Vehículos del proveedor autenticado.
final myVehiclesProvider = FutureProvider<List<VehicleModel>>((ref) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  if (userId == null) return const [];
  return ref.watch(fleetRepositoryProvider).getMyVehicles(userId);
});

final vehicleDetailProvider = FutureProvider.family<VehicleModel, String>(
  (ref, id) => ref.watch(fleetRepositoryProvider).getVehicle(id),
);

final vehicleReservationsProvider =
    FutureProvider.family<List<ReservationModel>, String>(
  (ref, vehicleId) =>
      ref.watch(fleetRepositoryProvider).getVehicleReservations(vehicleId),
);

final reservationDetailProvider =
    FutureProvider.family<ReservationModel, String>(
  (ref, id) => ref.watch(fleetRepositoryProvider).getReservation(id),
);

/// Todas las reservas PENDING de todos los vehículos del proveedor
/// (alimenta el dashboard y el polling de notificaciones).
final pendingReservationsProvider =
    FutureProvider<List<ReservationModel>>((ref) async {
  final vehicles = await ref.watch(myVehiclesProvider.future);
  final repository = ref.watch(fleetRepositoryProvider);
  final results = await Future.wait(
    vehicles.map((v) async {
      try {
        return await repository.getVehicleReservations(v.id);
      } catch (_) {
        return const <ReservationModel>[];
      }
    }),
  );
  return [
    for (final list in results)
      ...list.where((r) => r.status == ReservationStatus.pending),
  ];
});

/// Acciones sobre reservas con invalidación de caches relacionadas.
class ReservationActions {
  final Ref _ref;

  const ReservationActions(this._ref);

  FleetRepository get _repo => _ref.read(fleetRepositoryProvider);

  Future<void> confirm(ReservationModel reservation) async {
    await _repo.confirmReservation(reservation.id);
    _invalidate(reservation);
  }

  Future<void> startRental(ReservationModel reservation) async {
    await _repo.startRental(reservation.id);
    _invalidate(reservation);
  }

  Future<void> completeRental(ReservationModel reservation) async {
    await _repo.completeRental(reservation.id);
    _invalidate(reservation);
  }

  Future<void> cancel(ReservationModel reservation) async {
    await _repo.cancelReservation(reservation.id);
    _invalidate(reservation);
  }

  void _invalidate(ReservationModel reservation) {
    _ref.invalidate(reservationDetailProvider(reservation.id));
    _ref.invalidate(vehicleReservationsProvider(reservation.vehicleId));
    _ref.invalidate(pendingReservationsProvider);
    _ref.invalidate(vehicleDetailProvider(reservation.vehicleId));
  }
}

final reservationActionsProvider =
    Provider<ReservationActions>((ref) => ReservationActions(ref));

/// Acciones sobre vehículos.
class VehicleActions {
  final Ref _ref;

  const VehicleActions(this._ref);

  Future<void> changeStatus(String vehicleId, VehicleStatus status) async {
    await _ref.read(fleetRepositoryProvider).changeStatus(vehicleId, status);
    _ref.invalidate(vehicleDetailProvider(vehicleId));
    _ref.invalidate(myVehiclesProvider);
  }

  Future<VehicleModel> publish(VehicleModel vehicle) async {
    final created =
        await _ref.read(fleetRepositoryProvider).publishVehicle(vehicle);
    _ref.invalidate(myVehiclesProvider);
    return created;
  }

  Future<void> update(String id, Map<String, dynamic> changes) async {
    await _ref.read(fleetRepositoryProvider).updateVehicle(id, changes);
    _ref.invalidate(vehicleDetailProvider(id));
    _ref.invalidate(myVehiclesProvider);
  }
}

final vehicleActionsProvider =
    Provider<VehicleActions>((ref) => VehicleActions(ref));
