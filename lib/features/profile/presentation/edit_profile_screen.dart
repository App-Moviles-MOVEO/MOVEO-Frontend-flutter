import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';
import 'package:wheelspe_provider/core/utils/validators.dart';
import 'package:wheelspe_provider/features/profile/presentation/profile_providers.dart';
import 'package:wheelspe_provider/l10n/generated/app_localizations.dart';
import 'package:wheelspe_provider/shared/providers/user_provider.dart';
import 'package:wheelspe_provider/shared/widgets/avatar_widget.dart';
import 'package:wheelspe_provider/shared/widgets/error_state.dart';
import 'package:wheelspe_provider/shared/widgets/shimmer_card.dart';
import 'package:wheelspe_provider/shared/widgets/snackbars.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_button.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_text_field.dart';

class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editProfile)),
      body: userAsync.when(
        loading: () => const ShimmerList(count: 3, itemHeight: 80),
        error: (e, _) => ErrorState(
          onRetry: () => ref.invalidate(currentUserProvider),
        ),
        data: (user) => _EditProfileForm(
          initialName: user.fullName,
          initialPhone: user.phone,
          avatarUrl: user.avatarUrl,
        ),
      ),
    );
  }
}

class _EditProfileForm extends ConsumerStatefulWidget {
  final String initialName;
  final String initialPhone;
  final String? avatarUrl;

  const _EditProfileForm({
    required this.initialName,
    required this.initialPhone,
    this.avatarUrl,
  });

  @override
  ConsumerState<_EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends ConsumerState<_EditProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.initialName);
  late final _phoneController = TextEditingController(
    text: widget.initialPhone.replaceFirst('+51', ''),
  );
  final _picker = ImagePicker();
  XFile? _newPhoto;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final photo = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (photo != null && mounted) setState(() => _newPhoto = photo);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      await ref.read(profileActionsProvider).updateProfile(
            fullName: _nameController.text.trim(),
            phone: '+51${_phoneController.text.trim()}',
          );
      if (!mounted) return;
      showSuccessSnackBar(context, l10n.profileUpdated);
      context.pop();
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Form(
      key: _formKey,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Semantics(
              label: l10n.addPhoto,
              button: true,
              child: GestureDetector(
                onTap: _pickPhoto,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _newPhoto != null
                        ? CircleAvatar(
                            radius: 48,
                            backgroundImage:
                                FileImage(File(_newPhoto!.path)),
                          )
                        : AvatarWidget(
                            imageUrl: widget.avatarUrl,
                            name: widget.initialName,
                            radius: 48,
                          ),
                    Positioned(
                      bottom: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: AppColors.primaryGlow,
                        ),
                        child: const Icon(
                          Icons.photo_camera_outlined,
                          size: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          WheelsPeTextField(
            controller: _nameController,
            label: l10n.fullNameLabel,
            textCapitalization: TextCapitalization.words,
            validator: (value) =>
                Validators.isNotEmpty(value) ? null : l10n.requiredField,
          ),
          const SizedBox(height: 16),
          WheelsPeTextField(
            controller: _phoneController,
            label: l10n.phoneLabel,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(9),
            ],
            prefix: const Padding(
              padding: EdgeInsets.only(left: 14, right: 6, top: 13),
              child: Text('+51', style: AppTextStyles.body),
            ),
            validator: (value) =>
                Validators.isValidPhone(value ?? '') ? null : l10n.invalidPhone,
          ),
          const SizedBox(height: 28),
          WheelsPeButton(
            label: l10n.save,
            icon: Icons.check,
            loading: _saving,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
