import 'package:flutter/material.dart';

/// Centralised spacing scale used across all screens and widgets.
/// Use these constants instead of hardcoded numbers for consistent layout.
abstract final class AppSpacing {
  AppSpacing._();

  static const double xxs = 4.0;
  static const double xs  = 8.0;
  static const double sm  = 12.0;
  static const double md  = 16.0;
  static const double lg  = 20.0;
  static const double xl  = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;

  /// Standard horizontal padding for page-level content.
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: md);

  /// Vertical padding inside cards and containers.
  static const EdgeInsets cardPadding = EdgeInsets.all(md);

  /// Compact padding inside small chips / badges.
  static const EdgeInsets chipPadding =
      EdgeInsets.symmetric(horizontal: sm, vertical: xxs);
}
