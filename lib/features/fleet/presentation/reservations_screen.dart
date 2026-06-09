import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';
import 'package:wheelspe_provider/core/utils/currency_formatter.dart';
import 'package:wheelspe_provider/core/utils/date_formatter.dart';
import 'package:wheelspe_provider/features/fleet/data/reservation_model.dart';
import 'package:wheelspe_provider/features/fleet/presentation/fleet_providers.dart';
import 'package:wheelspe_provider/l10n/generated/app_localizations.dart';
import 'package:wheelspe_provider/shared/widgets/avatar_widget.dart';
import 'package:wheelspe_provider/shared/widgets/empty_state.dart';
import 'package:wheelspe_provider/shared/widgets/error_state.dart';
import 'package:wheelspe_provider/shared/widgets/shimmer_card.dart';
import 'package:wheelspe_provider/shared/widgets/snackbars.dart';
import 'package:wheelspe_provider/shared/widgets/status_badge.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_button.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_card.dart';

/// Reservas de un vehículo en tabs: Pendientes | Activas | Historial.
class VehicleReservationsScreen extends ConsumerWidget {
  final String vehicleId;

  const VehicleReservationsScreen({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final reservationsAsync =
        ref.watch(vehicleReservationsProvider(vehicleId));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.reservationsSection),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.tabPending),
              Tab(text: l10n.tabActive),
              Tab(text: l10n.tabHistory),
            ],
          ),
        ),
        body: reservationsAsync.when(
          loading: () => const ShimmerList(),
          error: (e, _) => ErrorState(
            onRetry: () =>
                ref.invalidate(vehicleReservationsProvider(vehicleId)),
          ),
          data: (reservations) {
            final pending = reservations
                .where((r) => r.status == ReservationStatus.pending)
                .toList();
            final active = reservations
                .where((r) =>
                    r.status == ReservationStatus.confirmed ||
                    r.status == ReservationStatus.inProgress)
                .toList();
            final history = reservations
                .where((r) =>
                    r.status == ReservationStatus.completed ||
                    r.status == ReservationStatus.cancelled)
                .toList();
            return TabBarView(
              children: [
                _ReservationList(reservations: pending, showActions: true),
                _ReservationList(reservations: active, showActions: true),
                _ReservationList(reservations: history),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ReservationList extends StatelessWidget {
  final List<ReservationModel> reservations;
  final bool showActions;

  const _ReservationList({
    required this.reservations,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (reservations.isEmpty) {
      return EmptyState(
        icon: Icons.event_busy_outlined,
        title: l10n.noReservations,
        message: '',
      );
    }
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: reservations.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) => ReservationCard(
        reservation: reservations[i],
        showActions: showActions,
      ),
    );
  }
}

/// Card de reserva reutilizable (también la usa el dashboard).
class ReservationCard extends ConsumerStatefulWidget {
  final ReservationModel reservation;
  final bool showActions;

  const ReservationCard({
    super.key,
    required this.reservation,
    this.showActions = false,
  });

  @override
  ConsumerState<ReservationCard> createState() => _ReservationCardState();
}

class _ReservationCardState extends ConsumerState<ReservationCard> {
  bool _busy = false;

  ReservationModel get reservation => widget.reservation;

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final actions = ref.read(reservationActionsProvider);
    final statusLabel = switch (reservation.status) {
      ReservationStatus.pending => l10n.statusPending,
      ReservationStatus.confirmed => l10n.statusConfirmed,
      ReservationStatus.inProgress => l10n.statusInProgress,
      ReservationStatus.completed => l10n.statusCompleted,
      ReservationStatus.cancelled => l10n.statusCancelled,
    };

    return WheelsPeCard(
      glow: reservation.status == ReservationStatus.pending,
      onTap: () => context.push('/reservations/${reservation.id}'),
      semanticsLabel: '${reservation.renterName}, $statusLabel, '
          '${CurrencyFormatter.format(reservation.totalAmount)}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarWidget(
                name: reservation.renterName,
                imageUrl: reservation.renterAvatar,
                showVerifiedBadge: reservation.renterVerified,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reservation.renterName,
                      style: AppTextStyles.body,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (reservation.vehicleName.isNotEmpty)
                      Text(
                        reservation.vehicleName,
                        style: AppTextStyles.caption,
                      ),
                  ],
                ),
              ),
              StatusBadge.fromStatus(
                reservation.status.apiValue,
                statusLabel,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${DateFormatter.shortDate(reservation.startDate, locale)} → '
                '${DateFormatter.shortDate(reservation.endDate, locale)}',
                style: AppTextStyles.bodySecondary,
              ),
              Text(
                CurrencyFormatter.format(reservation.totalAmount),
                style: AppTextStyles.title,
              ),
            ],
          ),
          if (widget.showActions) ...[
            const SizedBox(height: 12),
            if (reservation.status == ReservationStatus.pending)
              Row(
                children: [
                  Expanded(
                    child: WheelsPeButton(
                      label: l10n.confirm,
                      variant: WheelsPeButtonVariant.success,
                      loading: _busy,
                      onPressed: () => _run(
                        () => actions.confirm(reservation),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: WheelsPeButton(
                      label: l10n.reject,
                      variant: WheelsPeButtonVariant.danger,
                      loading: _busy,
                      onPressed: () => _run(
                        () => actions.cancel(reservation),
                      ),
                    ),
                  ),
                ],
              )
            else if (reservation.status == ReservationStatus.confirmed)
              WheelsPeButton(
                label: l10n.registerVehicleDelivery,
                icon: Icons.vpn_key_outlined,
                loading: _busy,
                onPressed: () => _run(
                  () => actions.startRental(reservation),
                ),
              )
            else if (reservation.status == ReservationStatus.inProgress)
              WheelsPeButton(
                label: l10n.registerVehicleReturn,
                icon: Icons.assignment_return_outlined,
                loading: _busy,
                onPressed: () => _run(
                  () => actions.completeRental(reservation),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
