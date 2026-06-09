import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';
import 'package:wheelspe_provider/core/utils/validators.dart';
import 'package:wheelspe_provider/features/auth/data/auth_models.dart';
import 'package:wheelspe_provider/features/auth/presentation/auth_providers.dart';
import 'package:wheelspe_provider/l10n/generated/app_localizations.dart';
import 'package:wheelspe_provider/shared/widgets/snackbars.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_button.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = ref.read(authControllerProvider.notifier);
    final ok = await controller.login(
      _emailController.text,
      _passwordController.text,
    );
    if (!mounted) return;

    if (!ok) {
      final error = ref.read(authControllerProvider).error;
      if (error != null) showErrorSnackBar(context, error);
      return;
    }

    // Tras login, valida el KYC para decidir el destino.
    try {
      final kyc =
          await ref.read(authRepositoryProvider).getKycStatus();
      if (!mounted) return;
      context.go(kyc.status == KycStatus.verified ? '/home' : '/auth/kyc');
    } catch (_) {
      if (mounted) context.go('/auth/kyc');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final loading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                Text(l10n.loginTitle, style: AppTextStyles.displayMedium),
                const SizedBox(height: 8),
                Text(l10n.loginSubtitle, style: AppTextStyles.bodySecondary),
                const SizedBox(height: 40),
                WheelsPeTextField(
                  controller: _emailController,
                  label: l10n.emailLabel,
                  keyboardType: TextInputType.emailAddress,
                  prefix: const Icon(Icons.mail_outline),
                  validator: (v) =>
                      Validators.isValidEmail(v ?? '') ? null : l10n.invalidEmail,
                ),
                const SizedBox(height: 20),
                WheelsPeTextField(
                  controller: _passwordController,
                  label: l10n.passwordLabel,
                  obscure: true,
                  prefix: const Icon(Icons.lock_outline),
                  validator: (v) => Validators.isValidPassword(v ?? '')
                      ? null
                      : l10n.passwordTooShort,
                ),
                const SizedBox(height: 32),
                WheelsPeButton(
                  label: l10n.loginButton,
                  loading: loading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 20),
                Center(
                  child: Semantics(
                    label: l10n.noAccountQuestion,
                    button: true,
                    child: TextButton(
                      onPressed: () => context.go('/auth/register'),
                      child: Text(l10n.noAccountQuestion),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
