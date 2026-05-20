import 'package:flutter/material.dart';
import 'package:spendly/theme/colors.dart';
import 'package:spendly/theme/app_radius.dart';

abstract final class EElevatedButtonTheme {
  EElevatedButtonTheme._();

  static ElevatedButtonThemeData lightElevated = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.buttonLight,
      foregroundColor: Colors.white,
      disabledBackgroundColor: AppColors.buttonLight.withValues(alpha: 0.5),
      disabledForegroundColor: Colors.white54,
      minimumSize: const Size(double.infinity, 52),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorderRadius),
      elevation: 0,
      shadowColor: Colors.transparent,
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
    ),
  );

  static ElevatedButtonThemeData darkElevated = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
      disabledForegroundColor: Colors.white54,
      minimumSize: const Size(double.infinity, 52),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorderRadius),
      elevation: 0,
      shadowColor: Colors.transparent,
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
    ),
  );
}
