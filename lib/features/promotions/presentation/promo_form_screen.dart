import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';
import 'package:wheelspe_provider/core/utils/date_formatter.dart';
import 'package:wheelspe_provider/features/promotions/data/promo_model.dart';
import 'package:wheelspe_provider/features/promotions/presentation/promotions_providers.dart';
import 'package:wheelspe_provider/l10n/generated/app_localizations.dart';
import 'package:wheelspe_provider/shared/widgets/snackbars.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_button.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_text_field.dart';

/// US34: alta de una oferta promocional temporal. El campo de reputación
/// mínima la convierte en recompensa para usuarios de alta reputación (US29).
class PromoFormScreen extends ConsumerStatefulWidget {
  const PromoFormScreen({super.key});

  @override
  ConsumerState<PromoFormScreen> createState() => _PromoFormScreenState();
}

class _PromoFormScreenState extends ConsumerState<PromoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _titleController = TextEditingController();
  final _valueController = TextEditingController();
  DiscountType _type = DiscountType.percent;
  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now().add(const Duration(days: 30));
  double _minReputation = 0;

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final initial = isStart ? _start : _end;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
        if (_end.isBefore(_start)) _end = _start;
      } else {
        _end = picked.isBefore(_start) ? _start : picked;
      }
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    final value = double.tryParse(_valueController.text.trim()) ?? 0;
    final offer = PromoOffer(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      code: _codeController.text.trim().toUpperCase(),
      title: _titleController.text.trim(),
      type: _type,
      value: value,
      startDate: _start,
      endDate: _end,
      minReputation: _minReputation,
    );
    await ref.read(promotionsProvider.notifier).add(offer);
    if (!mounted) return;
    showSuccessSnackBar(context, l10n.promoSaved);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addPromotion)),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WheelsPeTextField(
                controller: _codeController,
                label: l10n.promoCode,
                hint: l10n.promoCodeHint,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                  LengthLimitingTextInputFormatter(16),
                ],
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? l10n.requiredField : null,
              ),
              const SizedBox(height: 16),
              WheelsPeTextField(
                controller: _titleController,
                label: l10n.promoTitle,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 20),
              Text(l10n.promoDiscountType, style: AppTextStyles.subtitle),
              const SizedBox(height: 8),
              SegmentedButton<DiscountType>(
                segments: [
                  ButtonSegment(
                    value: DiscountType.percent,
                    label: Text(l10n.promoPercent),
                    icon: const Icon(Icons.percent, size: 16),
                  ),
                  ButtonSegment(
                    value: DiscountType.fixed,
                    label: Text(l10n.promoFixed),
                    icon: const Icon(Icons.attach_money, size: 16),
                  ),
                ],
                selected: {_type},
                showSelectedIcon: false,
                onSelectionChanged: (s) => setState(() => _type = s.first),
              ),
              const SizedBox(height: 16),
              WheelsPeTextField(
                controller: _valueController,
                label: l10n.promoValue,
                hint: _type == DiscountType.percent ? '20' : 'S/ 15',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                validator: (v) {
                  final n = double.tryParse((v ?? '').trim()) ?? 0;
                  if (n <= 0) return l10n.requiredField;
                  if (_type == DiscountType.percent && n > 100) {
                    return '≤ 100%';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _DateTile(
                      label: l10n.promoStart,
                      value: DateFormatter.shortDate(_start, locale),
                      onTap: () => _pickDate(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateTile(
                      label: l10n.promoEnd,
                      value: DateFormatter.shortDate(_end, locale),
                      onTap: () => _pickDate(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // US29: recompensa por reputación.
              Text(l10n.promoMinReputation, style: AppTextStyles.subtitle),
              Text(l10n.promoMinReputationHint, style: AppTextStyles.caption),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _minReputation,
                      min: 0,
                      max: 5,
                      divisions: 10,
                      label: _minReputation.toStringAsFixed(1),
                      onChanged: (v) => setState(() => _minReputation = v),
                    ),
                  ),
                  SizedBox(
                    width: 44,
                    child: Text(
                      _minReputation == 0
                          ? '—'
                          : '${_minReputation.toStringAsFixed(1)}★',
                      style: AppTextStyles.body,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              WheelsPeButton(label: l10n.addPromotion, onPressed: _save),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 16),
            const SizedBox(width: 8),
            Text(value, style: AppTextStyles.body),
          ],
        ),
      ),
    );
  }
}
