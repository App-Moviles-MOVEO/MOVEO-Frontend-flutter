import 'package:flutter/material.dart';

/// Paleta de colores de WheelsPe.
///
/// Soporta tema oscuro (por defecto) y claro. Los campos NO son `const`:
/// se reasignan en runtime con [applyMode] cuando el usuario cambia el tema
/// desde Ajustes. Como toda la app referencia `AppColors.x` directamente,
/// basta reconstruir el árbol (ver `main.dart`) para que el cambio se aplique.
class AppColors {
  AppColors._();

  /// `true` si la paleta activa es la oscura.
  static bool isDark = true;

  // ── Color de marca (igual en ambos temas) ──────────────────────────
  static const Color primary = Color(0xFF0057FF);
  static const Color primaryDark = Color(0xFF003EC1);

  /// Color para texto/íconos colocados SOBRE el color de marca (botones
  /// primarios, FAB, logo). Siempre blanco, no depende del tema.
  static const Color onPrimary = Color(0xFFFFFFFF);

  // ── Campos que cambian con el tema ──────────────────────────────────
  static Color background = _darkBackground;
  static Color surface = _darkSurface;
  static Color surfaceElevated = _darkSurfaceElevated;
  static Color accent = _darkAccent;
  static Color success = _darkSuccess;
  static Color warning = _darkWarning;
  static Color error = _darkError;
  static Color textPrimary = _darkTextPrimary;
  static Color textSecondary = _darkTextSecondary;
  static Color divider = _darkDivider;

  /// Glow azul sutil para elementos activos.
  static List<BoxShadow> get primaryGlow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.3),
          blurRadius: 16,
          spreadRadius: 1,
        ),
      ];

  /// Reasigna la paleta activa. Llamar antes de reconstruir la app.
  static void applyMode({required bool dark}) {
    isDark = dark;
    background = dark ? _darkBackground : _lightBackground;
    surface = dark ? _darkSurface : _lightSurface;
    surfaceElevated = dark ? _darkSurfaceElevated : _lightSurfaceElevated;
    accent = dark ? _darkAccent : _lightAccent;
    success = dark ? _darkSuccess : _lightSuccess;
    warning = dark ? _darkWarning : _lightWarning;
    error = dark ? _darkError : _lightError;
    textPrimary = dark ? _darkTextPrimary : _lightTextPrimary;
    textSecondary = dark ? _darkTextSecondary : _lightTextSecondary;
    divider = dark ? _darkDivider : _lightDivider;
  }

  // ── Paleta oscura ───────────────────────────────────────────────────
  static const Color _darkBackground = Color(0xFF0A0A0F);
  static const Color _darkSurface = Color(0xFF12121A);
  static const Color _darkSurfaceElevated = Color(0xFF1C1C28);
  static const Color _darkAccent = Color(0xFF00E5FF);
  static const Color _darkSuccess = Color(0xFF00C47D);
  static const Color _darkWarning = Color(0xFFF5A623);
  static const Color _darkError = Color(0xFFFF3B5C);
  static const Color _darkTextPrimary = Color(0xFFFFFFFF);
  static const Color _darkTextSecondary = Color(0xFF8A8A9E);
  static const Color _darkDivider = Color(0xFF2A2A3D);

  // ── Paleta clara ────────────────────────────────────────────────────
  static const Color _lightBackground = Color(0xFFF4F5F9);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightSurfaceElevated = Color(0xFFFFFFFF);
  static const Color _lightAccent = Color(0xFF008CA8);
  static const Color _lightSuccess = Color(0xFF00A86B);
  static const Color _lightWarning = Color(0xFFD98300);
  static const Color _lightError = Color(0xFFE0304F);
  static const Color _lightTextPrimary = Color(0xFF0E0E16);
  static const Color _lightTextSecondary = Color(0xFF5B5B70);
  static const Color _lightDivider = Color(0xFFE2E4EC);
}
