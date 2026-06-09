import 'package:flutter/material.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';
import 'package:wheelspe_provider/l10n/generated/app_localizations.dart';

/// Estado de error con ícono, mensaje y botón "Reintentar".
class ErrorState extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;

  const ErrorState({super.key, this.message, this.onRetry});

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
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.error.withValues(alpha: 0.12),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 44,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message ?? l10n.genericError,
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              Semantics(
                label: l10n.retryButton,
                button: true,
                child: OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.retryButton),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(160, 48),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
