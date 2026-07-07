import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';
import 'package:wheelspe_provider/core/storage/local_storage.dart';
import 'package:wheelspe_provider/features/fleet/presentation/fleet_providers.dart';
import 'package:wheelspe_provider/l10n/generated/app_localizations.dart';
import 'package:wheelspe_provider/shared/providers/user_provider.dart';
import 'package:wheelspe_provider/shared/widgets/snackbars.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_button.dart';

/// Punto de inspección del vehículo. Una sola foto general es suficiente.
/// La clave es estable para persistir en shared_preferences.
const _inspectionPoints = [
  'front',
];

const _minRequired = 1;

/// Checklist fotográfico pre/post alquiler.
/// [tipo] es "PRE" o "POST".
class ChecklistScreen extends ConsumerStatefulWidget {
  final String vehicleId;
  final String tipo;

  /// Alquiler asociado. Si viene, al finalizar se sube la inspección al
  /// backend (POST /rentals/{id}/inspections). Si es null, solo queda local.
  final String? reservationId;

  const ChecklistScreen({
    super.key,
    required this.vehicleId,
    required this.tipo,
    this.reservationId,
  });

  @override
  ConsumerState<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends ConsumerState<ChecklistScreen> {
  final _picker = ImagePicker();
  late Map<String, String> _photos;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Restaura un checklist en progreso si existe.
    _photos = ref
        .read(localStorageProvider)
        .loadChecklist(widget.vehicleId, widget.tipo);
  }

  String _pointLabel(AppLocalizations l10n, String key) => switch (key) {
        'front' => l10n.checkFront,
        'rightSide' => l10n.checkRightSide,
        'leftSide' => l10n.checkLeftSide,
        'rear' => l10n.checkRear,
        'driverInterior' => l10n.checkDriverInterior,
        'passengerInterior' => l10n.checkPassengerInterior,
        'dashboard' => l10n.checkDashboard,
        'trunk' => l10n.checkTrunk,
        'tires' => l10n.checkTires,
        _ => l10n.checkRoof,
      };

  Future<void> _capture(String point) async {
    // Abre la cámara directamente, como pide el flujo de inspección.
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (file == null || !mounted) return;
    setState(() => _photos[point] = file.path);
    await ref
        .read(localStorageProvider)
        .saveChecklist(widget.vehicleId, widget.tipo, _photos);
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    try {
      await ref
          .read(localStorageProvider)
          .saveChecklist(widget.vehicleId, widget.tipo, _photos);
      // Si el checklist pertenece a un alquiler, sube la inspección al
      // backend (US12). El id de usuario queda como autor del registro.
      final reservationId = widget.reservationId;
      if (reservationId != null && reservationId.isNotEmpty) {
        final ownerId = await ref.read(currentUserIdProvider.future);
        await ref.read(fleetRepositoryProvider).submitInspection(
              rentalId: reservationId,
              type: widget.tipo,
              photosByPoint: _photos,
              createdById: ownerId,
            );
      }
      if (!mounted) return;
      showSuccessSnackBar(
        context,
        AppLocalizations.of(context).checklistSaved,
      );
      context.pop();
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final done = _photos.length;
    final total = _inspectionPoints.length;
    final canFinish = done >= _minRequired;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.tipo == 'PRE'
              ? l10n.checklistTitlePre
              : l10n.checklistTitlePost,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.checklistSubtitle,
                    style: AppTextStyles.bodySecondary),
                const SizedBox(height: 12),
                Semantics(
                  label: l10n.checklistProgress(done, total),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: done / total,
                      minHeight: 8,
                      color: canFinish
                          ? AppColors.success
                          : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.checklistProgress(done, total),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              // Sin scrollbar visible, según el design system.
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.15,
              ),
              itemCount: _inspectionPoints.length,
              itemBuilder: (context, i) {
                final point = _inspectionPoints[i];
                final path = _photos[point];
                final label = _pointLabel(l10n, point);
                return _InspectionTile(
                  label: label,
                  photoPath: path,
                  retakeLabel: l10n.retakePhoto,
                  onTap: () => _capture(point),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: WheelsPeButton(
                label: l10n.checklistFinish,
                loading: _saving,
                onPressed: canFinish ? _finish : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InspectionTile extends StatelessWidget {
  final String label;
  final String? photoPath;
  final String retakeLabel;
  final VoidCallback onTap;

  const _InspectionTile({
    required this.label,
    required this.photoPath,
    required this.retakeLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoPath != null && File(photoPath!).existsSync();

    return Semantics(
      label: hasPhoto ? '$label: $retakeLabel' : '$label: tomar foto',
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasPhoto ? AppColors.success : AppColors.divider,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: hasPhoto
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(File(photoPath!), fit: BoxFit.cover),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        color: AppColors.background.withValues(alpha: 0.75),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                label,
                                style: AppTextStyles.caption,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(
                              Icons.refresh,
                              size: 16,
                              color: AppColors.accent,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Positioned(
                      top: 8,
                      right: 8,
                      child: Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 22,
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.photo_camera_outlined,
                      size: 36,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        label,
                        style: AppTextStyles.bodySecondary,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
