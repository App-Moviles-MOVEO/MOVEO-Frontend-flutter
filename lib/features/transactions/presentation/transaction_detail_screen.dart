import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';
import 'package:wheelspe_provider/core/utils/currency_formatter.dart';
import 'package:wheelspe_provider/core/services/receipt_service.dart';
import 'package:wheelspe_provider/core/utils/date_formatter.dart';
import 'package:wheelspe_provider/features/transactions/data/transaction_model.dart';
import 'package:wheelspe_provider/features/transactions/presentation/transactions_providers.dart';
import 'package:wheelspe_provider/shared/providers/user_provider.dart';
import 'package:wheelspe_provider/l10n/generated/app_localizations.dart';
import 'package:wheelspe_provider/shared/widgets/avatar_widget.dart';
import 'package:wheelspe_provider/shared/widgets/error_state.dart';
import 'package:wheelspe_provider/shared/widgets/shimmer_card.dart';
import 'package:wheelspe_provider/shared/widgets/snackbars.dart';
import 'package:wheelspe_provider/shared/widgets/status_badge.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_button.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_card.dart';

class TransactionDetailScreen extends ConsumerWidget {
  final String transactionId;

  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final transactionAsync =
        ref.watch(transactionDetailProvider(transactionId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.transactionDetailTitle)),
      body: transactionAsync.when(
        loading: () => const ShimmerList(count: 3, itemHeight: 140),
        error: (e, _) => ErrorState(
          onRetry: () =>
              ref.invalidate(transactionDetailProvider(transactionId)),
        ),
        data: (transaction) => _TransactionDetailBody(transaction: transaction),
      ),
    );
  }
}

class _TransactionDetailBody extends ConsumerStatefulWidget {
  final TransactionModel transaction;

  const _TransactionDetailBody({required this.transaction});

  @override
  ConsumerState<_TransactionDetailBody> createState() =>
      _TransactionDetailBodyState();
}

class _TransactionDetailBodyState
    extends ConsumerState<_TransactionDetailBody> {
  bool _busy = false;

  TransactionModel get transaction => widget.transaction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final statusLabel = switch (transaction.status) {
      TransactionStatus.completed => l10n.statusCompleted,
      TransactionStatus.pending => l10n.statusPending,
      TransactionStatus.refunded => l10n.statusRefunded,
    };

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        // Resumen de montos
        WheelsPeCard(
          glow: transaction.status == TransactionStatus.completed,
          child: Column(
            children: [
              StatusBadge.fromStatus(
                transaction.status.apiValue,
                statusLabel,
              ),
              const SizedBox(height: 12),
              Text(
                CurrencyFormatter.format(transaction.amount),
                style: AppTextStyles.amount.copyWith(fontSize: 34),
              ),
              const SizedBox(height: 4),
              Text(
                transaction.description,
                style: AppTextStyles.bodySecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Divider(),
              _row(
                l10n.totalAmount,
                CurrencyFormatter.format(transaction.amount),
              ),
              _row(
                '${l10n.platformFee} '
                '(${transaction.feePercent.toStringAsFixed(0)}%)',
                '- ${CurrencyFormatter.format(transaction.platformFee)}',
                valueColor: AppColors.error,
              ),
              _row(
                l10n.netReceived,
                CurrencyFormatter.format(transaction.netAmount),
                bold: true,
                valueColor: AppColors.success,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Información del pagador y referencia
        WheelsPeCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (transaction.payerName.isNotEmpty) ...[
                Row(
                  children: [
                    AvatarWidget(
                      imageUrl: transaction.payerAvatar,
                      name: transaction.payerName,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        transaction.payerName,
                        style: AppTextStyles.body,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
              ],
              _row(
                l10n.selectDate,
                DateFormatter.fullDateTime(transaction.date, locale),
              ),
              if (transaction.reference.isNotEmpty)
                _row(l10n.reference, transaction.reference),
            ],
          ),
        ),
        const SizedBox(height: 24),

        WheelsPeButton(
          label: l10n.downloadReceipt,
          icon: Icons.download_outlined,
          variant: WheelsPeButtonVariant.secondary,
          loading: _busy,
          onPressed: _downloadReceipt,
        ),
        if (transaction.refundable) ...[
          const SizedBox(height: 12),
          WheelsPeButton(
            label: l10n.requestRefund,
            icon: Icons.undo,
            variant: WheelsPeButtonVariant.danger,
            loading: _busy,
            onPressed: _requestRefund,
          ),
        ],
        const SizedBox(height: 32),
      ],
    );
  }

  Future<void> _downloadReceipt() async {
    setState(() => _busy = true);
    try {
      // Comprobante generado en el dispositivo (el backend no tiene /invoices).
      final providerName = ref.read(currentUserProvider).value?.fullName;
      await ref
          .read(receiptServiceProvider)
          .shareReceipt(transaction, providerName: providerName);
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _requestRefund() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await ref
          .read(transactionActionsProvider)
          .requestRefund(transaction.id);
      if (mounted) showSuccessSnackBar(context, l10n.refundProcessed);
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _row(
    String label,
    String value, {
    bool bold = false,
    Color? valueColor,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: AppTextStyles.bodySecondary),
            ),
            Text(
              value,
              style: AppTextStyles.body.copyWith(
                fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                color: valueColor,
              ),
            ),
          ],
        ),
      );
}
