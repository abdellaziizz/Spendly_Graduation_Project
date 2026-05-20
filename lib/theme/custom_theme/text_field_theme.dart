import 'package:flutter/material.dart';
import 'package:spendly/theme/colors.dart';
import 'package:spendly/theme/app_radius.dart';

abstract final class TTextFieldTheme {
  TTextFieldTheme._();

  static InputDecorationTheme lightInputDecoration = InputDecorationTheme(
    filled: true,
    fillColor: AppColors.inputFillLight,
    border: OutlineInputBorder(
      borderRadius: AppRadius.mdBorderRadius,
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: AppRadius.mdBorderRadius,
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppRadius.mdBorderRadius,
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: AppRadius.mdBorderRadius,
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: AppRadius.mdBorderRadius,
      borderSide: const BorderSide(color: AppColors.error, width: 2),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: AppRadius.mdBorderRadius,
      borderSide: BorderSide.none,
    ),
    hintStyle: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 14),
    labelStyle: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 14),
    floatingLabelStyle: const TextStyle(color: AppColors.primary, fontSize: 12),
    prefixIconColor: AppColors.textSecondaryLight,
    suffixIconColor: AppColors.textSecondaryLight,
    errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );

  static InputDecorationTheme darkInputDecoration = InputDecorationTheme(
    filled: true,
    fillColor: AppColors.inputFillDark,
    border: OutlineInputBorder(
      borderRadius: AppRadius.mdBorderRadius,
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: AppRadius.mdBorderRadius,
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppRadius.mdBorderRadius,
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: AppRadius.mdBorderRadius,
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: AppRadius.mdBorderRadius,
      borderSide: const BorderSide(color: AppColors.error, width: 2),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: AppRadius.mdBorderRadius,
      borderSide: BorderSide.none,
    ),
    hintStyle: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 14),
    labelStyle: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 14),
    floatingLabelStyle: const TextStyle(color: AppColors.primary, fontSize: 12),
    prefixIconColor: AppColors.textSecondaryDark,
    suffixIconColor: AppColors.textSecondaryDark,
    errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );
}
