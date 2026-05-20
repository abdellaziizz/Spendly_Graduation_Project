import 'package:flutter/material.dart';
import 'package:spendly/theme/colors.dart';

abstract final class TListTileTheme {
  TListTileTheme._();

  static ListTileThemeData lightListTile = ListTileThemeData(
    tileColor: Colors.transparent,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    iconColor: AppColors.textSecondaryLight,
    textColor: AppColors.textPrimaryLight,
    subtitleTextStyle: const TextStyle(
      fontSize: 13,
      color: AppColors.textSecondaryLight,
    ),
    titleTextStyle: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimaryLight,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  static ListTileThemeData darkListTile = ListTileThemeData(
    tileColor: Colors.transparent,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    iconColor: AppColors.textSecondaryDark,
    textColor: AppColors.textPrimaryDark,
    subtitleTextStyle: const TextStyle(
      fontSize: 13,
      color: AppColors.textSecondaryDark,
    ),
    titleTextStyle: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimaryDark,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
}
