import 'package:flutter/material.dart';
import 'package:spendly/theme/colors.dart';
import 'package:spendly/theme/app_radius.dart';

abstract final class TChipTheme {
  TChipTheme._();

  static ChipThemeData lightChip = ChipThemeData(
    backgroundColor: const Color(0xFFF2F0FA),
    selectedColor: AppColors.primary.withValues(alpha: 0.15),
    labelStyle: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimaryLight,
    ),
    secondaryLabelStyle: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.primary,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: AppRadius.fullBorderRadius),
    side: BorderSide.none,
    elevation: 0,
    pressElevation: 0,
  );

  static ChipThemeData darkChip = ChipThemeData(
    backgroundColor: const Color(0xFF253545),
    selectedColor: AppColors.primary.withValues(alpha: 0.25),
    labelStyle: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimaryDark,
    ),
    secondaryLabelStyle: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.primary,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: AppRadius.fullBorderRadius),
    side: BorderSide.none,
    elevation: 0,
    pressElevation: 0,
  );
}
