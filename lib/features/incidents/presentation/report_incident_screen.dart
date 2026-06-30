import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';
import 'package:wheelspe_provider/core/network/dio_client.dart';
import 'package:wheelspe_provider/features/incidents/data/incidents_remote_datasource.dart';
import 'package:wheelspe_provider/l10n/generated/app_localizations.dart';
import 'package:wheelspe_provider/shared/providers/user_provider.dart';
import 'package:wheelspe_provider/shared/widgets/snackbars.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_button.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_card.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_text_field.dart';

final incidentsDataSourceProvider = Provider<IncidentsRemoteDataSource>(
  (ref) => IncidentsRemoteDataSource(ref.watch(dioProvider)),
);

class ReportIncidentScreen extends ConsumerStatefulWidget {
  /// Reserva o ruta relacionada, pre-cargada cuando se navega desde
  /// el detalle de una reserva (/incidents/report?reservationId=...).
  final String? reservationId;
  final String? routeId;

  const ReportIncidentScreen({super.key, this.reservationId, this.routeId});

  @override
  ConsumerState<ReportIncidentScreen> createState() =>
      _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends ConsumerState<ReportIncidentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();

  IncidentType _type = IncidentType.damage;
  final List<XFile> _evidence = [];
  bool _submitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  String _typeLabel(AppLocalizations l10n, IncidentType type) =>
      switch (type) {
        IncidentType.damage => l10n.incidentDamage,
        IncidentType.accident => l10n.incidentAccident,
        IncidentType.lateness => l10n.incidentLateness,
        IncidentType.behavior => l10n.incidentBehavior,
        IncidentType.other => l10n.incidentOther,
      };

  Future<void> _addPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Cámara'),
              onTap: () =>
                  Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galería'),
              onTap: () =>
                  Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final photo = await _picker.pickImage(source: source, imageQuality: 80);
    if (photo != null && mounted) {
      setState(() => _evidence.add(photo));
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);
    try {
      final reporterId = await ref.read(currentUserIdProvider.future);
      if (reporterId == null) throw StateError('Sin sesión');
      await ref.read(incidentsDataSourceProvider).reportIncident(
            reporterId: reporterId,
            type: _type,
            description: _descriptionController.text.trim(),
            reservationId: widget.reservationId,
            routeId: widget.routeId,
            evidencePaths: _evidence.map((x) => x.path).toList(),
          );
      if (!mounted) return;
      showSuccessSnackBar(context, l10n.incidentReported);
      context.pop();
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.incidentTitle)),
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            // Reserva/ruta relacionada (auto-cargada si viene con parámetro)
            if (widget.reservationId != null || widget.routeId != null) ...[
              WheelsPeCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.link, color: AppColors.accent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${l10n.relatedReservation}: '
                        '${widget.reservationId ?? widget.routeId}',
                        style: AppTextStyles.bodySecondary,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Tipo de incidente
            Text(l10n.incidentType, style: AppTextStyles.subtitle),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final type in IncidentType.values)
                  Semantics(
                    label: _typeLabel(l10n, type),
                    button: true,
                    selected: _type == type,
                    child: ChoiceChip(
                      label: Text(_typeLabel(l10n, type)),
                      selected: _type == type,
                      selectedColor:
                          AppColors.primary.withValues(alpha: 0.25),
                      labelStyle: AppTextStyles.bodySecondary.copyWith(
                        color: _type == type
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                      side: BorderSide(
                        color: _type == type
                            ? AppColors.primary
                            : AppColors.divider,
                      ),
                      onSelected: (_) => setState(() => _type = type),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            WheelsPeTextField(
              controller: _descriptionController,
              label: l10n.incidentDescription,
              maxLines: 5,
              maxLength: 500,
              validator: (value) =>
                  (value == null || value.trim().isEmpty)
                      ? l10n.requiredField
                      : null,
            ),
            const SizedBox(height: 20),

            // Evidencia fotográfica
            Text(l10n.photoEvidence, style: AppTextStyles.subtitle),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                for (var i = 0; i < _evidence.length; i++)
                  Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_evidence[i].path),
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Semantics(
                          label: l10n.delete,
                          button: true,
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _evidence.removeAt(i)),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                Semantics(
                  label: l10n.addPhoto,
                  button: true,
                  child: InkWell(
                    onTap: _addPhoto,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: const Icon(
                        Icons.add_a_photo_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            WheelsPeButton(
              label: l10n.submitIncident,
              icon: Icons.send_outlined,
              loading: _submitting,
              onPressed: _submit,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
