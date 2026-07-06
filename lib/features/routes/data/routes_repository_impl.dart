import 'package:intl/intl.dart';
import 'package:wheelspe_provider/features/routes/data/route_model.dart';
import 'package:wheelspe_provider/features/routes/data/routes_remote_datasource.dart';
import 'package:wheelspe_provider/features/routes/domain/recurrence.dart';
import 'package:wheelspe_provider/features/routes/domain/routes_repository.dart';

class RoutesRepositoryImpl implements RoutesRepository {
  final RoutesRemoteDataSource _remote;

  const RoutesRepositoryImpl(this._remote);

  @override
  Future<List<RouteModel>> getMyRoutes(String ownerId) =>
      _remote.getDriverRoutes(ownerId);

  @override
  Future<RouteModel> getRoute(String id) => _remote.getRoute(id);

  @override
  Future<RouteModel> publishRoute({
    required String ownerId,
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
        'ownerId': int.tryParse(ownerId) ?? ownerId,
        // CreateAdventureRouteResource del backend real: name/title/
        // startLocation/endLocation + campos obligatorios de aventura.
        'name': '$origin → $destination',
        'title': '$origin → $destination',
        'description': notes.isNotEmpty ? notes : 'Carpool $origin → $destination',
        'startLocation': origin,
        'endLocation': destination,
        'type': 'carpool',
        'duration': 1,
        'difficulty': 'easy',
        'estimatedCost': pricePerSeat,
        'departureDate': DateFormat('yyyy-MM-dd').format(departureDate),
        'departureTime': departureTime,
        'seatsTotal': availableSeats,
        'seatsAvailable': availableSeats,
        'pricePerSeat': pricePerSeat,
        'onlyWomen': womenOnly,
        if (institutionalFilter) 'community': 'UPC',
      });

  @override
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
    bool institutionalFilter = false,
    bool womenOnly = false,
    String notes = '',
  }) async {
    final dates = RecurrencePlanner.weeklyOccurrences(
      firstDate: firstDate,
      weekdays: weekdays,
      weeks: weeks,
    );
    final created = <RouteModel>[];
    for (final date in dates) {
      created.add(
        await publishRoute(
          ownerId: ownerId,
          origin: origin,
          destination: destination,
          departureDate: date,
          departureTime: departureTime,
          availableSeats: availableSeats,
          pricePerSeat: pricePerSeat,
          institutionalFilter: institutionalFilter,
          womenOnly: womenOnly,
          notes: notes,
        ),
      );
    }
    return created;
  }

  @override
  Future<void> acceptPassenger(
    String routeId,
    String passengerId,
    String ownerId,
  ) =>
      _remote.acceptPassenger(routeId, passengerId, ownerId);

  @override
  Future<void> rejectPassenger(
    String routeId,
    String passengerId,
    String ownerId,
  ) =>
      _remote.rejectPassenger(routeId, passengerId, ownerId);

  @override
  Future<void> removePassenger(
    String routeId,
    String passengerId,
    String ownerId,
  ) =>
      _remote.removePassenger(routeId, passengerId, ownerId);

  @override
  Future<void> startRoute(String id, String ownerId) =>
      _remote.startRoute(id, ownerId);

  @override
  Future<void> completeRoute(String id, String ownerId) =>
      _remote.completeRoute(id, ownerId);

  @override
  Future<void> cancelRoute(String id, String ownerId) =>
      _remote.cancelRoute(id, ownerId);

  @override
  Future<void> ratePassenger({
    required String raterId,
    required String rateeId,
    required int score,
    String comment = '',
    String? rentalId,
  }) =>
      _remote.rateUser({
        'reviewerId': raterId,
        'reviewedUserId': rateeId,
        'rating': score,
        'type': 'owner_to_renter',
        if (comment.isNotEmpty) 'comment': comment,
        'rentalId': ?rentalId,
      });
}
