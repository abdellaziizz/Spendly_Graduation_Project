import 'package:flutter/material.dart';

/// Reusable box-shadow presets.
abstract final class AppShadows {
  AppShadows._();

  /// Subtle card shadow — light mode.
  static const List<BoxShadow> cardLight = [
    BoxShadow(
      color: Color(0x0D000000), // black @ 5 %
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  /// Subtle card shadow — dark mode (darker base needs less opacity).
  static const List<BoxShadow> cardDark = [
    BoxShadow(
      color: Color(0x1A000000), // black @ 10 %
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  /// Stronger floating element shadow (FAB, bottom nav).
  static const List<BoxShadow> floatingLight = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> floatingDark = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  /// Helper: returns the correct shadow list based on brightness.
  static List<BoxShadow> card(Brightness brightness) =>
      brightness == Brightness.light ? cardLight : cardDark;

  static List<BoxShadow> floating(Brightness brightness) =>
      brightness == Brightness.light ? floatingLight : floatingDark;
}
