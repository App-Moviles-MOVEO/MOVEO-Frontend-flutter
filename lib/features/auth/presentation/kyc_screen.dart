import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';
import 'package:wheelspe_provider/core/storage/local_storage.dart';
import 'package:wheelspe_provider/core/utils/platform_utils.dart';
import 'package:wheelspe_provider/features/auth/data/auth_models.dart';
import 'package:wheelspe_provider/features/auth/presentation/auth_providers.dart';
import 'package:wheelspe_provider/l10n/generated/app_localizations.dart';
import 'package:wheelspe_provider/shared/widgets/document_slot.dart';
import 'package:wheelspe_provider/shared/widgets/error_state.dart';
import 'package:wheelspe_provider/shared/widgets/shimmer_card.dart';
import 'package:wheelspe_provider/shared/widgets/snackbars.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_button.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_card.dart';

class KycScreen extends ConsumerStatefulWidget {
  const KycScreen({super.key});

  @override
  ConsumerState<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends ConsumerState<KycScreen> {
  final _picker = ImagePicker();
  XFile? _front;
  XFile? _back;
  bool _uploading = false;
  bool _justSubmitted = false;
  bool _retrying = false;

  Future<void> _pick(bool isFront) async {
    // El escáner/cámara de DNI usa hardware nativo que no funciona en web.
    if (isWeb) {
      showInfoSnackBar(
        context,
        'El escaneo de DNI solo está disponible en la app móvil. '
        'Descárgala para verificar tu identidad.',
      );
      return;
    }
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Cámara'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galería'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final file = await _picker.pickImage(source: source, imageQuality: 85);
    if (file != null && mounted) {
      setState(() => isFront ? _front = file : _back = file);
    }
  }

  Future<void> _submit() async {
    if (_front == null || _back == null) return;
    setState(() => _uploading = true);
    try {
      // Sube los documentos al endpoint real POST /auth/kyc (multipart).
      await ref.read(authRepositoryProvider).submitKyc(
            dniFrontPath: _front!.path,
            dniBackPath: _back!.path,
          );
      if (mounted) setState(() => _justSubmitted = true);
      ref.invalidate(kycStatusProvider);
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _logout() async {
    await ref.read(authControllerProvider.notifier).logout();
    if (mounted) context.go('/auth/login');
  }

  /// Bypass solo para pruebas: entra al home sin esperar la aprobación manual
  /// del KYC. Persiste el flag para no rebotar al KYC en cada arranque.
  Future<void> _skipForTesting() async {
    await ref.read(localStorageProvider).setKycDevBypass(true);
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final kycAsync = ref.watch(kycStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.kycTitle),
        automaticallyImplyLeading: false,
        actions: [
          Semantics(
            label: l10n.logout,
            button: true,
            child: IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
            ),
          ),
        ],
      ),
      body: kycAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(24),
          child: ShimmerCard(height: 280),
        ),
        error: (e, _) => ErrorState(
          onRetry: () => ref.invalidate(kycStatusProvider),
        ),
        data: (kyc) {
          if (kyc.status == KycStatus.verified) {
            // Verificado: el router lo manda al home en el próximo frame.
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => context.go('/home'),
            );
            return const SizedBox.shrink();
          }
          if (kyc.status == KycStatus.rejected && !_retrying) {
            return _RejectedView(
              reason: kyc.reason,
              onRetry: () => setState(() {
                _retrying = true;
                _front = null;
                _back = null;
                _justSubmitted = false;
              }),
            );
          }
          if (_justSubmitted || (kyc.submitted && !_retrying)) {
            return _InReviewView(
              onLogout: _logout,
              onSkip: _skipForTesting,
            );
          }
          return _buildForm(l10n);
        },
      ),
    );
  }

  Widget _buildForm(AppLocalizations l10n) {
    final canSubmit = _front != null && _back != null;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.kycIntro, style: AppTextStyles.headline),
          const SizedBox(height: 8),
          Text(l10n.kycReviewTime, style: AppTextStyles.bodySecondary),
          const SizedBox(height: 28),
          WheelsPeCard(
            child: Column(
              children: [
                DocumentSlot(
                  label: l10n.kycUploadFront,
                  filePath: _front?.path,
                  onTap: () => _pick(true),
                ),
                const Divider(height: 32),
                DocumentSlot(
                  label: l10n.kycUploadBack,
                  filePath: _back?.path,
                  onTap: () => _pick(false),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          WheelsPeButton(
            label: l10n.kycSubmit,
            loading: _uploading,
            onPressed: canSubmit ? _submit : null,
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              onPressed: _skipForTesting,
              icon: const Icon(Icons.fast_forward, size: 18),
              label: Text(l10n.kycSkipForTesting),
            ),
          ),
        ],
      ),
    );
  }
}

class _InReviewView extends StatelessWidget {
  final VoidCallback onLogout;
  final VoidCallback onSkip;

  const _InReviewView({required this.onLogout, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.warning.withValues(alpha: 0.12),
              ),
              child: const Icon(
                Icons.hourglass_top,
                size: 56,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.kycInReview,
              style: AppTextStyles.title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.kycReviewTime,
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            WheelsPeButton(
              label: l10n.logout,
              variant: WheelsPeButtonVariant.secondary,
              onPressed: onLogout,
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onSkip,
              icon: const Icon(Icons.fast_forward, size: 18),
              label: Text(l10n.kycSkipForTesting),
            ),
          ],
        ),
      ),
    );
  }
}

class _RejectedView extends StatelessWidget {
  final String? reason;
  final VoidCallback onRetry;

  const _RejectedView({required this.reason, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.error.withValues(alpha: 0.12),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 56,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.kycRejected,
              style: AppTextStyles.title,
              textAlign: TextAlign.center,
            ),
            if (reason != null) ...[
              const SizedBox(height: 8),
              Text(
                reason!,
                style: AppTextStyles.bodySecondary,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 32),
            WheelsPeButton(label: l10n.kycRetry, onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
