import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';
import 'package:wheelspe_provider/core/utils/currency_formatter.dart';
import 'package:wheelspe_provider/core/utils/date_formatter.dart';
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
