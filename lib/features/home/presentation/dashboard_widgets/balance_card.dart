import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';
import 'package:wheelspe_provider/core/utils/currency_formatter.dart';
import 'package:wheelspe_provider/features/transactions/presentation/transactions_providers.dart';
import 'package:wheelspe_provider/l10n/generated/app_localizations.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_card.dart';

/// Resumen financiero del dashboard: balance, semana vs mes y
/// mini gráfico de barras de los últimos 7 días.
class BalanceCard extends StatelessWidget {
  final WalletSummary summary;

  const BalanceCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final maxDay = summary.last7Days
        .fold<double>(0, (max, v) => v > max ? v : max);

    return WheelsPeCard(
      glow: true,
      semanticsLabel:
          '${l10n.availableBalance}: ${CurrencyFormatter.format(summary.balance)}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.availableBalance, style: AppTextStyles.subtitle),
          const SizedBox(height: 6),
          Text(
            CurrencyFormatter.format(summary.balance),
            style: AppTextStyles.amount.copyWith(fontSize: 32),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _PeriodChip(
                label: l10n.thisWeek,
                amount: summary.weekTotal,
              ),
              const SizedBox(width: 10),
              _PeriodChip(
                label: l10n.thisMonth,
                amount: summary.monthTotal,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(l10n.last7Days, style: AppTextStyles.caption),
          const SizedBox(height: 10),
          if (maxDay <= 0)
            SizedBox(
              height: 90,
              child: Center(
                child: Text(
                  l10n.noEarnings7Days,
                  style: AppTextStyles.bodySecondary,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            SizedBox(
            height: 90,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxDay <= 0 ? 1 : maxDay * 1.2,
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        final day = DateTime.now().subtract(
                          Duration(days: 6 - value.toInt()),
                        );
                        const names = [
                          'L', 'M', 'X', 'J', 'V', 'S', 'D',
                        ];
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            names[day.weekday - 1],
                            style: AppTextStyles.caption,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.surfaceElevated,
                    getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                      CurrencyFormatter.format(rod.toY),
                      AppTextStyles.caption.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < summary.last7Days.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: summary.last7Days[i],
                          width: 14,
                          borderRadius: BorderRadius.circular(4),
                          gradient: const LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [AppColors.primaryDark, AppColors.accent],
                          ),
                        ),
                      ],
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

class _PeriodChip extends StatelessWidget {
  final String label;
  final double amount;

  const _PeriodChip({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.caption),
            const SizedBox(height: 4),
            Text(
              CurrencyFormatter.format(amount),
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
