import 'package:flutter/material.dart';
import 'package:spendly/theme/colors.dart';
import 'package:spendly/theme/custom_theme/app_bar_theme.dart';
import 'package:spendly/theme/custom_theme/bottom_sheet_theme.dart';
import 'package:spendly/theme/custom_theme/card_theme.dart';
import 'package:spendly/theme/custom_theme/chip_theme.dart';
import 'package:spendly/theme/custom_theme/dialog_theme.dart' as t_dialog;
import 'package:spendly/theme/custom_theme/elevated_button_theme.dart';
import 'package:spendly/theme/custom_theme/list_tile_theme.dart';
import 'package:spendly/theme/custom_theme/outlined_button_theme.dart';
import 'package:spendly/theme/custom_theme/progress_indicator_theme.dart';
import 'package:spendly/theme/custom_theme/snack_bar_theme.dart';
import 'package:spendly/theme/custom_theme/switch_theme.dart';
import 'package:spendly/theme/custom_theme/tab_bar_theme.dart';
import 'package:spendly/theme/custom_theme/text_button_theme.dart';
import 'package:spendly/theme/custom_theme/text_field_theme.dart';
import 'package:spendly/theme/custom_theme/text_theme.dart';

/// Central theme factory.
/// All sub-themes are composed here — nothing is defined inline in widgets.
abstract final class AppTheme {
  AppTheme._();

  // ─────────────────────────────────────────────────────────────────────────
  // LIGHT THEME
  // ─────────────────────────────────────────────────────────────────────────
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // ── Colour scheme ────────────────────────────────────────────────────────
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFD6E4F7),
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.goalsAccent,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFE8E7FF),
      onSecondaryContainer: AppColors.goalsAccent,
      surface: AppColors.lightSurface,
      onSurface: AppColors.textPrimaryLight,
      surfaceContainerHighest: Color(0xFFF2F0FA),
      onSurfaceVariant: AppColors.textSecondaryLight,
      error: AppColors.error,
      onError: Colors.white,
      outline: AppColors.dividerLight,
      outlineVariant: Color(0xFFE0E0E0),
      scrim: Colors.black54,
      inverseSurface: AppColors.darkSurface,
      onInverseSurface: AppColors.textPrimaryDark,
      inversePrimary: AppColors.primary,
    ),

    // ── Scaffold ──────────────────────────────────────────────────────────────
    scaffoldBackgroundColor: AppColors.backgroundLight,

    // ── Typography ────────────────────────────────────────────────────────────
    textTheme: TTextTheme.lightTextTheme,

    // ── Sub-themes ────────────────────────────────────────────────────────────
    appBarTheme:                 TAppBarTheme.lightAppBar,
    elevatedButtonTheme:         EElevatedButtonTheme.lightElevated,
    outlinedButtonTheme:         TOutlinedButtonTheme.lightOutlined,
    textButtonTheme:             TTextButtonTheme.lightTextButton,
    inputDecorationTheme:        TTextFieldTheme.lightInputDecoration,
    cardTheme:                   TCardTheme.lightCard,
    chipTheme:                   TChipTheme.lightChip,
    dialogTheme:                 t_dialog.TDialogTheme.lightDialog,
    bottomSheetTheme:            TBottomSheetTheme.lightBottomSheet,
    snackBarTheme:               TSnackBarTheme.lightSnackBar,
    tabBarTheme:                 TTabBarTheme.lightTabBar,
    switchTheme:                 TSwitchTheme.lightSwitch,
    progressIndicatorTheme:      TProgressIndicatorTheme.lightProgress,
    listTileTheme:               TListTileTheme.lightListTile,

    // ── Icon ─────────────────────────────────────────────────────────────────
    iconTheme: const IconThemeData(color: AppColors.textPrimaryLight, size: 24),

    // ── Divider ───────────────────────────────────────────────────────────────
    dividerTheme: const DividerThemeData(
      color: AppColors.dividerLight,
      thickness: 1,
      space: 1,
    ),

    // ── Popup menu ────────────────────────────────────────────────────────────
    popupMenuTheme: PopupMenuThemeData(
      color: AppColors.lightSurface,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // ── DatePicker ────────────────────────────────────────────────────────────
    datePickerTheme: const DatePickerThemeData(
      backgroundColor: AppColors.lightSurface,
      headerBackgroundColor: AppColors.primary,
      headerForegroundColor: Colors.white,
      dayStyle: TextStyle(fontSize: 13),
    ),
  );

  // ─────────────────────────────────────────────────────────────────────────
  // DARK THEME
  // ─────────────────────────────────────────────────────────────────────────
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // ── Colour scheme ────────────────────────────────────────────────────────
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryDark,
      onPrimaryContainer: AppColors.textPrimaryDark,
      secondary: AppColors.goalsAccent,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFF2D2B6B),
      onSecondaryContainer: AppColors.goalsAccentVariant,
      surface: AppColors.darkSurface,
      onSurface: AppColors.textPrimaryDark,
      surfaceContainerHighest: AppColors.darkSurfaceElevated,
      onSurfaceVariant: AppColors.textSecondaryDark,
      error: AppColors.error,
      onError: Colors.white,
      outline: AppColors.dividerDark,
      outlineVariant: Color(0xFF3A4A55),
      scrim: Colors.black54,
      inverseSurface: AppColors.lightSurface,
      onInverseSurface: AppColors.textPrimaryLight,
      inversePrimary: AppColors.primaryDark,
    ),

    // ── Scaffold ──────────────────────────────────────────────────────────────
    scaffoldBackgroundColor: AppColors.backgroundDark,

    // ── Typography ────────────────────────────────────────────────────────────
    textTheme: TTextTheme.darkTextTheme,

    // ── Sub-themes ────────────────────────────────────────────────────────────
    appBarTheme:                 TAppBarTheme.darkAppBar,
    elevatedButtonTheme:         EElevatedButtonTheme.darkElevated,
    outlinedButtonTheme:         TOutlinedButtonTheme.darkOutlined,
    textButtonTheme:             TTextButtonTheme.darkTextButton,
    inputDecorationTheme:        TTextFieldTheme.darkInputDecoration,
    cardTheme:                   TCardTheme.darkCard,
    chipTheme:                   TChipTheme.darkChip,
    dialogTheme:                 t_dialog.TDialogTheme.darkDialog,
    bottomSheetTheme:            TBottomSheetTheme.darkBottomSheet,
    snackBarTheme:               TSnackBarTheme.darkSnackBar,
    tabBarTheme:                 TTabBarTheme.darkTabBar,
    switchTheme:                 TSwitchTheme.darkSwitch,
    progressIndicatorTheme:      TProgressIndicatorTheme.darkProgress,
    listTileTheme:               TListTileTheme.darkListTile,

    // ── Icon ─────────────────────────────────────────────────────────────────
    iconTheme: const IconThemeData(color: AppColors.textPrimaryDark, size: 24),

    // ── Divider ───────────────────────────────────────────────────────────────
    dividerTheme: const DividerThemeData(
      color: AppColors.dividerDark,
      thickness: 1,
      space: 1,
    ),

    // ── Popup menu ────────────────────────────────────────────────────────────
    popupMenuTheme: PopupMenuThemeData(
      color: AppColors.darkSurface,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // ── DatePicker ────────────────────────────────────────────────────────────
    datePickerTheme: const DatePickerThemeData(
      backgroundColor: AppColors.darkSurface,
      headerBackgroundColor: AppColors.primary,
      headerForegroundColor: Colors.white,
      dayStyle: TextStyle(fontSize: 13),
    ),
  );
}
