import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';
import 'package:wheelspe_provider/core/utils/currency_formatter.dart';
import 'package:wheelspe_provider/core/utils/validators.dart';
import 'package:wheelspe_provider/features/fleet/data/vehicle_model.dart';
import 'package:wheelspe_provider/features/fleet/presentation/fleet_providers.dart';
import 'package:wheelspe_provider/l10n/generated/app_localizations.dart';
import 'package:wheelspe_provider/shared/widgets/document_slot.dart';
import 'package:wheelspe_provider/shared/widgets/snackbars.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_button.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_card.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_text_field.dart';

const _brands = ['Toyota', 'Hyundai', 'Kia', 'Nissan', 'Otros'];
const _categories = ['Sedán', 'SUV', 'Hatchback', 'Pickup', 'Van'];
const _maxPhotos = 10;
const _minPhotos = 3;

/// Centro de Lima como ubicación inicial del marker.
const _limaCenter = LatLng(-12.0464, -77.0428);

class AddVehicleScreen extends ConsumerStatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  ConsumerState<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends ConsumerState<AddVehicleScreen> {
  int _step = 0;
  bool _publishing = false;

  // Step 1 — datos básicos
  final _basicFormKey = GlobalKey<FormState>();
  String _brand = _brands.first;
  final _modelController = TextEditingController();
  int _year = 2024;
  final _plateController = TextEditingController();
  String _category = _categories.first;

  // Step 2 — precio y disponibilidad
  final _priceFormKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  LatLng _location = _limaCenter;

  // Step 3 — fotos
  final _picker = ImagePicker();
  final List<XFile> _photos = [];

  // Step 4 — documentos de propiedad (US05)
  XFile? _propertyCardFront;
  XFile? _propertyCardBack;
  XFile? _soat;

  @override
  void dispose() {
    _modelController.dispose();
    _plateController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool _validateStep() {
    switch (_step) {
      case 0:
        return _basicFormKey.currentState!.validate();
      case 1:
        return _priceFormKey.currentState!.validate();
      case 2:
        if (_photos.length < _minPhotos) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).minPhotosRequired),
            ),
          );
          return false;
        }
        return true;
      case 3:
        if (_propertyCardFront == null ||
            _propertyCardBack == null ||
            _soat == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).documentsRequired),
            ),
          );
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  Future<void> _addPhoto() async {
    final files = await _picker.pickMultiImage(imageQuality: 80);
    if (files.isEmpty || !mounted) return;
    setState(() {
      _photos.addAll(files.take(_maxPhotos - _photos.length));
    });
  }

  Future<void> _pickDocument(void Function(XFile) assign) async {
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
    if (file != null && mounted) setState(() => assign(file));
  }

  Future<void> _publish() async {
    setState(() => _publishing = true);
    try {
      final vehicle = VehicleModel(
        id: '',
        brand: _brand,
        model: _modelController.text.trim(),
        year: _year,
        plate: _plateController.text.trim().toUpperCase(),
        category: _category,
        pricePerDay: SolesInputFormatter.parse(_priceController.text),
        description: _descriptionController.text.trim(),
        lat: _location.latitude,
        lng: _location.longitude,
        // En un backend real las fotos se subirían como multipart;
        // aquí enviamos las rutas locales como referencia.
        photos: _photos.map((f) => f.path).toList(),
        documents: {
          if (_propertyCardFront != null)
            'propertyCardFront': _propertyCardFront!.path,
          if (_propertyCardBack != null)
            'propertyCardBack': _propertyCardBack!.path,
          if (_soat != null) 'soat': _soat!.path,
        },
      );
      await ref.read(vehicleActionsProvider).publish(vehicle);
      if (!mounted) return;
      await _showSuccessAndExit();
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  Future<void> _showSuccessAndExit() async {
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future<void>.delayed(const Duration(milliseconds: 1600), () {
          if (context.mounted) Navigator.of(context).pop();
        });
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) =>
                      Transform.scale(scale: value, child: child),
                  child: const Icon(
                    Icons.check_circle,
                    size: 72,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 16),
                Text(l10n.vehiclePublished, style: AppTextStyles.title),
              ],
            ),
          ),
        );
      },
    );
    if (mounted) context.go('/fleet');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLast = _step == 4;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addVehicleTitle)),
      body: Stepper(
        physics: const BouncingScrollPhysics(),
        currentStep: _step,
        type: StepperType.vertical,
        onStepContinue: () {
          if (!_validateStep()) return;
          if (isLast) {
            _publish();
          } else {
            setState(() => _step++);
          }
        },
        onStepCancel:
            _step == 0 ? null : () => setState(() => _step--),
        controlsBuilder: (context, details) => Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Row(
            children: [
              Expanded(
                child: WheelsPeButton(
                  label: isLast ? l10n.publishVehicleButton : l10n.next,
                  loading: _publishing,
                  onPressed: details.onStepContinue,
                ),
              ),
              if (details.onStepCancel != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: WheelsPeButton(
                    label: l10n.back,
                    variant: WheelsPeButtonVariant.secondary,
                    onPressed: details.onStepCancel,
                  ),
                ),
              ],
            ],
          ),
        ),
        steps: [
          Step(
            title: Text(l10n.stepBasicData, style: AppTextStyles.body),
            isActive: _step >= 0,
            content: _buildBasicStep(l10n),
          ),
          Step(
            title:
                Text(l10n.stepPriceAvailability, style: AppTextStyles.body),
            isActive: _step >= 1,
            content: _buildPriceStep(l10n),
          ),
          Step(
            title: Text(l10n.stepPhotos, style: AppTextStyles.body),
            isActive: _step >= 2,
            content: _buildPhotosStep(l10n),
          ),
          Step(
            title: Text(l10n.stepDocuments, style: AppTextStyles.body),
            isActive: _step >= 3,
            content: _buildDocumentsStep(l10n),
          ),
          Step(
            title: Text(l10n.stepConfirmation, style: AppTextStyles.body),
            isActive: _step >= 4,
            content: _buildSummaryStep(l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicStep(AppLocalizations l10n) {
    return Form(
      key: _basicFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.brand, style: AppTextStyles.subtitle),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _brand,
            dropdownColor: AppColors.surfaceElevated,
            items: [
              for (final brand in _brands)
                DropdownMenuItem(value: brand, child: Text(brand)),
            ],
            onChanged: (v) => setState(() => _brand = v ?? _brand),
          ),
          const SizedBox(height: 16),
          WheelsPeTextField(
            controller: _modelController,
            label: l10n.model,
            textCapitalization: TextCapitalization.words,
            validator: (v) =>
                Validators.isNotEmpty(v) ? null : l10n.requiredField,
          ),
          const SizedBox(height: 16),
          Text(l10n.year, style: AppTextStyles.subtitle),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            initialValue: _year,
            dropdownColor: AppColors.surfaceElevated,
            items: [
              for (var y = 2024; y >= 2000; y--)
                DropdownMenuItem(value: y, child: Text('$y')),
            ],
            onChanged: (v) => setState(() => _year = v ?? _year),
          ),
          const SizedBox(height: 16),
          WheelsPeTextField(
            controller: _plateController,
            label: l10n.plate,
            hint: 'ABC-123',
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9-]')),
              LengthLimitingTextInputFormatter(7),
              TextInputFormatter.withFunction(
                (oldValue, newValue) =>
                    newValue.copyWith(text: newValue.text.toUpperCase()),
              ),
            ],
            validator: (v) =>
                Validators.isValidPlate(v ?? '') ? null : l10n.invalidPlate,
          ),
          const SizedBox(height: 16),
          Text(l10n.category, style: AppTextStyles.subtitle),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _category,
            dropdownColor: AppColors.surfaceElevated,
            items: [
              for (final c in _categories)
                DropdownMenuItem(value: c, child: Text(c)),
            ],
            onChanged: (v) => setState(() => _category = v ?? _category),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceStep(AppLocalizations l10n) {
    return Form(
      key: _priceFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WheelsPeTextField(
            controller: _priceController,
            label: l10n.pricePerDay,
            hint: 'S/ 120',
            keyboardType: TextInputType.number,
            inputFormatters: [SolesInputFormatter()],
            validator: (v) => SolesInputFormatter.parse(v ?? '') > 0
                ? null
                : l10n.requiredField,
          ),
          const SizedBox(height: 16),
          Text(l10n.deliveryLocation, style: AppTextStyles.subtitle),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 220,
              child: GoogleMap(
                initialCameraPosition:
                    const CameraPosition(target: _limaCenter, zoom: 13),
                markers: {
                  Marker(
                    markerId: const MarkerId('delivery'),
                    position: _location,
                    draggable: true,
                    onDragEnd: (pos) => setState(() => _location = pos),
                  ),
                },
                onTap: (pos) => setState(() => _location = pos),
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
              ),
            ),
          ),
          const SizedBox(height: 16),
          WheelsPeTextField(
            controller: _descriptionController,
            label: l10n.description,
            hint: l10n.descriptionHint,
            maxLines: 4,
            maxLength: 300,
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosStep(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.minPhotosRequired, style: AppTextStyles.bodySecondary),
            Text(
              l10n.photosCount(_photos.length, _maxPhotos),
              style: AppTextStyles.caption.copyWith(
                color: _photos.length >= _minPhotos
                    ? AppColors.success
                    : AppColors.warning,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount:
              _photos.length + (_photos.length < _maxPhotos ? 1 : 0),
          itemBuilder: (context, i) {
            if (i == _photos.length) {
              return Semantics(
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
              );
            }
            return Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(_photos[i].path), fit: BoxFit.cover),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Semantics(
                    label: l10n.delete,
                    button: true,
                    child: InkWell(
                      onTap: () => setState(() => _photos.removeAt(i)),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.background,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildDocumentsStep(AppLocalizations l10n) {
    final docs = <(String, XFile?, void Function(XFile))>[
      (
        l10n.docPropertyCardFront,
        _propertyCardFront,
        (f) => _propertyCardFront = f,
      ),
      (
        l10n.docPropertyCardBack,
        _propertyCardBack,
        (f) => _propertyCardBack = f,
      ),
      (l10n.docSoat, _soat, (f) => _soat = f),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.documentsIntro, style: AppTextStyles.bodySecondary),
        const SizedBox(height: 12),
        WheelsPeCard(
          child: Column(
            children: [
              for (final (i, (label, file, assign)) in docs.indexed) ...[
                if (i > 0) const Divider(height: 32),
                DocumentSlot(
                  label: label,
                  file: file,
                  onTap: () => _pickDocument(assign),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryStep(AppLocalizations l10n) {
    final rows = <(String, String)>[
      (l10n.brand, _brand),
      (l10n.model, _modelController.text),
      (l10n.year, '$_year'),
      (l10n.plate, _plateController.text.toUpperCase()),
      (l10n.category, _category),
      (l10n.pricePerDay, _priceController.text),
      (
        l10n.location,
        '${_location.latitude.toStringAsFixed(4)}, '
            '${_location.longitude.toStringAsFixed(4)}'
      ),
      (l10n.stepPhotos, '${_photos.length}'),
      (
        l10n.stepDocuments,
        l10n.documentsCount(
          [_propertyCardFront, _propertyCardBack, _soat]
              .whereType<XFile>()
              .length,
          3,
        ),
      ),
    ];
    return WheelsPeCard(
      child: Column(
        children: [
          for (final (label, value) in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child:
                        Text(label, style: AppTextStyles.bodySecondary),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      value,
                      style: AppTextStyles.body,
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
