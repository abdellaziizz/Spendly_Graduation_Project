import 'package:flutter/material.dart';
import 'package:spendly/theme/colors.dart';
import 'package:spendly/theme/app_radius.dart';

abstract final class TCardTheme {
  TCardTheme._();

  static CardThemeData lightCard = CardThemeData(
    color: AppColors.lightSurface,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorderRadius),
    shadowColor: const Color(0x0D000000),
  );

  static CardThemeData darkCard = CardThemeData(
    color: AppColors.darkSurface,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorderRadius),
    shadowColor: const Color(0x1A000000),
  );
}
