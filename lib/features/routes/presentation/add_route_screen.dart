import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';
import 'package:wheelspe_provider/core/utils/currency_formatter.dart';
import 'package:wheelspe_provider/core/utils/date_formatter.dart';
import 'package:wheelspe_provider/core/utils/validators.dart';
import 'package:wheelspe_provider/features/routes/presentation/routes_providers.dart';
import 'package:wheelspe_provider/l10n/generated/app_localizations.dart';
import 'package:wheelspe_provider/shared/widgets/snackbars.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_button.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_card.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_text_field.dart';

class AddRouteScreen extends ConsumerStatefulWidget {
  const AddRouteScreen({super.key});

  @override
  ConsumerState<AddRouteScreen> createState() => _AddRouteScreenState();
}

class _AddRouteScreenState extends ConsumerState<AddRouteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _date = DateTime.now();
  TimeOfDay _time = const TimeOfDay(hour: 7, minute: 0);
  int _seats = 3;
  bool _upcOnly = false;
  bool _womenOnly = false;
  bool _publishing = false;

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _publishing = true);
    try {
      final route = await ref.read(routesRepositoryProvider).publishRoute(
            origin: _originController.text.trim(),
            destination: _destinationController.text.trim(),
            departureDate: _date,
            departureTime:
                '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}',
            availableSeats: _seats,
            pricePerSeat: SolesInputFormatter.parse(_priceController.text),
            institutionalFilter: _upcOnly,
            womenOnly: _womenOnly,
            notes: _notesController.text.trim(),
          );
      ref.invalidate(myRoutesProvider);
      if (!mounted) return;
      showSuccessSnackBar(context, AppLocalizations.of(context).routePublished);
      if (route.id.isNotEmpty) {
        context.pushReplacement('/routes/${route.id}');
      } else {
        context.pop();
      }
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addRouteTitle)),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WheelsPeTextField(
                controller: _originController,
                label: l10n.origin,
                prefix: const Icon(Icons.trip_origin, size: 18),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    Validators.isNotEmpty(v) ? null : l10n.requiredField,
              ),
              const SizedBox(height: 16),
              WheelsPeTextField(
                controller: _destinationController,
                label: l10n.destination,
                prefix: const Icon(Icons.place_outlined, size: 20),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    Validators.isNotEmpty(v) ? null : l10n.requiredField,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _PickerTile(
                      label: l10n.departureDate,
                      value: DateFormatter.shortDate(_date, locale),
                      icon: Icons.calendar_today_outlined,
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PickerTile(
                      label: l10n.departureTime,
                      value: _time.format(context),
                      icon: Icons.access_time,
                      onTap: _pickTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(l10n.availableSeats, style: AppTextStyles.subtitle),
              const SizedBox(height: 8),
              WheelsPeCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Semantics(
                      label: 'Quitar asiento',
                      button: true,
                      child: IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        color: AppColors.primary,
                        onPressed: _seats > 1
                            ? () => setState(() => _seats--)
                            : null,
                      ),
                    ),
                    Text('$_seats', style: AppTextStyles.headline),
                    Semantics(
                      label: 'Agregar asiento',
                      button: true,
                      child: IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        color: AppColors.primary,
                        onPressed: _seats < 7
                            ? () => setState(() => _seats++)
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              WheelsPeTextField(
                controller: _priceController,
                label: l10n.pricePerSeat,
                hint: 'S/ 10',
                keyboardType: TextInputType.number,
                inputFormatters: [SolesInputFormatter()],
                validator: (v) => SolesInputFormatter.parse(v ?? '') > 0
                    ? null
                    : l10n.requiredField,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                value: _upcOnly,
                onChanged: (v) => setState(() => _upcOnly = v),
                title: Text(l10n.upcOnly, style: AppTextStyles.body),
                secondary:
                    const Icon(Icons.school_outlined, color: AppColors.accent),
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                value: _womenOnly,
                onChanged: (v) => setState(() => _womenOnly = v),
                title: Text(l10n.womenOnly, style: AppTextStyles.body),
                secondary:
                    const Icon(Icons.female, color: AppColors.accent),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),
              WheelsPeTextField(
                controller: _notesController,
                label: l10n.additionalNotes,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),
              WheelsPeButton(
                label: l10n.publishRouteButton,
                loading: _publishing,
                onPressed: _publish,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _PickerTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $value',
      button: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.subtitle),
          const SizedBox(height: 8),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      value,
                      style: AppTextStyles.body,
                      overflow: TextOverflow.ellipsis,
                    ),
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
