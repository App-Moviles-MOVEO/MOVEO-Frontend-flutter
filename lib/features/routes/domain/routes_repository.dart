import 'package:wheelspe_provider/features/routes/data/route_model.dart';

/// Contrato de rutas de carpooling del conductor.
abstract class RoutesRepository {
  Future<List<RouteModel>> getMyRoutes(String driverId);

  Future<RouteModel> getRoute(String id);

  Future<RouteModel> publishRoute({
    required String origin,
    required String destination,
    required DateTime departureDate,
    required String departureTime,
    required int availableSeats,
    required double pricePerSeat,
    bool institutionalFilter,
    bool womenOnly,
    String notes,
  });

  Future<void> acceptPassenger(String routeId, String passengerId);

  Future<void> removePassenger(String routeId, String passengerId);

  Future<void> completeRoute(String id);

  Future<void> cancelRoute(String id);
}
