import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';
import 'package:wheelspe_provider/core/utils/currency_formatter.dart';
import 'package:wheelspe_provider/core/utils/date_formatter.dart';
import 'package:wheelspe_provider/features/promotions/data/promo_model.dart';
import 'package:wheelspe_provider/features/promotions/presentation/promotions_providers.dart';
import 'package:wheelspe_provider/l10n/generated/app_localizations.dart';
import 'package:wheelspe_provider/shared/widgets/empty_state.dart';
import 'package:wheelspe_provider/shared/widgets/snackbars.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_card.dart';

/// US34: gestión de ofertas promocionales temporales del proveedor.
class PromotionsScreen extends ConsumerWidget {
  const PromotionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final promos = ref.watch(promotionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.promotions),
        actions: [
          Semantics(
            label: l10n.applyCoupon,
            button: true,
            child: IconButton(
              icon: const Icon(Icons.sell_outlined),
              tooltip: l10n.applyCoupon,
              onPressed: () => context.push('/promotions/apply'),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/promotions/new'),
        icon: const Icon(Icons.add),
        label: Text(l10n.addPromotion),
      ),
      body: promos.isEmpty
          ? EmptyState(
              icon: Icons.local_offer_outlined,
              title: l10n.promotions,
              message: l10n.noPromotions,
            )
          : ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Text(l10n.promotionsSubtitle,
                    style: AppTextStyles.bodySecondary),
                const SizedBox(height: 12),
                for (final promo in promos)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _PromoCard(promo: promo),
                  ),
              ],
            ),
    );
  }
}

class _PromoCard extends ConsumerWidget {
  final PromoOffer promo;

  const _PromoCard({required this.promo});

  (String, Color) _statusChip(AppLocalizations l10n) {
    final now = DateTime.now();
    if (!promo.enabled) return (l10n.promoDisabled, AppColors.textSecondary);
    if (now.isBefore(promo.startDate)) {
      return (l10n.promoScheduled, AppColors.warning);
    }
    if (!promo.isLiveOn(now)) return (l10n.promoExpired, AppColors.error);
    return (l10n.promoActive, AppColors.success);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final (statusLabel, statusColor) = _statusChip(l10n);
    final discountLabel = promo.type == DiscountType.percent
        ? '${promo.value.toStringAsFixed(0)}%'
        : CurrencyFormatter.format(promo.value);

    return WheelsPeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  promo.code,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const Spacer(),
              Text('-$discountLabel',
                  style: AppTextStyles.title.copyWith(color: AppColors.accent)),
            ],
          ),
          const SizedBox(height: 10),
          if (promo.title.isNotEmpty) ...[
            Text(promo.title, style: AppTextStyles.body),
            const SizedBox(height: 6),
          ],
          Row(
            children: [
              const Icon(Icons.event_outlined,
                  size: 15, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.promoValidity(
                    DateFormatter.shortDate(promo.startDate, locale),
                    DateFormatter.shortDate(promo.endDate, locale),
                  ),
                  style: AppTextStyles.caption,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _Chip(label: statusLabel, color: statusColor),
              if (promo.minReputation > 0) ...[
                const SizedBox(width: 8),
                _Chip(
                  label: l10n.promoRewardTag(
                      promo.minReputation.toStringAsFixed(1)),
                  color: AppColors.warning,
                  icon: Icons.star_rounded,
                ),
              ],
              const Spacer(),
              // US34: activar/desactivar la oferta.
              Switch(
                value: promo.enabled,
                onChanged: (_) =>
                    ref.read(promotionsProvider.notifier).toggle(promo.id),
              ),
              Semantics(
                label: l10n.delete,
                button: true,
                child: IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: AppColors.error),
                  onPressed: () async {
                    await ref
                        .read(promotionsProvider.notifier)
                        .remove(promo.id);
                    if (context.mounted) {
                      showSuccessSnackBar(context, l10n.promoDeleted);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const _Chip({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(label,
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              )),
        ],
      ),
    );
  }
}
