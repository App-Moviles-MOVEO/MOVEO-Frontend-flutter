import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheelspe_provider/core/network/dio_client.dart';
import 'package:wheelspe_provider/features/routes/data/route_model.dart';
import 'package:wheelspe_provider/features/routes/data/routes_remote_datasource.dart';
import 'package:wheelspe_provider/features/routes/data/routes_repository_impl.dart';
import 'package:wheelspe_provider/features/routes/domain/routes_repository.dart';
import 'package:wheelspe_provider/shared/providers/user_provider.dart';

final routesRepositoryProvider = Provider<RoutesRepository>(
  (ref) =>
      RoutesRepositoryImpl(RoutesRemoteDataSource(ref.watch(dioProvider))),
);

/// Rutas publicadas por el conductor autenticado.
final myRoutesProvider = FutureProvider<List<RouteModel>>((ref) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  if (userId == null) return const [];
  return ref.watch(routesRepositoryProvider).getMyRoutes(userId);
});

final routeDetailProvider = FutureProvider.family<RouteModel, String>(
  (ref, id) => ref.watch(routesRepositoryProvider).getRoute(id),
);

/// Acciones sobre rutas con invalidación de caches.
class RouteActions {
  final Ref _ref;

  const RouteActions(this._ref);

  RoutesRepository get _repo => _ref.read(routesRepositoryProvider);

  Future<void> acceptPassenger(String routeId, String passengerId) async {
    await _repo.acceptPassenger(routeId, passengerId);
    _invalidate(routeId);
  }

  Future<void> removePassenger(String routeId, String passengerId) async {
    await _repo.removePassenger(routeId, passengerId);
    _invalidate(routeId);
  }

  Future<void> start(String routeId) async {
    await _repo.startRoute(routeId);
    _invalidate(routeId);
  }

  Future<void> complete(String routeId) async {
    await _repo.completeRoute(routeId);
    _invalidate(routeId);
  }

  Future<void> ratePassenger({
    required String raterId,
    required String rateeId,
    required int score,
    String comment = '',
  }) =>
      _repo.ratePassenger(
        raterId: raterId,
        rateeId: rateeId,
        score: score,
        comment: comment,
      );

  Future<void> cancel(String routeId) async {
    await _repo.cancelRoute(routeId);
    _invalidate(routeId);
  }

  void _invalidate(String routeId) {
    _ref.invalidate(routeDetailProvider(routeId));
    _ref.invalidate(myRoutesProvider);
  }
}

final routeActionsProvider =
    Provider<RouteActions>((ref) => RouteActions(ref));
