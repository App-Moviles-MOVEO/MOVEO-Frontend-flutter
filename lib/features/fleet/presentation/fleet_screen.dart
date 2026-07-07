import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';
import 'package:wheelspe_provider/core/utils/currency_formatter.dart';
import 'package:wheelspe_provider/features/fleet/data/reservation_model.dart';
import 'package:wheelspe_provider/features/fleet/data/vehicle_model.dart';
import 'package:wheelspe_provider/features/fleet/presentation/fleet_providers.dart';
import 'package:wheelspe_provider/l10n/generated/app_localizations.dart';
import 'package:wheelspe_provider/shared/widgets/empty_state.dart';
import 'package:wheelspe_provider/shared/widgets/error_state.dart';
import 'package:wheelspe_provider/shared/widgets/shimmer_card.dart';
import 'package:wheelspe_provider/shared/widgets/status_badge.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_card.dart';

class FleetScreen extends ConsumerWidget {
  const FleetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final vehiclesAsync = ref.watch(myVehiclesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.fleetTitle)),
      floatingActionButton: Semantics(
        label: l10n.publishVehicle,
        button: true,
        child: FloatingActionButton(
          onPressed: () => context.push('/fleet/add'),
          child: const Icon(Icons.add),
        ),
      ),
      body: vehiclesAsync.when(
        loading: () => const ShimmerList(itemHeight: 170),
        error: (e, _) => ErrorState(
          onRetry: () => ref.invalidate(myVehiclesProvider),
        ),
        data: (vehicles) {
          if (vehicles.isEmpty) {
            return EmptyState(
              icon: Icons.directions_car_outlined,
              title: l10n.fleetEmpty,
              message: l10n.fleetEmptyBody,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myVehiclesProvider),
            child: ListView.separated(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.all(16),
              itemCount: vehicles.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) =>
                  _VehicleCard(vehicle: vehicles[i]),
            ),
          );
        },
      ),
    );
  }
}

class _VehicleCard extends ConsumerWidget {
  final VehicleModel vehicle;

  const _VehicleCard({required this.vehicle});

  String _statusLabel(AppLocalizations l10n) => switch (vehicle.status) {
        VehicleStatus.available => l10n.statusAvailable,
        VehicleStatus.rented => l10n.statusRented,
        VehicleStatus.maintenance => l10n.statusMaintenance,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    // El backend no devuelve estadísticas por vehículo (llegan en 0), así que
    // se calculan en cliente desde las reservas del proveedor de este mes.
    final reservations =
        ref.watch(ownerReservationsProvider).valueOrNull ?? const [];
    final now = DateTime.now();
    bool sameMonth(DateTime? d) =>
        d != null && d.year == now.year && d.month == now.month;
    final mine = reservations.where((r) => r.vehicleId == vehicle.id);
    final computedReservations = mine
        .where((r) =>
            r.status != ReservationStatus.cancelled &&
            sameMonth(r.createdAt ?? r.startDate))
        .length;
    final computedEarnings = mine
        .where((r) =>
            r.status == ReservationStatus.completed &&
            sameMonth(r.completedAt ?? r.startDate))
        .fold<double>(0, (sum, r) => sum + r.totalAmount);
    // Si algún día el backend sí devuelve los agregados, se prefieren.
    final monthReservations = vehicle.monthReservations > 0
        ? vehicle.monthReservations
        : computedReservations;
    final monthEarnings =
        vehicle.monthEarnings > 0 ? vehicle.monthEarnings : computedEarnings;

    return WheelsPeCard(
      padding: EdgeInsets.zero,
      semanticsLabel: '${vehicle.displayName}, ${_statusLabel(l10n)}',
      onTap: () => context.push('/fleet/${vehicle.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Hero(
              tag: 'vehicle-${vehicle.id}',
              child: vehicle.photos.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: vehicle.photos.first,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, _) =>
                          const ShimmerCard(height: 150, borderRadius: BorderRadius.zero),
                      errorWidget: (_, _, _) => _photoFallback(),
                    )
                  : _photoFallback(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        vehicle.displayName,
                        style: AppTextStyles.title,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    StatusBadge.fromStatus(
                      vehicle.status.apiValue,
                      _statusLabel(l10n),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(vehicle.plate, style: AppTextStyles.bodySecondary),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.insights,
                      size: 16,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        l10n.vehicleStats(
                          monthReservations,
                          CurrencyFormatter.formatCompact(monthEarnings),
                        ),
                        style: AppTextStyles.caption,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoFallback() => Container(
        height: 150,
        width: double.infinity,
        color: AppColors.surface,
        child: const Icon(
          Icons.directions_car_outlined,
          size: 56,
          color: AppColors.textSecondary,
        ),
      );
}
