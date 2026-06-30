import 'package:flutter/material.dart';

/// Paleta de colores de WheelsPe (tema oscuro).
///
/// Los campos son `const`: toda la app referencia `AppColors.x` directamente
/// dentro de widgets `const`, por lo que deben ser constantes en tiempo de
/// compilación.
///
/// NOTA: el cambio de tema claro/oscuro en runtime (reasignando estos campos)
/// se retiró porque hacía que los colores no fueran `const` y rompía la
/// compilación en toda la app (y en web con dart2js). Si más adelante se
/// quiere soportar tema claro, hacerlo con `ThemeData`/`Theme.of(context)`
/// en lugar de mutar estáticos globales.
class AppColors {
  AppColors._();

  // ── Color de marca ──────────────────────────────────────────────────
  static const Color primary = Color(0xFF0057FF);
  static const Color primaryDark = Color(0xFF003EC1);

  /// Color para texto/íconos colocados SOBRE el color de marca (botones
  /// primarios, FAB, logo). Siempre blanco.
  static const Color onPrimary = Color(0xFFFFFFFF);

  // ── Paleta oscura (activa) ──────────────────────────────────────────
  static const Color background = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF12121A);
  static const Color surfaceElevated = Color(0xFF1C1C28);
  static const Color accent = Color(0xFF00E5FF);
  static const Color success = Color(0xFF00C47D);
  static const Color warning = Color(0xFFF5A623);
  static const Color error = Color(0xFFFF3B5C);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8A8A9E);
  static const Color divider = Color(0xFF2A2A3D);

  /// Glow azul sutil para elementos activos.
  static List<BoxShadow> get primaryGlow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.3),
          blurRadius: 16,
          spreadRadius: 1,
        ),
      ];
}
