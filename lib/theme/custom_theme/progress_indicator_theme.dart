import 'package:flutter/material.dart';
import 'package:spendly/theme/colors.dart';

abstract final class TProgressIndicatorTheme {
  TProgressIndicatorTheme._();

  static ProgressIndicatorThemeData lightProgress = ProgressIndicatorThemeData(
    color: AppColors.primary,
    linearTrackColor: const Color(0xFFE0E0E0),
    circularTrackColor: const Color(0xFFE0E0E0),
    linearMinHeight: 6,
    borderRadius: BorderRadius.circular(4),
  );

  static ProgressIndicatorThemeData darkProgress = ProgressIndicatorThemeData(
    color: AppColors.primary,
    linearTrackColor: const Color(0xFF2A3A45),
    circularTrackColor: const Color(0xFF2A3A45),
    linearMinHeight: 6,
    borderRadius: BorderRadius.circular(4),
  );
}
