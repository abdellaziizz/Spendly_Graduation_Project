import 'package:flutter/material.dart';
import 'package:spendly/theme/colors.dart';
import 'package:spendly/theme/app_radius.dart';

abstract final class TSnackBarTheme {
  TSnackBarTheme._();

  static SnackBarThemeData lightSnackBar = SnackBarThemeData(
    backgroundColor: const Color(0xFF1C1C1E),
    contentTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorderRadius),
    behavior: SnackBarBehavior.floating,
    elevation: 4,
    actionTextColor: AppColors.primary,
  );

  static SnackBarThemeData darkSnackBar = SnackBarThemeData(
    backgroundColor: const Color(0xFF2C3E50),
    contentTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorderRadius),
    behavior: SnackBarBehavior.floating,
    elevation: 4,
    actionTextColor: AppColors.primary,
  );
}
