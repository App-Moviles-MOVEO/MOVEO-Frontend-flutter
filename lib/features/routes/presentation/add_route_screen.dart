import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';
import 'package:wheelspe_provider/core/utils/currency_formatter.dart';
import 'package:wheelspe_provider/core/utils/date_formatter.dart';
import 'package:wheelspe_provider/core/utils/validators.dart';
import 'package:wheelspe_provider/features/routes/presentation/routes_providers.dart';
import 'package:wheelspe_provider/l10n/generated/app_localizations.dart';
import 'package:wheelspe_provider/shared/providers/user_provider.dart';
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

  // US17: recurrencia semanal.
  bool _recurring = false;
  final Set<int> _weekdays = {};
  int _weeks = 4;

  @override
  void initState() {
    super.initState();
    _weekdays.add(_date.weekday);
  }

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
    if (picked != null) {
      setState(() {
        _date = picked;
        // El día de salida siempre forma parte de la recurrencia.
        if (_recurring) _weekdays.add(picked.weekday);
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;
    if (_recurring && _weekdays.isEmpty) {
      showInfoSnackBar(context, AppLocalizations.of(context).pickAtLeastOneDay);
      return;
    }
    // El carpooling exige correo institucional (comunidad verificada).
    final user = await ref.read(currentUserProvider.future);
    if (!Validators.isInstitutionalEmail(user.email)) {
      if (mounted) {
        showInfoSnackBar(
          context,
          AppLocalizations.of(context).institutionalEmailRequired,
        );
      }
      return;
    }
    setState(() => _publishing = true);
    try {
      final ownerId = await ref.read(currentUserIdProvider.future);
      if (ownerId == null || ownerId.isEmpty) {
        throw StateError('No hay sesión activa');
      }
      final repo = ref.read(routesRepositoryProvider);
      final departureTime =
          '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}';
      final price = SolesInputFormatter.parse(_priceController.text);

      if (_recurring) {
        // US17: publica una ocurrencia por cada día seleccionado durante
        // las semanas indicadas.
        final created = await repo.publishRecurringRoutes(
          ownerId: ownerId,
          origin: _originController.text.trim(),
          destination: _destinationController.text.trim(),
          firstDate: _date,
          departureTime: departureTime,
          availableSeats: _seats,
          pricePerSeat: price,
          weekdays: _weekdays,
          weeks: _weeks,
          institutionalFilter: _upcOnly,
          womenOnly: _womenOnly,
          notes: _notesController.text.trim(),
        );
        ref.invalidate(myRoutesProvider);
        if (!mounted) return;
        showSuccessSnackBar(
          context,
          AppLocalizations.of(context).recurringRoutesPublished(created.length),
        );
        context.pop();
        return;
      }

      final route = await repo.publishRoute(
        ownerId: ownerId,
        origin: _originController.text.trim(),
        destination: _destinationController.text.trim(),
        departureDate: _date,
        departureTime: departureTime,
        availableSeats: _seats,
        pricePerSeat: price,
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
    final user = ref.watch(currentUserProvider).valueOrNull;
    final missingInstitutionalEmail =
        user != null && !Validators.isInstitutionalEmail(user.email);

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
              if (missingInstitutionalEmail) ...[
                WheelsPeCard(
                  child: Row(
                    children: [
                      const Icon(Icons.school_outlined,
                          color: AppColors.warning),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.institutionalEmailRequired,
                          style: AppTextStyles.bodySecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
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
              // US17: recurrencia semanal.
              SwitchListTile(
                value: _recurring,
                onChanged: (v) => setState(() {
                  _recurring = v;
                  if (v && _weekdays.isEmpty) _weekdays.add(_date.weekday);
                }),
                title: Text(l10n.repeatWeekly, style: AppTextStyles.body),
                subtitle:
                    Text(l10n.repeatWeeklyHint, style: AppTextStyles.caption),
                secondary:
                    const Icon(Icons.repeat, color: AppColors.accent),
                contentPadding: EdgeInsets.zero,
              ),
              if (_recurring) ...[
                const SizedBox(height: 8),
                Text(l10n.weekdaysLabel, style: AppTextStyles.subtitle),
                const SizedBox(height: 8),
                _WeekdaySelector(
                  selected: _weekdays,
                  locale: locale,
                  onToggle: (wd) => setState(() {
                    if (_weekdays.contains(wd)) {
                      _weekdays.remove(wd);
                    } else {
                      _weekdays.add(wd);
                    }
                  }),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.numberOfWeeksValue(_weeks),
                        style: AppTextStyles.subtitle,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      color: AppColors.primary,
                      onPressed:
                          _weeks > 1 ? () => setState(() => _weeks--) : null,
                    ),
                    Text('$_weeks', style: AppTextStyles.title),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      color: AppColors.primary,
                      onPressed:
                          _weeks < 12 ? () => setState(() => _weeks++) : null,
                    ),
                  ],
                ),
              ],
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

/// Selector de días de la semana (US17). 1 = lunes … 7 = domingo.
class _WeekdaySelector extends StatelessWidget {
  final Set<int> selected;
  final String locale;
  final ValueChanged<int> onToggle;

  const _WeekdaySelector({
    required this.selected,
    required this.locale,
    required this.onToggle,
  });

  String _label(int weekday) {
    // 2024-01-01 fue lunes: DateTime(2024, 1, weekday) da el día correcto.
    return DateFormat.E(locale).format(DateTime(2024, 1, weekday));
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var wd = 1; wd <= 7; wd++)
          FilterChip(
            label: Text(_label(wd)),
            selected: selected.contains(wd),
            showCheckmark: false,
            onSelected: (_) => onToggle(wd),
          ),
      ],
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
