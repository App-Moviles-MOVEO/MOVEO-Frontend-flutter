import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';
import 'package:wheelspe_provider/features/auth/data/auth_models.dart';
import 'package:wheelspe_provider/features/auth/presentation/auth_providers.dart';
import 'package:wheelspe_provider/l10n/generated/app_localizations.dart';
import 'package:wheelspe_provider/shared/widgets/error_state.dart';
import 'package:wheelspe_provider/shared/widgets/shimmer_card.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_button.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_card.dart';

/// Estado actual de la verificación de identidad del proveedor.
class KycStatusScreen extends ConsumerWidget {
  const KycStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final kycAsync = ref.watch(kycStatusProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.kycStatus)),
      body: kycAsync.when(
        loading: () => const ShimmerList(count: 2, itemHeight: 160),
        error: (e, _) => ErrorState(
          onRetry: () => ref.invalidate(kycStatusProvider),
        ),
        data: (kyc) {
          final (icon, color, title, body) = switch (kyc.status) {
            KycStatus.verified => (
                Icons.verified_user,
                AppColors.success,
                l10n.kycVerified,
                l10n.verifiedProvider,
              ),
            KycStatus.rejected => (
                Icons.gpp_bad_outlined,
                AppColors.error,
                l10n.kycRejected,
                kyc.reason ?? l10n.genericError,
              ),
            KycStatus.pending => (
                Icons.hourglass_top,
                AppColors.warning,
                l10n.kycInReview,
                l10n.kycReviewTime,
              ),
          };

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              WheelsPeCard(
                glow: kyc.status == KycStatus.verified,
                child: Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withValues(alpha: 0.14),
                      ),
                      child: Icon(icon, size: 44, color: color),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: AppTextStyles.title,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      body,
                      style: AppTextStyles.bodySecondary,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              if (kyc.status == KycStatus.rejected) ...[
                const SizedBox(height: 20),
                WheelsPeButton(
                  label: l10n.kycRetry,
                  icon: Icons.refresh,
                  onPressed: () => context.push('/auth/kyc'),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
