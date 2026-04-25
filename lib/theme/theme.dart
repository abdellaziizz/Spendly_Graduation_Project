import 'package:flutter/material.dart';
import 'package:tspendly/theme/colors.dart';
import 'package:tspendly/theme/custom_theme/elevated_button_theme.dart';
import 'package:tspendly/theme/custom_theme/text_theme.dart';
import 'package:tspendly/theme/custom_theme/text_field_theme.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    textTheme: TTextTheme.lightTextTheme,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundLight,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
    elevatedButtonTheme: EElevatedButtonTheme.lightElevated,
    inputDecorationTheme: TTextFieldTheme.lightInputDecoration,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      surface: AppColors.lightSurface,
      onSurface: AppColors.textPrimaryLight,
      error: AppColors.error,
    ),
    cardTheme: CardThemeData(
      color: AppColors.lightSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    textTheme: TTextTheme.darkTextTheme,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundDark,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
    elevatedButtonTheme: EElevatedButtonTheme.darkElevated,
    inputDecorationTheme: TTextFieldTheme.darkInputDecoration,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryDark,
      onPrimary: Color(0xff21295C),
      surface: AppColors.darkSurface,
      onSurface: AppColors.textPrimaryDark,
      error: AppColors.error,
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
