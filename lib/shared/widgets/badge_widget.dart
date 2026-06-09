import 'package:flutter/material.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';

/// Insignia con forma de escudo/medalla: gradiente + ícono real,
/// nunca un Chip de texto plano.
class BadgeWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final bool earned;
  final double size;

  const BadgeWidget({
    super.key,
    required this.icon,
    required this.label,
    this.gradient = const [AppColors.primary, AppColors.accent],
    this.earned = true,
    this.size = 72,
  });

  @override
  Widget build(BuildContext context) {
    final colors = earned
        ? gradient
        : [AppColors.surfaceElevated, AppColors.divider];

    return Semantics(
      label: '$label${earned ? '' : ' (no obtenido)'}',
      image: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipPath(
            clipper: _ShieldClipper(),
            child: Container(
              width: size,
              height: size * 1.12,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: colors,
                ),
                boxShadow: earned ? AppColors.primaryGlow : null,
              ),
              child: Icon(
                icon,
                size: size * 0.42,
                color: earned
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: earned ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Forma de escudo: recta arriba, punta redondeada abajo.
class _ShieldClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    return Path()
      ..moveTo(w * 0.5, 0)
      ..lineTo(w * 0.92, h * 0.12)
      ..quadraticBezierTo(w, h * 0.16, w, h * 0.28)
      ..lineTo(w, h * 0.55)
      ..quadraticBezierTo(w, h * 0.8, w * 0.5, h)
      ..quadraticBezierTo(0, h * 0.8, 0, h * 0.55)
      ..lineTo(0, h * 0.28)
      ..quadraticBezierTo(0, h * 0.16, w * 0.08, h * 0.12)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
