import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';
import 'package:wheelspe_provider/features/routes/data/route_model.dart';
import 'package:wheelspe_provider/features/routes/presentation/route_detail_screen.dart';
import 'package:wheelspe_provider/features/routes/presentation/routes_providers.dart';
import 'package:wheelspe_provider/l10n/generated/app_localizations.dart';
import 'package:wheelspe_provider/shared/widgets/empty_state.dart';
import 'package:wheelspe_provider/shared/widgets/error_state.dart';
import 'package:wheelspe_provider/shared/widgets/shimmer_card.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_card.dart';

/// Gestión completa de pasajeros de una ruta: solicitudes pendientes
/// con aceptar/rechazar y confirmados con opción de eliminar.
///
/// US38: incluye un filtro por umbral de confianza (reputación) que separa
/// las solicitudes que superan el umbral de las que quedan por debajo, para
/// que el conductor revise primero a los pasajeros de mayor confianza.
class PassengersScreen extends ConsumerStatefulWidget {
  final String routeId;

  const PassengersScreen({super.key, required this.routeId});

  @override
  ConsumerState<PassengersScreen> createState() => _PassengersScreenState();
}

class _PassengersScreenState extends ConsumerState<PassengersScreen> {
  /// Umbral de confianza activo del filtro. `null` = aún no inicializado
  /// (toma por defecto el umbral configurado en el perfil, US30).
  double? _trustFilter;

  /// Mostrar u ocultar las solicitudes por debajo del umbral.
  bool _showBelow = false;

  String get routeId => widget.routeId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final routeAsync = ref.watch(routeDetailProvider(routeId));
    // Valor por defecto del filtro: el umbral configurado en el perfil (US30).
    final double trust =
        _trustFilter ?? ref.watch(reputationThresholdProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.passengers)),
      body: routeAsync.when(
        loading: () => const ShimmerList(itemHeight: 80),
        error: (e, _) => ErrorState(
          onRetry: () => ref.invalidate(routeDetailProvider(routeId)),
        ),
        data: (route) {
          if (route.passengers.isEmpty && route.unregisteredSeats == 0) {
            return EmptyState(
              icon: Icons.airline_seat_recline_normal,
              title: l10n.noPassengersYet,
              message: l10n.routesEmptyBody,
            );
          }
          final manageable = route.status == RouteStatus.scheduled;

          // US38: partición de las solicitudes pendientes según el umbral.
          final pending = route.pendingPassengers;
          final above =
              pending.where((p) => p.rating >= trust).toList();
          final below =
              pending.where((p) => p.rating < trust).toList();

          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(routeDetailProvider(routeId)),
            child: ListView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.all(16),
              children: [
                if (route.unregisteredSeats > 0) ...[
                  WheelsPeCard(
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: AppColors.warning),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.unregisteredSeats(route.unregisteredSeats),
                            style: AppTextStyles.bodySecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Control de filtro por confianza (US38).
                if (pending.isNotEmpty) ...[
                  _TrustFilterCard(
                    value: trust,
                    onChanged: (v) => setState(() => _trustFilter = v),
                  ),
                  const SizedBox(height: 16),
                ],

                if (pending.isNotEmpty) ...[
                  Text(l10n.pendingRequests, style: AppTextStyles.title),
                  const SizedBox(height: 12),
                  if (above.isEmpty && trust > 0)
                    WheelsPeCard(
                      child: Row(
                        children: [
                          const Icon(Icons.filter_alt_off_outlined,
                              color: AppColors.textSecondary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.noRequestsAboveThreshold,
                              style: AppTextStyles.bodySecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  for (final p in above)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: PassengerTile(
                        routeId: routeId,
                        passenger: p,
                        showActions: manageable,
                        availableSeats: route.availableSeats,
                      ),
                    ),

                  // Solicitudes por debajo del umbral, colapsables.
                  if (below.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () => setState(() => _showBelow = !_showBelow),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Icon(
                              _showBelow
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l10n.belowThresholdSection(below.length),
                                style: AppTextStyles.subtitle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_showBelow)
                      for (final p in below)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: PassengerTile(
                            routeId: routeId,
                            passenger: p,
                            showActions: manageable,
                            availableSeats: route.availableSeats,
                          ),
                        ),
                  ],
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

/// Tarjeta con el slider de confianza mínima para filtrar solicitudes (US38).
class _TrustFilterCard extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const _TrustFilterCard({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return WheelsPeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_user_outlined,
                  color: AppColors.accent, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(l10n.trustFilterTitle,
                    style: AppTextStyles.subtitle),
              ),
              Text(
                value == 0 ? l10n.trustFilterOff : '${value.toStringAsFixed(1)}★',
                style: AppTextStyles.body,
              ),
            ],
          ),
          Slider(
            value: value,
            min: 0,
            max: 5,
            divisions: 10,
            label: value == 0
                ? l10n.trustFilterOff
                : value.toStringAsFixed(1),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
