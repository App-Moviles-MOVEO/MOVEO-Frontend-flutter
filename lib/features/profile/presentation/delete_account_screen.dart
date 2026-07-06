import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';
import 'package:wheelspe_provider/features/auth/presentation/auth_providers.dart';
import 'package:wheelspe_provider/l10n/generated/app_localizations.dart';
import 'package:wheelspe_provider/shared/widgets/snackbars.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_button.dart';

/// US45: baja voluntaria y eliminación de datos. Es inmediata (sin aprobación
/// de admin): elimina la cuenta en el backend y cierra la sesión.
class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final _controller = TextEditingController();
  bool _deleting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _deleting = true);
    try {
      await ref.read(authControllerProvider.notifier).deleteAccount();
      if (!mounted) return;
      showSuccessSnackBar(context, l10n.accountDeleted);
      context.go('/auth/login');
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canDelete =
        _controller.text.trim().toUpperCase() == l10n.deleteConfirmWord;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.deleteAccount)),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppColors.error),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.deleteAccountWarning,
                      style: AppTextStyles.bodySecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.characters,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: l10n.deleteAccountTypeHint,
              ),
            ),
            const SizedBox(height: 32),
            WheelsPeButton(
              label: l10n.deleteAccountConfirm,
              icon: Icons.delete_forever_outlined,
              variant: WheelsPeButtonVariant.danger,
              loading: _deleting,
              onPressed: canDelete ? _delete : null,
            ),
          ],
        ),
      ),
    );
  }
}
