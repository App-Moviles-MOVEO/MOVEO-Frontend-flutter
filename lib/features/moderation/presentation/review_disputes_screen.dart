import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';
import 'package:wheelspe_provider/core/utils/date_formatter.dart';
import 'package:wheelspe_provider/features/moderation/domain/dispute_mediator.dart';
import 'package:wheelspe_provider/features/moderation/presentation/moderation_providers.dart';
import 'package:wheelspe_provider/features/profile/data/profile_remote_datasource.dart';
import 'package:wheelspe_provider/features/profile/presentation/profile_providers.dart';
import 'package:wheelspe_provider/l10n/generated/app_localizations.dart';
import 'package:wheelspe_provider/shared/widgets/avatar_widget.dart';
import 'package:wheelspe_provider/shared/widgets/empty_state.dart';
import 'package:wheelspe_provider/shared/widgets/error_state.dart';
import 'package:wheelspe_provider/shared/widgets/rating_stars.dart';
import 'package:wheelspe_provider/shared/widgets/shimmer_card.dart';
import 'package:wheelspe_provider/shared/widgets/snackbars.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_card.dart';

/// US41: mediación de disputas de reputación. El proveedor puede disputar una
/// reseña recibida y el sistema la resuelve automáticamente (sin admin): si es
/// un voto bajo, atípico y sin justificación, la excluye del cálculo de su
/// reputación.
class ReviewDisputesScreen extends ConsumerWidget {
  const ReviewDisputesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final reviewsAsync = ref.watch(myReviewsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reviewMediationTitle)),
      body: reviewsAsync.when(
        loading: () => const ShimmerList(itemHeight: 96),
        error: (e, _) => ErrorState(
          onRetry: () => ref.invalidate(myReviewsProvider),
        ),
        data: (reviews) {
          if (reviews.isEmpty) {
            return EmptyState(
              icon: Icons.reviews_outlined,
              title: l10n.noReviewsYet,
              message: l10n.reviewMediationIntro,
            );
          }
          final excluded = ref.watch(reviewDisputesProvider);
          final adjusted = ref.watch(adjustedReputationProvider).value ?? 0;
          final excludedCount =
              reviews.where((r) => excluded.contains(DisputeMediator.keyOf(r)))
                  .length;

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              WheelsPeCard(
                glow: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.reviewMediationAdjusted,
                        style: AppTextStyles.subtitle),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          adjusted.toStringAsFixed(2),
                          style: AppTextStyles.amount.copyWith(fontSize: 34),
                        ),
                        const SizedBox(width: 12),
                        RatingStars(rating: adjusted, size: 20),
                      ],
                    ),
                    if (excludedCount > 0) ...[
                      const SizedBox(height: 6),
                      Text(
                        l10n.reviewMediationExcludedCount(excludedCount),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(l10n.reviewMediationIntro, style: AppTextStyles.caption),
              const SizedBox(height: 12),
              for (final r in reviews)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _DisputeReviewTile(
                    review: r,
                    allReviews: reviews,
                    excluded: excluded.contains(DisputeMediator.keyOf(r)),
                  ),
                ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}

class _DisputeReviewTile extends ConsumerWidget {
  final ReviewModel review;
  final List<ReviewModel> allReviews;
  final bool excluded;

  const _DisputeReviewTile({
    required this.review,
    required this.allReviews,
    required this.excluded,
  });

  Future<void> _dispute(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final outcome = await ref
        .read(reviewDisputesProvider.notifier)
        .dispute(review, allReviews);
    if (!context.mounted) return;
    if (outcome == DisputeOutcome.upheld) {
      showSuccessSnackBar(context, l10n.reviewDisputeUpheld);
    } else {
      showInfoSnackBar(context, l10n.reviewDisputeRejected);
    }
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    await ref.read(reviewDisputesProvider.notifier).restore(review);
    if (!context.mounted) return;
    showInfoSnackBar(context, l10n.reviewDisputeRestored);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    return WheelsPeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarWidget(
                imageUrl: review.authorAvatar,
                name: review.authorName,
                radius: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.authorName, style: AppTextStyles.body),
                    if (review.date != null)
                      Text(
                        DateFormatter.shortDate(review.date!, locale),
                        style: AppTextStyles.caption,
                      ),
                  ],
                ),
              ),
              RatingStars(rating: review.score, size: 15),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(review.comment, style: AppTextStyles.bodySecondary),
          ],
          const SizedBox(height: 10),
          if (excluded)
            Row(
              children: [
                const Icon(Icons.gpp_good, size: 18, color: AppColors.success),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.reviewMediationExcludedBadge,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.success),
                  ),
                ),
                TextButton(
                  onPressed: () => _restore(context, ref),
                  child: Text(l10n.reviewDisputeRestore),
                ),
              ],
            )
          else
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.gavel_outlined, size: 18),
                label: Text(l10n.reviewDisputeAction),
                onPressed: () => _dispute(context, ref),
              ),
            ),
        ],
      ),
    );
  }
}
