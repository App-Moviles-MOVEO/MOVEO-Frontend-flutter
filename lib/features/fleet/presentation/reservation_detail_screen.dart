import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';
import 'package:wheelspe_provider/core/utils/currency_formatter.dart';
import 'package:wheelspe_provider/core/utils/date_formatter.dart';
import 'package:wheelspe_provider/core/utils/trip_pin.dart';
import 'package:wheelspe_provider/features/fleet/data/reservation_model.dart';
import 'package:wheelspe_provider/features/fleet/presentation/fleet_providers.dart';
import 'package:wheelspe_provider/l10n/generated/app_localizations.dart';
import 'package:wheelspe_provider/shared/widgets/avatar_widget.dart';
import 'package:wheelspe_provider/shared/widgets/error_state.dart';
import 'package:wheelspe_provider/shared/widgets/rating_stars.dart';
import 'package:wheelspe_provider/shared/widgets/shimmer_card.dart';
import 'package:wheelspe_provider/shared/widgets/snackbars.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_button.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_card.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_text_field.dart';

class ReservationDetailScreen extends ConsumerWidget {
  final String reservationId;

  const ReservationDetailScreen({super.key, required this.reservationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final reservationAsync =
        ref.watch(reservationDetailProvider(reservationId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reservationDetailTitle)),
      body: reservationAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              ShimmerCard(height: 110),
              SizedBox(height: 12),
              ShimmerCard(height: 180),
            ],
          ),
        ),
        error: (e, _) => ErrorState(
          onRetry: () =>
              ref.invalidate(reservationDetailProvider(reservationId)),
        ),
        data: (reservation) => _ReservationDetailBody(reservation: reservation),
      ),
    );
  }
}

class _ReservationDetailBody extends ConsumerStatefulWidget {
  final ReservationModel reservation;

  const _ReservationDetailBody({required this.reservation});

  @override
  ConsumerState<_ReservationDetailBody> createState() =>
      _ReservationDetailBodyState();
}

class _ReservationDetailBodyState
    extends ConsumerState<_ReservationDetailBody> {
  bool _busy = false;
  bool _rated = false;

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

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info del arrendatario
          Text(l10n.renterInfo, style: AppTextStyles.title),
          const SizedBox(height: 12),
          WheelsPeCard(
            child: Row(
              children: [
                AvatarWidget(
                  name: reservation.renterName,
                  imageUrl: reservation.renterAvatar,
                  radius: 28,
                  showVerifiedBadge: reservation.renterVerified,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(reservation.renterName, style: AppTextStyles.body),
                      const SizedBox(height: 4),
                      RatingStars(rating: reservation.renterRating),
                    ],
                  ),
                ),
                Semantics(
                  label: 'Contactar cliente',
                  button: true,
                  child: IconButton(
                    icon: const Icon(Icons.chat_bubble_outline,
                        color: AppColors.accent),
                    onPressed: reservation.renterId.isEmpty
                        ? null
                        : () => context.push(
                              '/chat/${reservation.renterId}'
                              '?name=${Uri.encodeComponent(reservation.renterName)}',
                            ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Info del alquiler
          Text(l10n.rentalInfo, style: AppTextStyles.title),
          const SizedBox(height: 12),
          WheelsPeCard(
            child: Column(
              children: [
                if (reservation.vehicleName.isNotEmpty)
                  _row(l10n.model, reservation.vehicleName),
                _row(
                  l10n.departureDate,
                  '${DateFormatter.shortDate(reservation.startDate, locale)}'
                  ' → '
                  '${DateFormatter.shortDate(reservation.endDate, locale)}',
                ),
                _row(l10n.totalDays(reservation.totalDaysCount), ''),
                _row(
                  l10n.totalAmount,
                  CurrencyFormatter.format(reservation.totalAmount),
                ),
                if (reservation.deposit > 0)
                  _row(
                    l10n.deposit,
                    CurrencyFormatter.format(reservation.deposit),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Línea de tiempo
          Text(l10n.timeline, style: AppTextStyles.title),
          const SizedBox(height: 12),
          WheelsPeCard(
            child: Column(
              children: [
                _TimelineStep(
                  label: l10n.statusPending,
                  date: reservation.createdAt,
                  locale: locale,
                  done: true,
                ),
                _TimelineStep(
                  label: l10n.statusConfirmed,
                  date: reservation.confirmedAt,
                  locale: locale,
                  done: reservation.status.index >=
                      ReservationStatus.confirmed.index &&
                      reservation.status != ReservationStatus.cancelled,
                ),
                _TimelineStep(
                  label: l10n.statusInProgress,
                  date: reservation.startedAt,
                  locale: locale,
                  done: reservation.status.index >=
                      ReservationStatus.inProgress.index &&
                      reservation.status != ReservationStatus.cancelled,
                ),
                _TimelineStep(
                  label: reservation.status == ReservationStatus.cancelled
                      ? l10n.statusCancelled
                      : l10n.statusCompleted,
                  date: reservation.completedAt,
                  locale: locale,
                  done: reservation.status == ReservationStatus.completed ||
                      reservation.status == ReservationStatus.cancelled,
                  isLast: true,
                  isError:
                      reservation.status == ReservationStatus.cancelled,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Acciones según estado
          ..._buildActions(l10n, actions),
          const SizedBox(height: 12),
          WheelsPeButton(
            label: l10n.reportIncident,
            icon: Icons.report_outlined,
            variant: WheelsPeButtonVariant.secondary,
            onPressed: () => context.push(
              '/incidents/report?reservationId=${reservation.id}',
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// US09: pide el PIN de 4 dígitos que el arrendatario ve en su app,
  /// lo valida y solo entonces registra la entrega e inicia el checklist.
  Future<void> _startDeliveryWithPin(ReservationActions actions) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        String? errorText;
        return StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            title: Text(l10n.startPinTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.startPinSubtitle,
                    style: AppTextStyles.bodySecondary),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headline,
                  decoration: InputDecoration(
                    labelText: l10n.pinLabel,
                    errorText: errorText,
                    counterText: '',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () {
                  if (TripPin.validate(reservation.id, controller.text)) {
                    Navigator.pop(ctx, true);
                  } else {
                    setDialogState(() => errorText = l10n.invalidPin);
                  }
                },
                child: Text(l10n.confirm),
              ),
            ],
          ),
        );
      },
    );
    if (ok != true || !mounted) return;
    showSuccessSnackBar(context, l10n.pinValidated);
    await _run(() async {
      await actions.startRental(reservation);
      if (mounted) {
        context.push(
          '/fleet/${reservation.vehicleId}/checklist'
          '?tipo=PRE&reservationId=${reservation.id}',
        );
      }
    });
  }

  List<Widget> _buildActions(
    AppLocalizations l10n,
    ReservationActions actions,
  ) {
    switch (reservation.status) {
      case ReservationStatus.pending:
        return [
          WheelsPeButton(
            label: l10n.confirmReservation,
            variant: WheelsPeButtonVariant.success,
            loading: _busy,
            onPressed: () => _run(() => actions.confirm(reservation)),
          ),
          const SizedBox(height: 12),
          WheelsPeButton(
            label: l10n.reject,
            variant: WheelsPeButtonVariant.danger,
            loading: _busy,
            onPressed: () => _run(() => actions.cancel(reservation)),
          ),
        ];
      case ReservationStatus.confirmed:
        return [
          // El PIN lo genera y muestra ÚNICAMENTE la app Renter (arrendatario).
          // Aquí el proveedor solo lo pide y lo valida al registrar la entrega.
          WheelsPeCard(
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.accent),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.tripPinAsk,
                    style: AppTextStyles.caption,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          WheelsPeButton(
            label: l10n.registerVehicleDelivery,
            icon: Icons.vpn_key_outlined,
            loading: _busy,
            onPressed: () => _startDeliveryWithPin(actions),
          ),
        ];
      case ReservationStatus.inProgress:
        return [
          WheelsPeButton(
            label: l10n.registerVehicleReturn,
            icon: Icons.assignment_return_outlined,
            loading: _busy,
            onPressed: () => _run(() async {
              await actions.completeRental(reservation);
              if (mounted) {
                context.push(
                  '/fleet/${reservation.vehicleId}/checklist'
                  '?tipo=POST&reservationId=${reservation.id}',
                );
              }
            }),
          ),
        ];
      case ReservationStatus.completed:
        return [
          // Cierra el ciclo de reputación: el owner califica al arrendatario
          // (POST /user-reviews, alimenta renter.reputation en próximas reservas).
          if (!_rated && reservation.renterId.isNotEmpty) ...[
            WheelsPeButton(
              label: l10n.rateRenter,
              icon: Icons.star_outline_rounded,
              loading: _busy,
              onPressed: _showRateRenterDialog,
            ),
            const SizedBox(height: 12),
          ],
          WheelsPeButton(
            label: l10n.viewReceipt,
            icon: Icons.receipt_long_outlined,
            variant: _rated
                ? WheelsPeButtonVariant.primary
                : WheelsPeButtonVariant.secondary,
            onPressed: () => context.push('/transactions'),
          ),
        ];
      case ReservationStatus.cancelled:
        return const [];
    }
  }

  void _showRateRenterDialog() {
    final l10n = AppLocalizations.of(context);
    final commentController = TextEditingController();
    int score = 5;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(l10n.rateRenter, style: AppTextStyles.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(reservation.renterName, style: AppTextStyles.body),
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
                var ok = false;
                await _run(() async {
                  await ref.read(reservationActionsProvider).rateRenter(
                        reservation,
                        score,
                        commentController.text.trim(),
                      );
                  ok = true;
                });
                if (mounted && ok) {
                  setState(() => _rated = true);
                  showSuccessSnackBar(context, l10n.ratingSent);
                }
              },
              child: Text(l10n.send),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: AppTextStyles.bodySecondary),
            ),
            Text(value, style: AppTextStyles.body),
          ],
        ),
      );
}

class _TimelineStep extends StatelessWidget {
  final String label;
  final DateTime? date;
  final String locale;
  final bool done;
  final bool isLast;
  final bool isError;

  const _TimelineStep({
    required this.label,
    required this.date,
    required this.locale,
    required this.done,
    this.isLast = false,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isError
        ? AppColors.error
        : done
            ? AppColors.success
            : AppColors.divider;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Icon(
                isError
                    ? Icons.cancel
                    : done
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                size: 20,
                color: color,
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: color),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.body.copyWith(
                      color: done
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                  if (date != null)
                    Text(
                      DateFormatter.fullDateTime(date!, locale),
                      style: AppTextStyles.caption,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
