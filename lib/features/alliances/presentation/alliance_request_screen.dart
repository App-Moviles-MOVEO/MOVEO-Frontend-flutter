import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';
import 'package:wheelspe_provider/core/utils/date_formatter.dart';
import 'package:wheelspe_provider/core/utils/validators.dart';
import 'package:wheelspe_provider/features/alliances/data/alliance_model.dart';
import 'package:wheelspe_provider/features/alliances/presentation/alliances_providers.dart';
import 'package:wheelspe_provider/l10n/generated/app_localizations.dart';
import 'package:wheelspe_provider/shared/widgets/snackbars.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_button.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_card.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_text_field.dart';

/// US46: solicitud de alianza corporativa. El proveedor postula a su empresa
/// para movilizar colaboradores; la revisión (que normalmente haría un admin)
/// se resuelve de forma automática con una política determinística.
class AllianceRequestScreen extends ConsumerStatefulWidget {
  const AllianceRequestScreen({super.key});

  @override
  ConsumerState<AllianceRequestScreen> createState() =>
      _AllianceRequestScreenState();
}

class _AllianceRequestScreenState extends ConsumerState<AllianceRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyController = TextEditingController();
  final _rucController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  int _fleetSize = 5;
  bool _submitting = false;

  @override
  void dispose() {
    _companyController.dispose();
    _rucController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final request = await ref.read(alliancesProvider.notifier).submit(
            companyName: _companyController.text.trim(),
            taxId: _rucController.text.trim(),
            contactName: _contactController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            fleetSize: _fleetSize,
            message: _messageController.text.trim(),
          );
      if (!mounted) return;
      _formKey.currentState!.reset();
      _companyController.clear();
      _rucController.clear();
      _contactController.clear();
      _emailController.clear();
      _phoneController.clear();
      _messageController.clear();
      setState(() => _fleetSize = 5);
      await _showResult(request.status);
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _showResult(AllianceStatus status) async {
    final l10n = AppLocalizations.of(context);
    final approved = status.isApproved;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(
          approved ? Icons.verified_rounded : Icons.hourglass_top_rounded,
          color: approved ? AppColors.success : AppColors.warning,
          size: 40,
        ),
        title: Text(
          approved ? l10n.allianceApprovedTitle : l10n.allianceUnderReviewTitle,
          textAlign: TextAlign.center,
        ),
        content: Text(
          approved ? l10n.allianceApprovedBody : l10n.allianceUnderReviewBody,
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final requests = ref.watch(alliancesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.allianceTitle)),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WheelsPeCard(
                child: Row(
                  children: [
                    const Icon(Icons.handshake_outlined,
                        color: AppColors.accent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(l10n.allianceIntro,
                          style: AppTextStyles.bodySecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              WheelsPeTextField(
                controller: _companyController,
                label: l10n.allianceCompany,
                prefix: const Icon(Icons.business_outlined, size: 20),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    Validators.isNotEmpty(v) ? null : l10n.requiredField,
              ),
              const SizedBox(height: 16),
              WheelsPeTextField(
                controller: _rucController,
                label: l10n.allianceRuc,
                hint: '20123456789',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                validator: (v) => RegExp(r'^\d{11}$').hasMatch((v ?? '').trim())
                    ? null
                    : l10n.allianceRucInvalid,
              ),
              const SizedBox(height: 16),
              WheelsPeTextField(
                controller: _contactController,
                label: l10n.allianceContact,
                prefix: const Icon(Icons.person_outline, size: 20),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    Validators.isNotEmpty(v) ? null : l10n.requiredField,
              ),
              const SizedBox(height: 16),
              WheelsPeTextField(
                controller: _emailController,
                label: l10n.emailLabel,
                keyboardType: TextInputType.emailAddress,
                prefix: const Icon(Icons.mail_outline, size: 20),
                validator: (v) => Validators.isValidEmail(v ?? '')
                    ? null
                    : l10n.invalidEmail,
              ),
              const SizedBox(height: 16),
              WheelsPeTextField(
                controller: _phoneController,
                label: l10n.alliancePhone,
                keyboardType: TextInputType.phone,
                prefix: const Icon(Icons.phone_outlined, size: 20),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(9),
                ],
                validator: (v) => Validators.isValidPhone(v ?? '')
                    ? null
                    : l10n.invalidPhone,
              ),
              const SizedBox(height: 16),
              Text(l10n.allianceFleetSize, style: AppTextStyles.subtitle),
              Text(l10n.allianceFleetSizeHint, style: AppTextStyles.caption),
              const SizedBox(height: 4),
              WheelsPeCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      color: AppColors.primary,
                      onPressed: _fleetSize > 1
                          ? () => setState(() => _fleetSize--)
                          : null,
                    ),
                    Text('$_fleetSize', style: AppTextStyles.headline),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      color: AppColors.primary,
                      onPressed: _fleetSize < 500
                          ? () => setState(() => _fleetSize++)
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              WheelsPeTextField(
                controller: _messageController,
                label: l10n.allianceMessage,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),
              WheelsPeButton(
                label: l10n.allianceSubmit,
                loading: _submitting,
                onPressed: _submit,
              ),
              if (requests.isNotEmpty) ...[
                const SizedBox(height: 32),
                Text(l10n.allianceHistory, style: AppTextStyles.title),
                const SizedBox(height: 12),
                for (final r in requests)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _AllianceTile(request: r, locale: locale),
                  ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _AllianceTile extends StatelessWidget {
  final AlliancePartnership request;
  final String locale;

  const _AllianceTile({required this.request, required this.locale});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final approved = request.status.isApproved;
    return WheelsPeCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(request.companyName, style: AppTextStyles.body),
                const SizedBox(height: 2),
                Text(
                  DateFormatter.shortDate(request.createdAt, locale),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: (approved ? AppColors.success : AppColors.warning)
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              approved ? l10n.allianceApproved : l10n.allianceUnderReview,
              style: AppTextStyles.caption.copyWith(
                color: approved ? AppColors.success : AppColors.warning,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
