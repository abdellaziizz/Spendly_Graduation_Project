import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spendly/theme/colors.dart';

abstract final class TAppBarTheme {
  TAppBarTheme._();

  static AppBarTheme lightAppBar = AppBarTheme(
    backgroundColor: AppColors.backgroundLight,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
    actionsIconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
    titleTextStyle: const TextStyle(
      color: AppColors.textPrimaryLight,
      fontSize: 18,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
    ),
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
    ),
  );

  static AppBarTheme darkAppBar = AppBarTheme(
    backgroundColor: AppColors.backgroundDark,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
    actionsIconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
    titleTextStyle: const TextStyle(
      color: AppColors.textPrimaryDark,
      fontSize: 18,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
    ),
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
      statusBarColor: Colors.transparent,
    ),
  );
}
