import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';
import 'package:wheelspe_provider/core/storage/local_storage.dart';
import 'package:wheelspe_provider/core/utils/currency_formatter.dart';
import 'package:wheelspe_provider/features/auth/data/auth_models.dart';
import 'package:wheelspe_provider/features/auth/presentation/auth_providers.dart';
import 'package:wheelspe_provider/features/profile/data/profile_remote_datasource.dart';
import 'package:wheelspe_provider/features/profile/presentation/profile_providers.dart';
import 'package:wheelspe_provider/features/transactions/presentation/transactions_providers.dart';
import 'package:wheelspe_provider/l10n/generated/app_localizations.dart';
import 'package:wheelspe_provider/shared/providers/locale_provider.dart';
import 'package:wheelspe_provider/shared/providers/user_provider.dart';
import 'package:wheelspe_provider/shared/widgets/avatar_widget.dart';
import 'package:wheelspe_provider/shared/widgets/badge_widget.dart';
import 'package:wheelspe_provider/shared/widgets/error_state.dart';
import 'package:wheelspe_provider/shared/widgets/rating_stars.dart';
import 'package:wheelspe_provider/shared/widgets/shimmer_card.dart';
import 'package:wheelspe_provider/shared/widgets/snackbars.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_button.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: userAsync.when(
        loading: () => const ShimmerList(count: 4, itemHeight: 130),
        error: (e, _) => ErrorState(
          onRetry: () => ref.invalidate(currentUserProvider),
        ),
        data: (user) => _ProfileBody(user: user),
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  final UserModel user;

  const _ProfileBody({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final badges = ref.watch(myBadgesProvider).value ??
        ProviderBadges.fromUser(user);
    final summary = ref.watch(walletSummaryProvider).value;
    final reviews = ref.watch(myReviewsProvider).value ?? const [];
    final locale = ref.watch(localeProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(currentUserProvider);
        ref.invalidate(walletSummaryProvider);
        ref.invalidate(myReviewsProvider);
      },
      child: ListView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.all(16),
        children: [
          // Cabecera con avatar y nombre
          Center(
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AvatarWidget(
                      imageUrl: user.avatarUrl,
                      name: user.fullName,
                      radius: 48,
                      showVerifiedBadge: user.isVerified,
                    ),
                    Positioned(
                      bottom: -4,
                      right: -4,
                      child: Semantics(
                        label: l10n.editProfile,
                        button: true,
                        child: GestureDetector(
                          onTap: () => context.push('/profile/edit'),
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              boxShadow: AppColors.primaryGlow,
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(user.fullName, style: AppTextStyles.headline),
                if (user.isVerified) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified,
                        size: 16,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.verifiedProvider,
                        style: AppTextStyles.bodySecondary.copyWith(
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Badges
          Text(l10n.badgesSection, style: AppTextStyles.title),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              BadgeWidget(
                icon: Icons.shield_outlined,
                label: l10n.badgeVerified,
                earned: badges.verified,
                size: 58,
              ),
              BadgeWidget(
                icon: Icons.schedule,
                label: l10n.badgePunctual,
                earned: badges.punctual,
                size: 58,
                gradient: const [AppColors.success, AppColors.accent],
              ),
              BadgeWidget(
                icon: Icons.emoji_events_outlined,
                label: l10n.badgeTopRenter,
                earned: badges.topRenter,
                size: 58,
                gradient: const [AppColors.warning, AppColors.error],
              ),
              BadgeWidget(
                icon: Icons.star_outline_rounded,
                label: l10n.badgeFiveStars,
                earned: badges.fiveStars,
                size: 58,
                gradient: const [AppColors.primary, AppColors.primaryDark],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Reputación
          Text(l10n.reputation, style: AppTextStyles.title),
          const SizedBox(height: 12),
          WheelsPeCard(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user.reputation.toStringAsFixed(1),
                      style: AppTextStyles.amount.copyWith(fontSize: 40),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RatingStars(rating: user.reputation, size: 22),
                        const SizedBox(height: 4),
                        Text(
                          l10n.ratingsCount(user.ratingCount),
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ],
                ),
                if (reviews.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.latestReviews,
                      style: AppTextStyles.subtitle,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final review in reviews.take(3))
                    _ReviewTile(review: review),
                ] else ...[
                  const SizedBox(height: 8),
                  Text(l10n.noReviewsYet, style: AppTextStyles.caption),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Estadísticas
          Text(l10n.statistics, style: AppTextStyles.title),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.directions_car_outlined,
                  value: '${user.completedRentals}',
                  label: l10n.totalRentals,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  icon: Icons.route_outlined,
                  value: '${user.completedRoutes}',
                  label: l10n.totalRoutes,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  icon: Icons.savings_outlined,
                  value: CurrencyFormatter.formatCompact(
                    summary?.balance ?? 0,
                  ),
                  label: l10n.totalEarnings,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Wallet
          Text(l10n.wallet, style: AppTextStyles.title),
          const SizedBox(height: 12),
          WheelsPeCard(
            glow: true,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.availableBalance,
                        style: AppTextStyles.subtitle,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        CurrencyFormatter.format(summary?.balance ?? 0),
                        style: AppTextStyles.amount,
                      ),
                    ],
                  ),
                ),
                Semantics(
                  label: l10n.withdrawFunds,
                  button: true,
                  child: ElevatedButton.icon(
                    onPressed: () => _showWithdrawSheet(
                      context,
                      ref,
                      l10n,
                      summary?.balance ?? 0,
                    ),
                    icon: const Icon(Icons.arrow_outward, size: 18),
                    label: Text(l10n.withdrawFunds),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      textStyle: AppTextStyles.bodySecondary.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Menú de opciones
          WheelsPeCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _MenuTile(
                  icon: Icons.person_outline,
                  label: l10n.editProfile,
                  onTap: () => context.push('/profile/edit'),
                ),
                _MenuTile(
                  icon: Icons.badge_outlined,
                  label: l10n.kycStatus,
                  onTap: () => context.push('/profile/kyc'),
                ),
                _MenuTile(
                  icon: Icons.military_tech_outlined,
                  label: l10n.badgesSection,
                  onTap: () => context.push('/profile/badges'),
                ),
                _MenuTile(
                  icon: Icons.lock_outline,
                  label: l10n.changePassword,
                  onTap: () => context.push('/profile/change-password'),
                ),
                _MenuTile(
                  icon: Icons.account_balance_wallet_outlined,
                  label: l10n.payoutMethods,
                  onTap: () => context.push('/profile/payout-methods'),
                ),
                _MenuTile(
                  icon: Icons.tune,
                  label: l10n.reputationThreshold,
                  onTap: () =>
                      context.push('/profile/reputation-threshold'),
                ),
                _MenuTile(
                  icon: Icons.gavel_outlined,
                  label: l10n.reviewMediationTitle,
                  onTap: () => context.push('/profile/review-disputes'),
                ),
                _MenuTile(
                  icon: Icons.local_offer_outlined,
                  label: l10n.promotions,
                  onTap: () => context.push('/promotions'),
                ),
                _MenuTile(
                  icon: Icons.handshake_outlined,
                  label: l10n.allianceTitle,
                  onTap: () => context.push('/profile/alliance'),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.language,
                    color: AppColors.textSecondary,
                  ),
                  title: Text(l10n.language, style: AppTextStyles.body),
                  trailing: Semantics(
                    label: l10n.language,
                    child: SegmentedButton<String>(
                      segments: [
                        ButtonSegment(
                          value: 'es',
                          label: Text(
                            'ES',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        ButtonSegment(
                          value: 'en',
                          label: Text(
                            'EN',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                      selected: {locale.languageCode},
                      showSelectedIcon: false,
                      onSelectionChanged: (selection) => ref
                          .read(localeProvider.notifier)
                          .setLocale(selection.first),
                    ),
                  ),
                ),
                _MenuTile(
                  icon: Icons.description_outlined,
                  label: l10n.termsAndConditions,
                  onTap: () {},
                ),
                _MenuTile(
                  icon: Icons.no_accounts_outlined,
                  label: l10n.deleteAccount,
                  color: AppColors.error,
                  onTap: () => context.push('/profile/delete-account'),
                ),
                _MenuTile(
                  icon: Icons.logout,
                  label: l10n.logout,
                  color: AppColors.error,
                  onTap: () async {
                    await ref
                        .read(authControllerProvider.notifier)
                        .logout();
                    if (context.mounted) context.go('/auth/login');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showWithdrawSheet(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    double balance,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: _WithdrawSheet(balance: balance),
      ),
    );
  }
}

/// Formulario real de retiro: monto, método y destino → POST /withdrawals.
class _WithdrawSheet extends ConsumerStatefulWidget {
  final double balance;

  const _WithdrawSheet({required this.balance});

  @override
  ConsumerState<_WithdrawSheet> createState() => _WithdrawSheetState();
}

class _WithdrawSheetState extends ConsumerState<_WithdrawSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _destinationController = TextEditingController();
  String _method = 'yape';
  bool _submitting = false;
  late final List<Map<String, String>> _savedMethods;

  @override
  void initState() {
    super.initState();
    // US21: métodos de cobro guardados para rellenar rápido.
    _savedMethods = ref.read(localStorageProvider).loadPayoutMethods();
  }

  void _applySaved(Map<String, String> m) {
    setState(() {
      _method = m['method'] ?? _method;
      _destinationController.text = m['destination'] ?? '';
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final l10n = AppLocalizations.of(context);
    try {
      await ref.read(transactionActionsProvider).requestWithdrawal(
            amount: double.parse(_amountController.text.trim()),
            method: _method,
            destination: _destinationController.text.trim(),
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      showSuccessSnackBar(context, l10n.withdrawRequested);
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.withdrawFunds, style: AppTextStyles.title),
              const SizedBox(height: 4),
              Text(
                l10n.availableToWithdraw(
                  CurrencyFormatter.format(widget.balance),
                ),
                style: AppTextStyles.bodySecondary,
              ),
              if (_savedMethods.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final m in _savedMethods)
                      ActionChip(
                        avatar: const Icon(Icons.account_balance_wallet_outlined,
                            size: 16),
                        label: Text(m['alias'] ?? ''),
                        onPressed: () => _applySaved(m),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: l10n.withdrawAmount),
                validator: (v) {
                  final amount = double.tryParse((v ?? '').trim()) ?? 0;
                  if (amount <= 0) return l10n.requiredField;
                  if (amount > widget.balance) return l10n.insufficientBalance;
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Text(l10n.withdrawMethod, style: AppTextStyles.subtitle),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'yape', label: Text(l10n.yape)),
                  ButtonSegment(value: 'plin', label: Text(l10n.plin)),
                  ButtonSegment(value: 'bank', label: Text(l10n.card)),
                ],
                selected: {_method},
                showSelectedIcon: false,
                onSelectionChanged: (s) => setState(() => _method = s.first),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _destinationController,
                decoration:
                    InputDecoration(labelText: l10n.withdrawDestination),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? l10n.requiredField : null,
              ),
              const SizedBox(height: 20),
              WheelsPeButton(
                label: l10n.withdrawConfirm,
                loading: _submitting,
                onPressed: _submit,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final ReviewModel review;

  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AvatarWidget(
            imageUrl: review.authorAvatar,
            name: review.authorName,
            radius: 16,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        review.authorName,
                        style: AppTextStyles.bodySecondary.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    RatingStars(rating: review.score, size: 13),
                  ],
                ),
                if (review.comment.isNotEmpty)
                  Text(
                    review.comment,
                    style: AppTextStyles.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return WheelsPeCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      semanticsLabel: '$label: $value',
      child: Column(
        children: [
          Icon(icon, color: AppColors.accent),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              value,
              style: AppTextStyles.title,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: ListTile(
        leading: Icon(icon, color: color ?? AppColors.textSecondary),
        title: Text(
          label,
          style: AppTextStyles.body.copyWith(color: color),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }
}
