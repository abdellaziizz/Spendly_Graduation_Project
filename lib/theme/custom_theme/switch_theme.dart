import 'package:flutter/material.dart';
import 'package:spendly/theme/colors.dart';

abstract final class TSwitchTheme {
  TSwitchTheme._();

  static SwitchThemeData lightSwitch = SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return Colors.white;
      return AppColors.textSecondaryLight;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppColors.primary;
      return const Color(0xFFE0E0E0);
    }),
    trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
  );

  static SwitchThemeData darkSwitch = SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return Colors.white;
      return AppColors.textSecondaryDark;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppColors.primary;
      return const Color(0xFF3A4A55);
    }),
    trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
  );
}
