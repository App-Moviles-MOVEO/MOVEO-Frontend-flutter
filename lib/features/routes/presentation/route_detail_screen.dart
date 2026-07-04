import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';
import 'package:wheelspe_provider/core/utils/currency_formatter.dart';
import 'package:wheelspe_provider/core/utils/date_formatter.dart';
import 'package:wheelspe_provider/features/routes/data/route_model.dart';
import 'package:wheelspe_provider/features/routes/presentation/routes_providers.dart';
import 'package:wheelspe_provider/l10n/generated/app_localizations.dart';
import 'package:wheelspe_provider/shared/providers/user_provider.dart';
import 'package:wheelspe_provider/shared/widgets/avatar_widget.dart';
import 'package:wheelspe_provider/shared/widgets/error_state.dart';
import 'package:wheelspe_provider/shared/widgets/rating_stars.dart';
import 'package:wheelspe_provider/shared/widgets/shimmer_card.dart';
import 'package:wheelspe_provider/shared/widgets/snackbars.dart';
import 'package:wheelspe_provider/shared/widgets/status_badge.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_button.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_card.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_text_field.dart';

class RouteDetailScreen extends ConsumerWidget {
  final String routeId;

  const RouteDetailScreen({super.key, required this.routeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final routeAsync = ref.watch(routeDetailProvider(routeId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.routeDetailTitle)),
      body: routeAsync.when(
        loading: () => const ShimmerList(count: 3, itemHeight: 160),
        error: (e, _) => ErrorState(
          onRetry: () => ref.invalidate(routeDetailProvider(routeId)),
        ),
        data: (route) => _RouteDetailBody(route: route),
      ),
    );
  }
}

class _RouteDetailBody extends ConsumerStatefulWidget {
  final RouteModel route;

  const _RouteDetailBody({required this.route});

  @override
  ConsumerState<_RouteDetailBody> createState() => _RouteDetailBodyState();
}

class _RouteDetailBodyState extends ConsumerState<_RouteDetailBody> {
  bool _busy = false;

  RouteModel get route => widget.route;

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
    final actions = ref.read(routeActionsProvider);
    final occupancy = route.seatCapacity == 0
        ? 0.0
        : route.occupiedSeats / route.seatCapacity;
    final statusLabel = switch (route.status) {
      RouteStatus.scheduled => l10n.statusScheduled,
      RouteStatus.inProgress => l10n.statusInProgress,
      RouteStatus.completed => l10n.statusCompleted,
      RouteStatus.cancelled => l10n.statusCancelled,
    };

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        _RouteMap(route: route),
        const SizedBox(height: 16),

        // Información general de la ruta
        WheelsPeCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${route.origin} → ${route.destination}',
                      style: AppTextStyles.title,
                    ),
                  ),
                  StatusBadge.fromStatus(route.status.apiValue, statusLabel),
                ],
              ),
              const SizedBox(height: 14),
              _infoRow(
                Icons.schedule,
                DateFormatter.fullDateTime(route.departureDateTime, locale),
              ),
              const SizedBox(height: 8),
              _infoRow(
                Icons.attach_money,
                '${l10n.pricePerSeat}: '
                '${CurrencyFormatter.format(route.pricePerSeat)}',
              ),
              const SizedBox(height: 12),
              Text(
                l10n.seatsOccupied(
                  route.occupiedSeats,
                  route.seatCapacity,
                ),
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(value: occupancy, minHeight: 6),
              ),
              if (route.institutionalFilter || route.womenOnly) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    if (route.institutionalFilter)
                      StatusBadge(
                        label: l10n.upcOnly,
                        color: AppColors.accent,
                        icon: Icons.school_outlined,
                      ),
                    if (route.womenOnly)
                      StatusBadge(
                        label: l10n.womenOnly,
                        color: AppColors.warning,
                        icon: Icons.female,
                      ),
                  ],
                ),
              ],
              if (route.notes.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(route.notes, style: AppTextStyles.bodySecondary),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Pasajeros
        Row(
          children: [
            Expanded(
              child: Text(l10n.passengers, style: AppTextStyles.title),
            ),
            Semantics(
              label: l10n.seeAll,
              button: true,
              child: TextButton(
                onPressed: () =>
                    context.push('/routes/${route.id}/passengers'),
                child: Text(l10n.seeAll),
              ),
            ),
          ],
        ),
        if (route.unregisteredSeats > 0) ...[
          WheelsPeCard(
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.warning),
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
          const SizedBox(height: 10),
        ],
        if (route.passengers.isEmpty && route.unregisteredSeats == 0)
          WheelsPeCard(
            child: Row(
              children: [
                const Icon(
                  Icons.airline_seat_recline_normal,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.noPassengersYet,
                    style: AppTextStyles.bodySecondary,
                  ),
                ),
              ],
            ),
          )
        else ...[
          for (final p in route.pendingPassengers)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PassengerTile(
                routeId: route.id,
                passenger: p,
                showActions: route.status == RouteStatus.scheduled,
              ),
            ),
          for (final p in route.confirmedPassengers)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PassengerTile(routeId: route.id, passenger: p),
            ),
        ],
        const SizedBox(height: 16),

        // Resumen de ingresos al completar
        if (route.status == RouteStatus.completed) ...[
          WheelsPeCard(
            glow: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.routeEarningsSummary, style: AppTextStyles.subtitle),
                const SizedBox(height: 8),
                Text(
                  CurrencyFormatter.format(route.earnings),
                  style: AppTextStyles.amount,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.seatsOccupied(
                    route.occupiedSeats,
                    route.seatCapacity,
                  ),
                  style: AppTextStyles.bodySecondary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        ..._buildActions(l10n, actions),
        const SizedBox(height: 32),
      ],
    );
  }

  List<Widget> _buildActions(AppLocalizations l10n, RouteActions actions) {
    switch (route.status) {
      case RouteStatus.scheduled:
        return [
          if (DateFormatter.isToday(route.departureDateTime)) ...[
            WheelsPeButton(
              label: l10n.startRoute,
              icon: Icons.play_arrow_rounded,
              loading: _busy,
              onPressed: () => _run(() => actions.start(route.id)),
            ),
            const SizedBox(height: 12),
          ],
          WheelsPeButton(
            label: l10n.cancelRoute,
            icon: Icons.close,
            variant: WheelsPeButtonVariant.danger,
            loading: _busy,
            onPressed: () => _run(() => actions.cancel(route.id)),
          ),
        ];
      case RouteStatus.inProgress:
        return [
          WheelsPeButton(
            label: l10n.finishRoute,
            icon: Icons.flag_outlined,
            variant: WheelsPeButtonVariant.success,
            loading: _busy,
            onPressed: () => _run(() => actions.complete(route.id)),
          ),
        ];
      case RouteStatus.completed:
        return [
          if (route.confirmedPassengers.isNotEmpty)
            WheelsPeButton(
              label: l10n.ratePassengers,
              icon: Icons.star_outline_rounded,
              variant: WheelsPeButtonVariant.secondary,
              onPressed: () => _showRatePassengersSheet(context),
            ),
        ];
      case RouteStatus.cancelled:
        return const [];
    }
  }

  void _showRatePassengersSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.ratePassengers, style: AppTextStyles.title),
              const SizedBox(height: 16),
              for (final p in route.confirmedPassengers)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: AvatarWidget(
                    imageUrl: p.avatarUrl,
                    name: p.name,
                    showVerifiedBadge: p.verified,
                  ),
                  title: Text(p.name, style: AppTextStyles.body),
                  subtitle: RatingStars(rating: p.rating, size: 14),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _showRatingDialog(p);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRatingDialog(RoutePassenger passenger) {
    final l10n = AppLocalizations.of(context);
    final commentController = TextEditingController();
    int score = 5;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(l10n.rateUser, style: AppTextStyles.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(passenger.name, style: AppTextStyles.body),
              const SizedBox(height: 12),
              RatingStars(
                rating: score.toDouble(),
                size: 34,
                onChanged: (value) => setDialogState(() => score = value),
              ),
              const SizedBox(height: 16),
              WheelsPeTextField(
                controller: commentController,
                label: l10n.comment,
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final raterId =
                    await ref.read(currentUserIdProvider.future);
                if (raterId == null) return;
                await _run(
                  () => ref.read(routeActionsProvider).ratePassenger(
                        raterId: raterId,
                        rateeId: passenger.passengerId,
                        score: score,
                        comment: commentController.text.trim(),
                      ),
                );
                if (mounted) showSuccessSnackBar(context, l10n.ratingSent);
              },
              child: Text(l10n.send),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: AppTextStyles.bodySecondary)),
        ],
      );
}

/// Mapa con origen-destino y la ruta dibujada en color primary.
/// Si la ruta no tiene coordenadas, muestra un placeholder estilizado.
class _RouteMap extends StatelessWidget {
  final RouteModel route;

  const _RouteMap({required this.route});

  bool get _hasCoords =>
      route.originLat != null &&
      route.originLng != null &&
      route.destLat != null &&
      route.destLng != null;

  @override
  Widget build(BuildContext context) {
    if (!_hasCoords) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: const Center(
          child: Icon(Icons.map_outlined, size: 48, color: AppColors.primary),
        ),
      );
    }

    final origin = LatLng(route.originLat!, route.originLng!);
    final dest = LatLng(route.destLat!, route.destLng!);
    final center = LatLng(
      (origin.latitude + dest.latitude) / 2,
      (origin.longitude + dest.longitude) / 2,
    );

    return Semantics(
      label: 'Mapa de la ruta de ${route.origin} a ${route.destination}',
      image: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 220,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(target: center, zoom: 11),
            markers: {
              Marker(
                markerId: const MarkerId('origin'),
                position: origin,
                infoWindow: InfoWindow(title: route.origin),
              ),
              Marker(
                markerId: const MarkerId('destination'),
                position: dest,
                infoWindow: InfoWindow(title: route.destination),
              ),
            },
            polylines: {
              Polyline(
                polylineId: const PolylineId('route'),
                points: [origin, dest],
                color: AppColors.primary,
                width: 4,
              ),
            },
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            liteModeEnabled: true,
          ),
        ),
      ),
    );
  }
}

/// Tile de pasajero con acciones de aceptar/rechazar para solicitudes.
class PassengerTile extends ConsumerStatefulWidget {
  final String routeId;
  final RoutePassenger passenger;
  final bool showActions;
  final bool allowRemoveConfirmed;

  const PassengerTile({
    super.key,
    required this.routeId,
    required this.passenger,
    this.showActions = false,
    this.allowRemoveConfirmed = false,
  });

  @override
  ConsumerState<PassengerTile> createState() => _PassengerTileState();
}

class _PassengerTileState extends ConsumerState<PassengerTile> {
  bool _busy = false;

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
    final passenger = widget.passenger;
    final actions = ref.read(routeActionsProvider);
    final isPending = passenger.status == PassengerStatus.pending;
    // El backend puede devolver la solicitud sin nombre; mostramos al menos
    // el id del pasajero en lugar de una fila en blanco.
    final displayName = passenger.name.isNotEmpty
        ? passenger.name
        : l10n.passengerFallback(passenger.passengerId);

    return WheelsPeCard(
      padding: const EdgeInsets.all(12),
      semanticsLabel: displayName,
      child: Row(
        children: [
          AvatarWidget(
            imageUrl: passenger.avatarUrl,
            name: displayName,
            showVerifiedBadge: passenger.verified,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: AppTextStyles.body,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                RatingStars(rating: passenger.rating, size: 14),
              ],
            ),
          ),
          if (_busy)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          else if (isPending && widget.showActions) ...[
            Semantics(
              label: l10n.accept,
              button: true,
              child: IconButton(
                icon: const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 30,
                ),
                onPressed: () => _run(
                  () => actions.acceptPassenger(
                    widget.routeId,
                    passenger.passengerId,
                  ),
                ),
              ),
            ),
            Semantics(
              label: l10n.reject,
              button: true,
              child: IconButton(
                icon: const Icon(
                  Icons.cancel,
                  color: AppColors.error,
                  size: 30,
                ),
                onPressed: () => _run(
                  () => actions.rejectPassenger(
                    widget.routeId,
                    passenger.passengerId,
                  ),
                ),
              ),
            ),
          ] else if (isPending)
            StatusBadge.fromStatus('PENDING', l10n.statusPending)
          else if (widget.allowRemoveConfirmed)
            Semantics(
              label: l10n.delete,
              button: true,
              child: IconButton(
                icon: const Icon(
                  Icons.person_remove_outlined,
                  color: AppColors.error,
                ),
                onPressed: () => _run(
                  () => actions.removePassenger(
                    widget.routeId,
                    passenger.passengerId,
                  ),
                ),
              ),
            )
          else
            StatusBadge.fromStatus('CONFIRMED', l10n.statusConfirmed),
        ],
      ),
    );
  }
}
