import 'package:intl/intl.dart';
import 'package:wheelspe_provider/features/routes/data/route_model.dart';
import 'package:wheelspe_provider/features/routes/data/routes_remote_datasource.dart';
import 'package:wheelspe_provider/features/routes/domain/routes_repository.dart';

class RoutesRepositoryImpl implements RoutesRepository {
  final RoutesRemoteDataSource _remote;

  const RoutesRepositoryImpl(this._remote);

  @override
  Future<List<RouteModel>> getMyRoutes(String driverId) =>
      _remote.getDriverRoutes(driverId);

  @override
  Future<RouteModel> getRoute(String id) => _remote.getRoute(id);

  @override
  Future<RouteModel> publishRoute({
    required String origin,
    required String destination,
    required DateTime departureDate,
    required String departureTime,
    required int availableSeats,
    required double pricePerSeat,
    bool institutionalFilter = false,
    bool womenOnly = false,
    String notes = '',
  }) =>
      _remote.createRoute({
        'origin': origin,
        'destination': destination,
        'departureDate': DateFormat('yyyy-MM-dd').format(departureDate),
        'departureTime': departureTime,
        'availableSeats': availableSeats,
        'pricePerSeat': pricePerSeat,
        if (institutionalFilter) 'institutionalFilter': 'UPC',
        'womenOnly': womenOnly,
        if (notes.isNotEmpty) 'notes': notes,
      });

  @override
  Future<void> acceptPassenger(String routeId, String passengerId) =>
      _remote.acceptPassenger(routeId, passengerId);

  @override
  Future<void> removePassenger(String routeId, String passengerId) =>
      _remote.removePassenger(routeId, passengerId);

  @override
  Future<void> completeRoute(String id) => _remote.completeRoute(id);

  @override
  Future<void> cancelRoute(String id) => _remote.cancelRoute(id);
}
