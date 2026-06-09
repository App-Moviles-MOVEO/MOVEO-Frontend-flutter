import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';
import 'package:wheelspe_provider/core/utils/validators.dart';
import 'package:wheelspe_provider/features/auth/presentation/auth_providers.dart';
import 'package:wheelspe_provider/l10n/generated/app_localizations.dart';
import 'package:wheelspe_provider/shared/widgets/snackbars.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_button.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.mustAcceptTerms)),
      );
      return;
    }

    // El rol se fija en "PROVIDER" internamente; no se muestra al usuario.
    final ok = await ref.read(authControllerProvider.notifier).register(
          email: _emailController.text,
          password: _passwordController.text,
          fullName: _nameController.text,
          phone: '+51${_phoneController.text.trim()}',
        );
    if (!mounted) return;

    if (ok) {
      context.go('/auth/kyc');
    } else {
      final error = ref.read(authControllerProvider).error;
      if (error != null) showErrorSnackBar(context, error);
    }
  }

  void _openTerms() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).termsAndConditions,
                style: AppTextStyles.headline,
              ),
              const SizedBox(height: 16),
              const Text(
                'Al registrarte como proveedor de WheelsPe aceptas operar '
                'con vehículos de tu propiedad, mantener la información de '
                'tus publicaciones actualizada y cumplir las normas de '
                'convivencia de la comunidad. WheelsPe retiene una comisión '
                'por cada transacción procesada en la plataforma.',
                style: AppTextStyles.bodySecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final loading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.registerTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.registerSubtitle,
                    style: AppTextStyles.bodySecondary),
                const SizedBox(height: 28),
                WheelsPeTextField(
                  controller: _nameController,
                  label: l10n.fullNameLabel,
                  textCapitalization: TextCapitalization.words,
                  prefix: const Icon(Icons.person_outline),
                  validator: (v) =>
                      Validators.isNotEmpty(v) ? null : l10n.requiredField,
                ),
                const SizedBox(height: 20),
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
                  controller: _phoneController,
                  label: l10n.phoneLabel,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 16, right: 8, top: 14),
                    child: Text('+51', style: AppTextStyles.body),
                  ),
                  validator: (v) =>
                      Validators.isValidPhone(v ?? '') ? null : l10n.invalidPhone,
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
                const SizedBox(height: 20),
                WheelsPeTextField(
                  controller: _confirmController,
                  label: l10n.confirmPasswordLabel,
                  obscure: true,
                  prefix: const Icon(Icons.lock_outline),
                  validator: (v) => v == _passwordController.text
                      ? null
                      : l10n.passwordsDontMatch,
                ),
                const SizedBox(height: 24),
                Semantics(
                  label: l10n.acceptTerms,
                  checked: _acceptedTerms,
                  child: Row(
                    children: [
                      Checkbox(
                        value: _acceptedTerms,
                        onChanged: (v) =>
                            setState(() => _acceptedTerms = v ?? false),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: _openTerms,
                          child: Text(
                            l10n.acceptTerms,
                            style: AppTextStyles.bodySecondary.copyWith(
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                WheelsPeButton(
                  label: l10n.registerButton,
                  loading: loading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 16),
                Center(
                  child: Semantics(
                    label: l10n.alreadyHaveAccount,
                    button: true,
                    child: TextButton(
                      onPressed: () => context.go('/auth/login'),
                      child: Text(l10n.alreadyHaveAccount),
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
