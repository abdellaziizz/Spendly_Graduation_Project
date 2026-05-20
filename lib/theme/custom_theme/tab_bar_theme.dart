import 'package:flutter/material.dart';
import 'package:spendly/theme/colors.dart';

abstract final class TTabBarTheme {
  TTabBarTheme._();

  static TabBarThemeData lightTabBar = TabBarThemeData(
    labelColor: AppColors.primary,
    unselectedLabelColor: AppColors.textSecondaryLight,
    labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    unselectedLabelStyle:
        const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    indicator: const UnderlineTabIndicator(
      borderSide: BorderSide(color: AppColors.primary, width: 2.5),
    ),
    dividerColor: Colors.transparent,
    overlayColor: WidgetStateProperty.all(Colors.transparent),
  );

  static TabBarThemeData darkTabBar = TabBarThemeData(
    labelColor: AppColors.primary,
    unselectedLabelColor: AppColors.textSecondaryDark,
    labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    unselectedLabelStyle:
        const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    indicator: const UnderlineTabIndicator(
      borderSide: BorderSide(color: AppColors.primary, width: 2.5),
    ),
    dividerColor: Colors.transparent,
    overlayColor: WidgetStateProperty.all(Colors.transparent),
  );
}
