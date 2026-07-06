import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheelspe_provider/core/network/dio_client.dart';
import 'package:wheelspe_provider/features/auth/data/auth_models.dart';
import 'package:wheelspe_provider/features/profile/data/profile_remote_datasource.dart';
import 'package:wheelspe_provider/shared/providers/user_provider.dart';

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>(
  (ref) => ProfileRemoteDataSource(ref.watch(dioProvider)),
);

/// Últimas reseñas recibidas por el proveedor.
final myReviewsProvider = FutureProvider<List<ReviewModel>>((ref) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  if (userId == null) return const [];
  return ref.watch(profileRemoteDataSourceProvider).getReviews(userId);
});

/// Badges del proveedor calculados a partir de su perfil.
class ProviderBadges {
  final bool verified;
  final bool punctual;
  final bool topRenter;
  final bool fiveStars;

  const ProviderBadges({
    this.verified = false,
    this.punctual = false,
    this.topRenter = false,
    this.fiveStars = false,
  });

  factory ProviderBadges.fromUser(UserModel user) {
    // Preferimos los badges otorgados server-side (US36). Si el backend aún
    // no los expone, caemos a la aproximación por reputación/actividad.
    if (user.serverBadges.isNotEmpty) {
      final b = user.serverBadges.map((e) => e.toUpperCase()).toSet();
      return ProviderBadges(
        verified: b.contains('VERIFIED'),
        punctual: b.contains('PUNCTUAL'),
        topRenter: b.contains('TOP_RENTER'),
        fiveStars: b.contains('FIVE_STARS'),
      );
    }
    return ProviderBadges(
      verified: user.isVerified,
      // Con onTimeRate del backend usamos el umbral real; si no viene (-1),
      // aproximamos con reputación + actividad.
      punctual: user.onTimeRate >= 0
          ? user.completedRentals >= 3 && user.onTimeRate >= 0.9
          : user.completedRentals > 0 && user.reputation >= 4.5,
      topRenter: user.completedRentals > 10,
      fiveStars: user.reputation >= 4.8 && user.ratingCount > 0,
    );
  }
}

final myBadgesProvider = FutureProvider<ProviderBadges>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  return ProviderBadges.fromUser(user);
});

/// Acciones de perfil (PUT /users/{id}).
class ProfileActions {
  final Ref _ref;

  const ProfileActions(this._ref);

  Future<void> updateProfile({
    required String fullName,
    required String phone,
  }) async {
    final userId = await _ref.read(currentUserIdProvider.future);
    if (userId == null) throw StateError('Sin sesión activa');
    await _ref.read(profileRemoteDataSourceProvider).updateUser(userId, {
      'fullName': fullName,
      'phone': phone,
    });
    _ref.invalidate(currentUserProvider);
  }
}

final profileActionsProvider =
    Provider<ProfileActions>((ref) => ProfileActions(ref));
