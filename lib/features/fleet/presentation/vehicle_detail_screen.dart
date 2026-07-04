import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';
import 'package:wheelspe_provider/core/storage/local_storage.dart';
import 'package:wheelspe_provider/core/utils/currency_formatter.dart';
import 'package:wheelspe_provider/core/utils/date_formatter.dart';
import 'package:wheelspe_provider/features/fleet/data/reservation_model.dart';
import 'package:wheelspe_provider/features/fleet/data/vehicle_model.dart';
import 'package:wheelspe_provider/features/fleet/presentation/fleet_providers.dart';
import 'package:wheelspe_provider/l10n/generated/app_localizations.dart';
import 'package:wheelspe_provider/shared/widgets/avatar_widget.dart';
import 'package:wheelspe_provider/shared/widgets/document_slot.dart';
import 'package:wheelspe_provider/shared/widgets/error_state.dart';
import 'package:wheelspe_provider/shared/widgets/shimmer_card.dart';
import 'package:wheelspe_provider/shared/widgets/snackbars.dart';
import 'package:wheelspe_provider/shared/widgets/status_badge.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_button.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_card.dart';

class VehicleDetailScreen extends ConsumerWidget {
  final String vehicleId;

  const VehicleDetailScreen({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final vehicleAsync = ref.watch(vehicleDetailProvider(vehicleId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.vehicleDetailTitle),
        actions: [
          Semantics(
            label: l10n.edit,
            button: true,
            child: IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push('/fleet/$vehicleId/edit'),
            ),
          ),
        ],
      ),
      body: vehicleAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              ShimmerCard(height: 220),
              SizedBox(height: 12),
              ShimmerCard(height: 140),
            ],
          ),
        ),
        error: (e, _) => ErrorState(
          onRetry: () => ref.invalidate(vehicleDetailProvider(vehicleId)),
        ),
        data: (vehicle) => _VehicleDetailBody(vehicle: vehicle),
      ),
    );
  }
}

class _VehicleDetailBody extends ConsumerStatefulWidget {
  final VehicleModel vehicle;

  const _VehicleDetailBody({required this.vehicle});

  @override
  ConsumerState<_VehicleDetailBody> createState() =>
      _VehicleDetailBodyState();
}

class _VehicleDetailBodyState extends ConsumerState<_VehicleDetailBody> {
  bool _changingStatus = false;
  final _picker = ImagePicker();
  late Map<String, String> _docs;

  VehicleModel get vehicle => widget.vehicle;

  @override
  void initState() {
    super.initState();
    // Documentos de propiedad (US05): lo que devuelva el backend más la
    // copia local guardada al publicar (el backend aún no persiste el campo).
    _docs = {
      ...widget.vehicle.documents,
      ...ref.read(localStorageProvider).loadVehicleDocs(widget.vehicle.id),
    };
  }

  Future<void> _pickDoc(String key) async {
    final l10n = AppLocalizations.of(context);
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.camera),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.gallery),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final file = await _picker.pickImage(source: source, imageQuality: 85);
    if (file == null || !mounted) return;
    setState(() => _docs[key] = file.path);
    await ref.read(localStorageProvider).saveVehicleDocs(vehicle.id, _docs);
    // Mejor esfuerzo: se manda al backend aunque hoy no persista el campo.
    try {
      await ref
          .read(fleetRepositoryProvider)
          .updateVehicle(vehicle.id, {'documents': _docs});
    } catch (_) {
      // La copia local ya quedó guardada.
    }
    if (mounted) {
      showSuccessSnackBar(context, AppLocalizations.of(context).documentsSaved);
    }
  }

  Future<void> _toggleStatus() async {
    final target = vehicle.status == VehicleStatus.maintenance
        ? VehicleStatus.available
        : VehicleStatus.maintenance;
    setState(() => _changingStatus = true);
    try {
      await ref.read(vehicleActionsProvider).changeStatus(vehicle.id, target);
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _changingStatus = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reservationsAsync =
        ref.watch(vehicleReservationsProvider(vehicle.id));
    final statusLabel = switch (vehicle.status) {
      VehicleStatus.available => l10n.statusAvailable,
      VehicleStatus.rented => l10n.statusRented,
      VehicleStatus.maintenance => l10n.statusMaintenance,
    };

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PhotoCarousel(vehicle: vehicle),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(vehicle.displayName, style: AppTextStyles.headline),
              ),
              StatusBadge.fromStatus(vehicle.status.apiValue, statusLabel),
            ],
          ),
          const SizedBox(height: 16),
          WheelsPeCard(
            child: Column(
              children: [
                _InfoRow(label: l10n.plate, value: vehicle.plate),
                _InfoRow(label: l10n.category, value: vehicle.category),
                _InfoRow(label: l10n.year, value: '${vehicle.year}'),
                _InfoRow(
                  label: l10n.pricePerDay,
                  value: CurrencyFormatter.format(vehicle.pricePerDay),
                ),
                if (vehicle.address.isNotEmpty)
                  _InfoRow(label: l10n.location, value: vehicle.address),
              ],
            ),
          ),
          if (vehicle.description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(l10n.description, style: AppTextStyles.title),
            const SizedBox(height: 8),
            Text(vehicle.description, style: AppTextStyles.bodySecondary),
          ],
          const SizedBox(height: 20),
          // Acreditación de propiedad (US05)
          Row(
            children: [
              Expanded(
                child: Text(l10n.stepDocuments, style: AppTextStyles.title),
              ),
              Text(
                l10n.documentsCount(_docs.length, 3),
                style: AppTextStyles.caption.copyWith(
                  color: _docs.length >= 3
                      ? AppColors.success
                      : AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          WheelsPeCard(
            child: Column(
              children: [
                DocumentSlot(
                  label: l10n.docPropertyCardFront,
                  filePath: _docs['propertyCardFront'],
                  onTap: () => _pickDoc('propertyCardFront'),
                ),
                const Divider(height: 32),
                DocumentSlot(
                  label: l10n.docPropertyCardBack,
                  filePath: _docs['propertyCardBack'],
                  onTap: () => _pickDoc('propertyCardBack'),
                ),
                const Divider(height: 32),
                DocumentSlot(
                  label: l10n.docSoat,
                  filePath: _docs['soat'],
                  onTap: () => _pickDoc('soat'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (vehicle.status != VehicleStatus.rented)
            WheelsPeButton(
              label: vehicle.status == VehicleStatus.maintenance
                  ? l10n.markAvailable
                  : l10n.markMaintenance,
              icon: vehicle.status == VehicleStatus.maintenance
                  ? Icons.check_circle_outline
                  : Icons.build_outlined,
              variant: vehicle.status == VehicleStatus.maintenance
                  ? WheelsPeButtonVariant.success
                  : WheelsPeButtonVariant.secondary,
              loading: _changingStatus,
              onPressed: _toggleStatus,
            ),
          const SizedBox(height: 28),
          Text(l10n.photoChecklist, style: AppTextStyles.title),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: WheelsPeButton(
                  label: l10n.startDelivery,
                  icon: Icons.vpn_key_outlined,
                  onPressed: () =>
                      context.push('/fleet/${vehicle.id}/checklist?tipo=PRE'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: WheelsPeButton(
                  label: l10n.registerReturn,
                  icon: Icons.assignment_return_outlined,
                  variant: WheelsPeButtonVariant.secondary,
                  onPressed: () =>
                      context.push('/fleet/${vehicle.id}/checklist?tipo=POST'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.reservationsSection, style: AppTextStyles.title),
              Semantics(
                label: l10n.seeAll,
                button: true,
                child: TextButton(
                  onPressed: () =>
                      context.push('/fleet/${vehicle.id}/reservations'),
                  child: Text(l10n.seeAll),
                ),
              ),
            ],
          ),
          reservationsAsync.when(
            loading: () => const ShimmerCard(height: 80),
            error: (_, _) => const SizedBox.shrink(),
            data: (reservations) {
              final active = reservations
                  .where((r) =>
                      r.status == ReservationStatus.pending ||
                      r.status == ReservationStatus.confirmed ||
                      r.status == ReservationStatus.inProgress)
                  .take(3)
                  .toList();
              if (active.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    l10n.noReservations,
                    style: AppTextStyles.bodySecondary,
                  ),
                );
              }
              return Column(
                children: [
                  for (final reservation in active) ...[
                    _MiniReservationTile(reservation: reservation),
                    const SizedBox(height: 8),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _PhotoCarousel extends StatelessWidget {
  final VehicleModel vehicle;

  const _PhotoCarousel({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    if (vehicle.photos.isEmpty) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Icon(
            Icons.directions_car_outlined,
            size: 72,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }
    return SizedBox(
      height: 220,
      child: PageView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: vehicle.photos.length,
        itemBuilder: (context, i) => Padding(
          padding: EdgeInsets.only(
            right: i < vehicle.photos.length - 1 ? 8 : 0,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Hero(
              tag: i == 0 ? 'vehicle-${vehicle.id}' : 'photo-${vehicle.id}-$i',
              child: CachedNetworkImage(
                imageUrl: vehicle.photos[i],
                fit: BoxFit.cover,
                placeholder: (_, _) => const ShimmerCard(height: 220),
                errorWidget: (_, _, _) => Container(
                  color: AppColors.surfaceElevated,
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: AppTextStyles.bodySecondary)),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: AppTextStyles.body,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniReservationTile extends StatelessWidget {
  final ReservationModel reservation;

  const _MiniReservationTile({required this.reservation});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final statusLabel = switch (reservation.status) {
      ReservationStatus.pending => l10n.statusPending,
      ReservationStatus.confirmed => l10n.statusConfirmed,
      ReservationStatus.inProgress => l10n.statusInProgress,
      ReservationStatus.completed => l10n.statusCompleted,
      ReservationStatus.cancelled => l10n.statusCancelled,
    };

    return WheelsPeCard(
      padding: const EdgeInsets.all(12),
      onTap: () => context.push('/reservations/${reservation.id}'),
      semanticsLabel:
          '${reservation.renterName}, ${CurrencyFormatter.format(reservation.totalAmount)}, $statusLabel',
      child: Row(
        children: [
          AvatarWidget(
            name: reservation.renterName,
            imageUrl: reservation.renterAvatar,
            radius: 20,
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
                Text(
                  '${DateFormatter.shortDate(reservation.startDate, locale)}'
                  ' → '
                  '${DateFormatter.shortDate(reservation.endDate, locale)}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          StatusBadge.fromStatus(reservation.status.apiValue, statusLabel),
        ],
      ),
    );
  }
}
