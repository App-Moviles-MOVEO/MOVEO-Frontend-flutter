import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';
import 'package:wheelspe_provider/core/utils/currency_formatter.dart';
import 'package:wheelspe_provider/core/utils/date_formatter.dart';
import 'package:wheelspe_provider/features/moderation/domain/anomaly_detector.dart';
import 'package:wheelspe_provider/features/moderation/presentation/moderation_providers.dart';
import 'package:wheelspe_provider/features/transactions/data/transaction_model.dart';
import 'package:wheelspe_provider/features/transactions/presentation/transactions_providers.dart';
import 'package:wheelspe_provider/l10n/generated/app_localizations.dart';
import 'package:wheelspe_provider/shared/widgets/empty_state.dart';
import 'package:wheelspe_provider/shared/widgets/error_state.dart';
import 'package:wheelspe_provider/shared/widgets/shimmer_card.dart';
import 'package:wheelspe_provider/shared/widgets/status_badge.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_card.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final transactionsAsync = ref.watch(myTransactionsProvider);
    final summaryAsync = ref.watch(walletSummaryProvider);
    final anomalies =
        ref.watch(financialAnomaliesProvider).value ?? const [];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.transactionsTitle)),
      body: transactionsAsync.when(
        loading: () => const ShimmerList(itemHeight: 84),
        error: (e, _) => ErrorState(
          onRetry: () => ref.invalidate(myTransactionsProvider),
        ),
        data: (transactions) {
          if (transactions.isEmpty) {
            return EmptyState(
              icon: Icons.account_balance_wallet_outlined,
              title: l10n.noTransactions,
              message: l10n.fleetEmptyBody,
            );
          }

          final sorted = [...transactions]
            ..sort((a, b) => b.date.compareTo(a.date));
          final byMonth = <DateTime, List<TransactionModel>>{};
          for (final t in sorted) {
            final key = DateTime(t.date.year, t.date.month);
            byMonth.putIfAbsent(key, () => []).add(t);
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myTransactionsProvider),
            child: ListView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.all(16),
              children: [
                // US40: monitoreo automático de anomalías financieras.
                if (anomalies.isNotEmpty) ...[
                  _AnomalyBanner(anomalies: anomalies),
                  const SizedBox(height: 16),
                ],
                // Header con total del mes
                WheelsPeCard(
                  glow: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.monthTotal, style: AppTextStyles.subtitle),
                      const SizedBox(height: 6),
                      Text(
                        CurrencyFormatter.format(
                          summaryAsync.value?.monthTotal ?? 0,
                        ),
                        style: AppTextStyles.amount,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                for (final entry in byMonth.entries) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      _capitalize(
                        DateFormatter.monthYear(
                          entry.key,
                          Localizations.localeOf(context).languageCode,
                        ),
                      ),
                      style: AppTextStyles.title,
                    ),
                  ),
                  for (final t in entry.value)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _TransactionTile(transaction: t),
                    ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  String _capitalize(String value) =>
      value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);
}

/// US40: banner que resume las anomalías financieras detectadas y revisadas
/// automáticamente. Al tocarlo muestra el detalle de cada anomalía.
class _AnomalyBanner extends StatelessWidget {
  final List<FinancialAnomaly> anomalies;

  const _AnomalyBanner({required this.anomalies});

  String _typeLabel(AppLocalizations l10n, AnomalyType type) => switch (type) {
        AnomalyType.amountOutlier => l10n.anomalyAmountOutlier,
        AnomalyType.duplicateCharge => l10n.anomalyDuplicateCharge,
        AnomalyType.refundSpike => l10n.anomalyRefundSpike,
      };

  void _showDetail(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.anomalyTitle, style: AppTextStyles.title),
              const SizedBox(height: 4),
              Text(l10n.anomalyAutoReviewed, style: AppTextStyles.caption),
              const SizedBox(height: 16),
              for (final a in anomalies)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.flag_outlined,
                      color: AppColors.warning),
                  title: Text(_typeLabel(l10n, a.type),
                      style: AppTextStyles.body),
                  subtitle: a.type == AnomalyType.refundSpike
                      ? Text(l10n.anomalyRefundCount(a.amount.toInt()),
                          style: AppTextStyles.caption)
                      : Text(
                          '${a.label} · ${CurrencyFormatter.format(a.amount)}',
                          style: AppTextStyles.caption,
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return WheelsPeCard(
      onTap: () => _showDetail(context),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.shield_moon_outlined,
                color: AppColors.warning),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.anomalyTitle, style: AppTextStyles.body),
                const SizedBox(height: 2),
                Text(
                  l10n.anomalyDetected(anomalies.length),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionModel transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final (icon, iconColor) = switch (transaction.type) {
      TransactionType.rental =>
        (Icons.directions_car_outlined, AppColors.primary),
      TransactionType.carpool => (Icons.groups_outlined, AppColors.accent),
      TransactionType.other =>
        (Icons.receipt_long_outlined, AppColors.textSecondary),
    };
    final statusLabel = switch (transaction.status) {
      TransactionStatus.completed => l10n.statusCompleted,
      TransactionStatus.pending => l10n.statusPending,
      TransactionStatus.refunded => l10n.statusRefunded,
    };

    return WheelsPeCard(
      padding: const EdgeInsets.all(14),
      onTap: () => context.push('/transactions/${transaction.id}'),
      semanticsLabel:
          '${transaction.description}, ${CurrencyFormatter.format(transaction.amount)}, $statusLabel',
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description.isEmpty
                      ? transaction.reference
                      : transaction.description,
                  style: AppTextStyles.body,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormatter.shortDate(transaction.date, locale),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(transaction.amount),
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              StatusBadge.fromStatus(
                transaction.status.apiValue,
                statusLabel,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
