import 'package:flutter/material.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';

/// Card base de WheelsPe: bordes redondeados 16dp, fondo Surface Elevated,
/// glow azul opcional cuando está activa.
class WheelsPeCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final bool glow;
  final String? semanticsLabel;

  const WheelsPeCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.glow = false,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: glow ? AppColors.primary : AppColors.divider,
          width: glow ? 1.2 : 1,
        ),
        boxShadow: glow ? AppColors.primaryGlow : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );

    if (semanticsLabel == null) return card;
    return Semantics(
      label: semanticsLabel,
      button: onTap != null,
      child: card,
    );
  }
}
