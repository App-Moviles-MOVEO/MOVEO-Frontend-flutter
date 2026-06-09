import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wheelspe_provider/core/utils/currency_formatter.dart';
import 'package:wheelspe_provider/core/utils/validators.dart';
import 'package:wheelspe_provider/features/fleet/data/vehicle_model.dart';
import 'package:wheelspe_provider/features/fleet/presentation/fleet_providers.dart';
import 'package:wheelspe_provider/l10n/generated/app_localizations.dart';
import 'package:wheelspe_provider/shared/widgets/error_state.dart';
import 'package:wheelspe_provider/shared/widgets/shimmer_card.dart';
import 'package:wheelspe_provider/shared/widgets/snackbars.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_button.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_text_field.dart';

class EditVehicleScreen extends ConsumerWidget {
  final String vehicleId;

  const EditVehicleScreen({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final vehicleAsync = ref.watch(vehicleDetailProvider(vehicleId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.edit)),
      body: vehicleAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: ShimmerCard(height: 300),
        ),
        error: (e, _) => ErrorState(
          onRetry: () => ref.invalidate(vehicleDetailProvider(vehicleId)),
        ),
        data: (vehicle) => _EditVehicleForm(vehicle: vehicle),
      ),
    );
  }
}

class _EditVehicleForm extends ConsumerStatefulWidget {
  final VehicleModel vehicle;

  const _EditVehicleForm({required this.vehicle});

  @override
  ConsumerState<_EditVehicleForm> createState() => _EditVehicleFormState();
}

class _EditVehicleFormState extends ConsumerState<_EditVehicleForm> {
  final _formKey = GlobalKey<FormState>();
  late final _modelController =
      TextEditingController(text: widget.vehicle.model);
  late final _priceController = TextEditingController(
    text: 'S/ ${widget.vehicle.pricePerDay.toStringAsFixed(0)}',
  );
  late final _descriptionController =
      TextEditingController(text: widget.vehicle.description);
  bool _saving = false;

  @override
  void dispose() {
    _modelController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(vehicleActionsProvider).update(widget.vehicle.id, {
        'model': _modelController.text.trim(),
        'pricePerDay': SolesInputFormatter.parse(_priceController.text),
        'description': _descriptionController.text.trim(),
      });
      if (!mounted) return;
      showSuccessSnackBar(
        context,
        AppLocalizations.of(context).profileUpdated,
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
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WheelsPeTextField(
              controller: _modelController,
              label: l10n.model,
              validator: (v) =>
                  Validators.isNotEmpty(v) ? null : l10n.requiredField,
            ),
            const SizedBox(height: 16),
            WheelsPeTextField(
              controller: _priceController,
              label: l10n.pricePerDay,
              keyboardType: TextInputType.number,
              inputFormatters: [SolesInputFormatter()],
              validator: (v) => SolesInputFormatter.parse(v ?? '') > 0
                  ? null
                  : l10n.requiredField,
            ),
            const SizedBox(height: 16),
            WheelsPeTextField(
              controller: _descriptionController,
              label: l10n.description,
              maxLines: 4,
              maxLength: 300,
            ),
            const SizedBox(height: 24),
            WheelsPeButton(
              label: l10n.save,
              loading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
