import 'package:flutter/material.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';

enum WheelsPeButtonVariant { primary, secondary, danger, success }

/// Botón principal de WheelsPe con glow azul y estado de carga.
class WheelsPeButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final WheelsPeButtonVariant variant;
  final IconData? icon;
  final bool expanded;

  const WheelsPeButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.variant = WheelsPeButtonVariant.primary,
    this.icon,
    this.expanded = true,
  });

  Color get _color => switch (variant) {
        WheelsPeButtonVariant.primary => AppColors.primary,
        WheelsPeButtonVariant.secondary => AppColors.surfaceElevated,
        WheelsPeButtonVariant.danger => AppColors.error,
        WheelsPeButtonVariant.success => AppColors.success,
      };

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;

    final child = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: enabled && variant == WheelsPeButtonVariant.primary
            ? AppColors.primaryGlow
            : null,
      ),
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _color,
          minimumSize: expanded
              ? const Size.fromHeight(52)
              : const Size(0, 48),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.textPrimary,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(label, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
      ),
    );

    return Semantics(
      label: label,
      button: true,
      enabled: enabled,
      child: child,
    );
  }
}
