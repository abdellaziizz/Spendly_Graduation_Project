import 'package:flutter/material.dart';
import 'package:spendly/theme/colors.dart';
import 'package:spendly/theme/app_radius.dart';

abstract final class TDialogTheme {
  TDialogTheme._();

  static DialogThemeData lightDialog = DialogThemeData(
    backgroundColor: AppColors.lightSurface,
    surfaceTintColor: Colors.transparent,
    elevation: 8,
    shadowColor: const Color(0x1A000000),
    shape: RoundedRectangleBorder(borderRadius: AppRadius.xlBorderRadius),
    titleTextStyle: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimaryLight,
    ),
    contentTextStyle: const TextStyle(
      fontSize: 14,
      color: AppColors.textSecondaryLight,
      height: 1.5,
    ),
  );

  static DialogThemeData darkDialog = DialogThemeData(
    backgroundColor: AppColors.darkSurface,
    surfaceTintColor: Colors.transparent,
    elevation: 8,
    shadowColor: const Color(0x33000000),
    shape: RoundedRectangleBorder(borderRadius: AppRadius.xlBorderRadius),
    titleTextStyle: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimaryDark,
    ),
    contentTextStyle: const TextStyle(
      fontSize: 14,
      color: AppColors.textSecondaryDark,
      height: 1.5,
    ),
  );
}
