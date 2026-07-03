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

/// Recuperación de contraseña en 2 pasos (`/auth/forgot-password` +
/// `/auth/reset-password`). En desarrollo el backend devuelve el `resetToken`,
/// que precargamos para poder completar el flujo sin servidor de correo.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailKey = GlobalKey<FormState>();
  final _resetKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  bool _tokenSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _sendLink() async {
    final l10n = AppLocalizations.of(context);
    if (!_emailKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final result = await ref
          .read(authRepositoryProvider)
          .forgotPassword(_emailController.text.trim());
      if (!mounted) return;
      // En desarrollo el token viene en la respuesta: lo precargamos.
      if (result.resetToken != null) {
        _tokenController.text = result.resetToken!;
      }
      setState(() => _tokenSent = true);
      showInfoSnackBar(context, l10n.forgotPasswordSent);
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final l10n = AppLocalizations.of(context);
    if (!_resetKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).resetPassword(
            token: _tokenController.text.trim(),
            newPassword: _passwordController.text,
          );
      if (!mounted) return;
      showInfoSnackBar(context, l10n.resetPasswordSuccess);
      context.go('/auth/login');
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
      appBar: AppBar(title: Text(l10n.forgotPasswordTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: _tokenSent ? _buildResetForm(l10n) : _buildEmailForm(l10n),
        ),
      ),
    );
  }

  Widget _buildEmailForm(AppLocalizations l10n) {
    return Form(
      key: _emailKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(l10n.forgotPasswordSubtitle,
              style: AppTextStyles.bodySecondary),
          const SizedBox(height: 28),
          WheelsPeTextField(
            controller: _emailController,
            label: l10n.emailLabel,
            keyboardType: TextInputType.emailAddress,
            prefix: const Icon(Icons.mail_outline),
            validator: (v) =>
                Validators.isValidEmail(v ?? '') ? null : l10n.invalidEmail,
          ),
          const SizedBox(height: 32),
          WheelsPeButton(
            label: l10n.forgotPasswordSend,
            loading: _loading,
            onPressed: _sendLink,
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () => context.go('/auth/login'),
              child: Text(l10n.backToLogin),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetForm(AppLocalizations l10n) {
    return Form(
      key: _resetKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(l10n.resetPasswordSubtitle,
              style: AppTextStyles.bodySecondary),
          const SizedBox(height: 28),
          WheelsPeTextField(
            controller: _tokenController,
            label: l10n.resetTokenLabel,
            prefix: const Icon(Icons.vpn_key_outlined),
            validator: (v) =>
                Validators.isNotEmpty(v) ? null : l10n.requiredField,
          ),
          const SizedBox(height: 20),
          WheelsPeTextField(
            controller: _passwordController,
            label: l10n.newPasswordLabel,
            obscure: true,
            prefix: const Icon(Icons.lock_outline),
            validator: (v) => Validators.isValidPassword(v ?? '')
                ? null
                : l10n.passwordTooShort,
          ),
          const SizedBox(height: 32),
          WheelsPeButton(
            label: l10n.resetPasswordButton,
            loading: _loading,
            onPressed: _resetPassword,
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () => context.go('/auth/login'),
              child: Text(l10n.backToLogin),
            ),
          ),
        ],
      ),
    );
  }
}
