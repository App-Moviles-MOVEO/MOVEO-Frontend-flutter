import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';
import 'package:wheelspe_provider/features/routes/data/route_model.dart';
import 'package:wheelspe_provider/features/routes/presentation/route_detail_screen.dart';
import 'package:wheelspe_provider/features/routes/presentation/routes_providers.dart';
import 'package:wheelspe_provider/l10n/generated/app_localizations.dart';
import 'package:wheelspe_provider/shared/widgets/empty_state.dart';
import 'package:wheelspe_provider/shared/widgets/error_state.dart';
import 'package:wheelspe_provider/shared/widgets/shimmer_card.dart';

/// Gestión completa de pasajeros de una ruta: solicitudes pendientes
/// con aceptar/rechazar y confirmados con opción de eliminar.
class PassengersScreen extends ConsumerWidget {
  final String routeId;

  const PassengersScreen({super.key, required this.routeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final routeAsync = ref.watch(routeDetailProvider(routeId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.passengers)),
      body: routeAsync.when(
        loading: () => const ShimmerList(itemHeight: 80),
        error: (e, _) => ErrorState(
          onRetry: () => ref.invalidate(routeDetailProvider(routeId)),
        ),
        data: (route) {
          if (route.passengers.isEmpty) {
            return EmptyState(
              icon: Icons.airline_seat_recline_normal,
              title: l10n.noPassengersYet,
              message: l10n.routesEmptyBody,
            );
          }
          final manageable = route.status == RouteStatus.scheduled;
          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(routeDetailProvider(routeId)),
            child: ListView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.all(16),
              children: [
                if (route.pendingPassengers.isNotEmpty) ...[
                  Text(l10n.pendingRequests, style: AppTextStyles.title),
                  const SizedBox(height: 12),
                  for (final p in route.pendingPassengers)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: PassengerTile(
                        routeId: routeId,
                        passenger: p,
                        showActions: manageable,
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
                if (route.confirmedPassengers.isNotEmpty) ...[
                  Text(l10n.confirmedPassengers, style: AppTextStyles.title),
                  const SizedBox(height: 12),
                  for (final p in route.confirmedPassengers)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: PassengerTile(
                        routeId: routeId,
                        passenger: p,
                        allowRemoveConfirmed: manageable,
                      ),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
