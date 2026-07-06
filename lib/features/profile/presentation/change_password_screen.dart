import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';
import 'package:wheelspe_provider/core/utils/validators.dart';
import 'package:wheelspe_provider/features/auth/presentation/auth_providers.dart';
import 'package:wheelspe_provider/l10n/generated/app_localizations.dart';
import 'package:wheelspe_provider/shared/widgets/snackbars.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_button.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_text_field.dart';

/// Cambio de contraseña del usuario autenticado (`POST /auth/change-password`).
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).changePassword(
            currentPassword: _currentController.text,
            newPassword: _newController.text,
          );
      if (!mounted) return;
      showSuccessSnackBar(context, l10n.passwordChanged);
      context.pop();
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.changePassword)),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.changePasswordSubtitle,
                    style: AppTextStyles.bodySecondary),
                const SizedBox(height: 28),
                WheelsPeTextField(
                  controller: _currentController,
                  label: l10n.currentPassword,
                  obscure: true,
                  prefix: const Icon(Icons.lock_outline),
                  validator: (v) =>
                      Validators.isNotEmpty(v) ? null : l10n.requiredField,
                ),
                const SizedBox(height: 20),
                WheelsPeTextField(
                  controller: _newController,
                  label: l10n.newPassword,
                  obscure: true,
                  prefix: const Icon(Icons.lock_reset_outlined),
                  validator: (v) => Validators.isValidPassword(v ?? '')
                      ? null
                      : l10n.passwordTooShort,
                ),
                const SizedBox(height: 20),
                WheelsPeTextField(
                  controller: _confirmController,
                  label: l10n.confirmNewPassword,
                  obscure: true,
                  prefix: const Icon(Icons.lock_outline),
                  validator: (v) => v == _newController.text
                      ? null
                      : l10n.passwordsDontMatch,
                ),
                const SizedBox(height: 32),
                WheelsPeButton(
                  label: l10n.changePassword,
                  loading: _loading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
