import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';
import 'package:wheelspe_provider/l10n/generated/app_localizations.dart';
import 'package:wheelspe_provider/shared/providers/locale_provider.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_card.dart';

/// Pantalla de configuración accesible desde el perfil. Agrupa las
/// opciones de cuenta: contraseña, métodos de cobro, umbral de
/// reputación, idioma, términos y baja de cuenta.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          WheelsPeCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.lock_outline,
                  label: l10n.changePassword,
                  onTap: () => context.push('/profile/change-password'),
                ),
                _SettingsTile(
                  icon: Icons.account_balance_wallet_outlined,
                  label: l10n.payoutMethods,
                  onTap: () => context.push('/profile/payout-methods'),
                ),
                _SettingsTile(
                  icon: Icons.tune,
                  label: l10n.reputationThreshold,
                  onTap: () => context.push('/profile/reputation-threshold'),
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
                _SettingsTile(
                  icon: Icons.description_outlined,
                  label: l10n.termsAndConditions,
                  onTap: () => context.push('/legal/terms'),
                ),
                _SettingsTile(
                  icon: Icons.no_accounts_outlined,
                  label: l10n.deleteAccount,
                  color: AppColors.error,
                  onTap: () => context.push('/profile/delete-account'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _SettingsTile({
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
