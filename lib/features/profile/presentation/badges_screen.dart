import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';
import 'package:wheelspe_provider/features/profile/presentation/profile_providers.dart';
import 'package:wheelspe_provider/l10n/generated/app_localizations.dart';
import 'package:wheelspe_provider/shared/widgets/badge_widget.dart';
import 'package:wheelspe_provider/shared/widgets/error_state.dart';
import 'package:wheelspe_provider/shared/widgets/shimmer_card.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_card.dart';

/// Galería de badges y logros del proveedor.
class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final badgesAsync = ref.watch(myBadgesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.badgesSection)),
      body: badgesAsync.when(
        loading: () => const ShimmerList(count: 4, itemHeight: 110),
        error: (e, _) => ErrorState(
          onRetry: () => ref.invalidate(myBadgesProvider),
        ),
        data: (badges) {
          final items = [
            (
              Icons.shield_outlined,
              l10n.badgeVerified,
              l10n.badgeVerifiedDesc,
              badges.verified,
              const [AppColors.primary, AppColors.accent],
            ),
            (
              Icons.schedule,
              l10n.badgePunctual,
              l10n.badgePunctualDesc,
              badges.punctual,
              const [AppColors.success, AppColors.accent],
            ),
            (
              Icons.emoji_events_outlined,
              l10n.badgeTopRenter,
              l10n.badgeTopRenterDesc,
              badges.topRenter,
              const [AppColors.warning, AppColors.error],
            ),
            (
              Icons.star_outline_rounded,
              l10n.badgeFiveStars,
              l10n.badgeFiveStarsDesc,
              badges.fiveStars,
              const [AppColors.primary, AppColors.primaryDark],
            ),
          ];

          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final (icon, label, description, earned, gradient) = items[i];
              return WheelsPeCard(
                glow: earned,
                child: Row(
                  children: [
                    BadgeWidget(
                      icon: icon,
                      label: '',
                      earned: earned,
                      gradient: gradient,
                      size: 64,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(label, style: AppTextStyles.title),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: AppTextStyles.bodySecondary,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      earned ? Icons.check_circle : Icons.lock_outline,
                      color: earned
                          ? AppColors.success
                          : AppColors.textSecondary,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
