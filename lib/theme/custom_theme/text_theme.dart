import 'package:flutter/material.dart';
import 'package:spendly/theme/colors.dart';

abstract final class TTextTheme {
  TTextTheme._();

  static TextTheme lightTextTheme = TextTheme(
    displayLarge: const TextStyle(
      fontSize: 48, fontWeight: FontWeight.w800,
      color: AppColors.textPrimaryLight, letterSpacing: -1.0,
    ),
    displayMedium: const TextStyle(
      fontSize: 36, fontWeight: FontWeight.w800,
      color: AppColors.textPrimaryLight, letterSpacing: -0.5,
    ),
    displaySmall: const TextStyle(
      fontSize: 28, fontWeight: FontWeight.w700,
      color: AppColors.textPrimaryLight, letterSpacing: -0.3,
    ),
    headlineLarge: const TextStyle(
      fontSize: 32, fontWeight: FontWeight.bold,
      color: AppColors.textPrimaryLight,
    ),
    headlineMedium: const TextStyle(
      fontSize: 24, fontWeight: FontWeight.bold,
      color: AppColors.textPrimaryLight,
    ),
    headlineSmall: const TextStyle(
      fontSize: 18, fontWeight: FontWeight.bold,
      color: AppColors.textPrimaryLight,
    ),
    titleLarge: const TextStyle(
      fontSize: 16, fontWeight: FontWeight.w700,
      color: AppColors.textPrimaryLight, letterSpacing: -0.1,
    ),
    titleMedium: const TextStyle(
      fontSize: 16, fontWeight: FontWeight.w600,
      color: AppColors.textPrimaryLight,
    ),
    titleSmall: const TextStyle(
      fontSize: 14, fontWeight: FontWeight.w600,
      color: AppColors.textPrimaryLight,
    ),
    bodyLarge: const TextStyle(
      fontSize: 15, fontWeight: FontWeight.w500,
      color: AppColors.textPrimaryLight, height: 1.5,
    ),
    bodyMedium: const TextStyle(
      fontSize: 14, fontWeight: FontWeight.normal,
      color: AppColors.textPrimaryLight, height: 1.5,
    ),
    bodySmall: const TextStyle(
      fontSize: 13, fontWeight: FontWeight.normal,
      color: AppColors.textSecondaryLight, height: 1.4,
    ),
    labelLarge: const TextStyle(
      fontSize: 14, fontWeight: FontWeight.w600,
      color: AppColors.textPrimaryLight,
    ),
    labelMedium: const TextStyle(
      fontSize: 12, fontWeight: FontWeight.w500,
      color: AppColors.textSecondaryLight,
    ),
    labelSmall: const TextStyle(
      fontSize: 11, fontWeight: FontWeight.w500,
      color: AppColors.textSecondaryLight, letterSpacing: 0.5,
    ),
  );

  static TextTheme darkTextTheme = TextTheme(
    displayLarge: const TextStyle(
      fontSize: 48, fontWeight: FontWeight.w800,
      color: AppColors.textPrimaryDark, letterSpacing: -1.0,
    ),
    displayMedium: const TextStyle(
      fontSize: 36, fontWeight: FontWeight.w800,
      color: AppColors.textPrimaryDark, letterSpacing: -0.5,
    ),
    displaySmall: const TextStyle(
      fontSize: 28, fontWeight: FontWeight.w700,
      color: AppColors.textPrimaryDark, letterSpacing: -0.3,
    ),
    headlineLarge: const TextStyle(
      fontSize: 32, fontWeight: FontWeight.bold,
      color: AppColors.textPrimaryDark,
    ),
    headlineMedium: const TextStyle(
      fontSize: 24, fontWeight: FontWeight.bold,
      color: AppColors.textPrimaryDark,
    ),
    headlineSmall: const TextStyle(
      fontSize: 18, fontWeight: FontWeight.bold,
      color: AppColors.textPrimaryDark,
    ),
    titleLarge: const TextStyle(
      fontSize: 16, fontWeight: FontWeight.w700,
      color: AppColors.textPrimaryDark, letterSpacing: -0.1,
    ),
    titleMedium: const TextStyle(
      fontSize: 16, fontWeight: FontWeight.w600,
      color: AppColors.textPrimaryDark,
    ),
    titleSmall: const TextStyle(
      fontSize: 14, fontWeight: FontWeight.w600,
      color: AppColors.textPrimaryDark,
    ),
    bodyLarge: const TextStyle(
      fontSize: 15, fontWeight: FontWeight.w500,
      color: AppColors.textPrimaryDark, height: 1.5,
    ),
    bodyMedium: const TextStyle(
      fontSize: 14, fontWeight: FontWeight.normal,
      color: AppColors.textPrimaryDark, height: 1.5,
    ),
    bodySmall: const TextStyle(
      fontSize: 13, fontWeight: FontWeight.normal,
      color: AppColors.textSecondaryDark, height: 1.4,
    ),
    labelLarge: const TextStyle(
      fontSize: 14, fontWeight: FontWeight.w600,
      color: AppColors.textPrimaryDark,
    ),
    labelMedium: const TextStyle(
      fontSize: 12, fontWeight: FontWeight.w500,
      color: AppColors.textSecondaryDark,
    ),
    labelSmall: const TextStyle(
      fontSize: 11, fontWeight: FontWeight.w500,
      color: AppColors.textSecondaryDark, letterSpacing: 0.5,
    ),
  );
}
