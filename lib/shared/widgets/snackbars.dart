import 'package:flutter/material.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';
import 'package:wheelspe_provider/core/errors/exceptions.dart';
import 'package:wheelspe_provider/l10n/generated/app_localizations.dart';

/// SnackBar verde de éxito (3 segundos).
void showSuccessSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 3),
      backgroundColor: AppColors.success,
      content: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.textPrimary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: AppTextStyles.body),
          ),
        ],
      ),
    ),
  );
}

/// SnackBar informativo (azul). Útil para avisar de funciones no disponibles
/// en la plataforma actual, por ejemplo en web.
void showInfoSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 4),
      backgroundColor: AppColors.primary,
      content: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.onPrimary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.body.copyWith(color: AppColors.onPrimary),
            ),
          ),
        ],
      ),
    ),
  );
}

/// SnackBar de error con mensaje legible según el tipo de excepción.
void showErrorSnackBar(BuildContext context, Object error) {
  final l10n = AppLocalizations.of(context);
  final message = switch (error) {
    NetworkException() => l10n.connectionError,
    AuthException() => l10n.sessionExpired,
    ServerException(:final message) => message,
    _ => l10n.genericError,
  };
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: AppColors.error,
      content: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.textPrimary),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: AppTextStyles.body)),
        ],
      ),
    ),
  );
}
