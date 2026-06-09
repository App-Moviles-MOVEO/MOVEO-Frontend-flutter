import 'package:flutter/material.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';

/// Tipografía de WheelsPe: DM Sans (body) y DM Serif Display (headings).
class AppTextStyles {
  AppTextStyles._();

  static const String sans = 'DM Sans';
  static const String serif = 'DM Serif Display';

  static const TextStyle displayLarge = TextStyle(
    fontFamily: serif,
    fontSize: 36,
    color: AppColors.textPrimary,
    height: 1.15,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: serif,
    fontSize: 28,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle headline = TextStyle(
    fontFamily: sans,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle title = TextStyle(
    fontFamily: sans,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: sans,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: sans,
    fontSize: 15,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontFamily: sans,
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: sans,
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontFamily: sans,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle amount = TextStyle(
    fontFamily: sans,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
}
