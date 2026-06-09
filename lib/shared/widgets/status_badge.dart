import 'package:flutter/material.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';

/// Badge de estado con ícono + color (no depende solo del color, a11y).
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    required this.icon,
  });

  /// Mapea estados comunes del backend a color + ícono.
  factory StatusBadge.fromStatus(String status, String localizedLabel) {
    final (color, icon) = switch (status.toUpperCase()) {
      'AVAILABLE' || 'COMPLETED' || 'CONFIRMED' =>
        (AppColors.success, Icons.check_circle_outline),
      'RENTED' || 'IN_PROGRESS' => (AppColors.primary, Icons.timelapse),
      'MAINTENANCE' => (AppColors.warning, Icons.build_outlined),
      'PENDING' || 'SCHEDULED' => (AppColors.warning, Icons.schedule),
      'CANCELLED' || 'REJECTED' => (AppColors.error, Icons.cancel_outlined),
      'REFUNDED' => (AppColors.error, Icons.undo),
      _ => (AppColors.textSecondary, Icons.info_outline),
    };
    return StatusBadge(label: localizedLabel, color: color, icon: icon);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Estado: $label',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
