import 'package:wheelspe_provider/features/routes/data/route_model.dart';

/// Contrato de rutas de carpooling del conductor.
abstract class RoutesRepository {
  Future<List<RouteModel>> getMyRoutes(String ownerId);

  Future<RouteModel> getRoute(String id);

  Future<RouteModel> publishRoute({
    required String ownerId,
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

  /// US17: publica la misma ruta de forma recurrente en los días [weekdays]
  /// (1 = lunes … 7 = domingo) durante [weeks] semanas, empezando por la
  /// semana de [firstDate]. Devuelve las rutas creadas.
  Future<List<RouteModel>> publishRecurringRoutes({
    required String ownerId,
    required String origin,
    required String destination,
    required DateTime firstDate,
    required String departureTime,
    required int availableSeats,
    required double pricePerSeat,
    required Set<int> weekdays,
    required int weeks,
    bool institutionalFilter,
    bool womenOnly,
    String notes,
  });

  Future<void> acceptPassenger(
    String routeId,
    String passengerId,
    String ownerId,
  );

  Future<void> rejectPassenger(
    String routeId,
    String passengerId,
    String ownerId,
  );

  Future<void> removePassenger(
    String routeId,
    String passengerId,
    String ownerId,
  );

  Future<void> startRoute(String id, String ownerId);

  Future<void> completeRoute(String id, String ownerId);

  Future<void> cancelRoute(String id, String ownerId);

  /// Califica a un pasajero al finalizar la ruta (POST /user-reviews).
  Future<void> ratePassenger({
    required String raterId,
    required String rateeId,
    required int score,
    String comment,
    String? rentalId,
  });
}
