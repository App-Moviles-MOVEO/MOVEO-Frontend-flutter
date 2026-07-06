import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';
import 'package:wheelspe_provider/core/utils/currency_formatter.dart';
import 'package:wheelspe_provider/features/promotions/data/promo_model.dart';
import 'package:wheelspe_provider/features/promotions/presentation/promotions_providers.dart';
import 'package:wheelspe_provider/l10n/generated/app_localizations.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_button.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_card.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_text_field.dart';

/// US27: aplica/valida un cupón sobre un monto y muestra el descuento.
/// Ejecuta el mismo motor puro que usaría el arrendatario al pagar.
class ApplyCouponScreen extends ConsumerStatefulWidget {
  const ApplyCouponScreen({super.key});

  @override
  ConsumerState<ApplyCouponScreen> createState() => _ApplyCouponScreenState();
}

class _ApplyCouponScreenState extends ConsumerState<ApplyCouponScreen> {
  final _codeController = TextEditingController();
  final _amountController = TextEditingController();
  final _reputationController = TextEditingController();
  CouponOutcome? _outcome;

  @override
  void dispose() {
    _codeController.dispose();
    _amountController.dispose();
    _reputationController.dispose();
    super.dispose();
  }

  void _apply() {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    final reputation =
        double.tryParse(_reputationController.text.trim()) ?? 0;
    final result = ref.read(applyCouponProvider)(
      _codeController.text,
      amount,
      reputation: reputation,
    );
    setState(() => _outcome = result);
    FocusScope.of(context).unfocus();
  }

  String _errorFor(AppLocalizations l10n, CouponStatus status) =>
      switch (status) {
        CouponStatus.notFound => l10n.couponNotFound,
        CouponStatus.notStarted => l10n.couponNotStarted,
        CouponStatus.expired => l10n.couponExpired,
        CouponStatus.disabled => l10n.couponDisabled,
        CouponStatus.reputationTooLow => l10n.couponReputationTooLow,
        CouponStatus.applied => '',
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.applyCoupon)),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.applyCouponSubtitle,
                style: AppTextStyles.bodySecondary),
            const SizedBox(height: 20),
            WheelsPeTextField(
              controller: _codeController,
              label: l10n.promoCode,
              hint: l10n.promoCodeHint,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
              ],
            ),
            const SizedBox(height: 16),
            WheelsPeTextField(
              controller: _amountController,
              label: l10n.couponAmount,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
            ),
            const SizedBox(height: 16),
            WheelsPeTextField(
              controller: _reputationController,
              label: l10n.couponReputationOptional,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
            ),
            const SizedBox(height: 24),
            WheelsPeButton(label: l10n.couponApply, onPressed: _apply),
            const SizedBox(height: 20),
            if (_outcome != null) _buildResult(l10n, _outcome!),
          ],
        ),
      ),
    );
  }

  Widget _buildResult(AppLocalizations l10n, CouponOutcome outcome) {
    if (!outcome.status.isSuccess) {
      return WheelsPeCard(
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error),
            const SizedBox(width: 12),
            Expanded(
              child: Text(_errorFor(l10n, outcome.status),
                  style: AppTextStyles.body),
            ),
          ],
        ),
      );
    }
    return WheelsPeCard(
      glow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.success),
              const SizedBox(width: 8),
              Text(outcome.promo?.code ?? '',
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.success,
                  )),
            ],
          ),
          const SizedBox(height: 12),
          _row(l10n.couponAmount,
              CurrencyFormatter.format(outcome.finalAmount + outcome.discount)),
          _row('${l10n.promoValue} (-)',
              '- ${CurrencyFormatter.format(outcome.discount)}',
              color: AppColors.error),
          const Divider(),
          _row(l10n.netReceived, CurrencyFormatter.format(outcome.finalAmount),
              bold: true, color: AppColors.success),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false, Color? color}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: AppTextStyles.bodySecondary),
            ),
            Text(
              value,
              style: AppTextStyles.body.copyWith(
                fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      );
}
