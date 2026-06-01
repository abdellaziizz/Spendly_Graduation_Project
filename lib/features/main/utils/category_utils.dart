import 'package:flutter/material.dart';
import 'package:spendly/core/categories/category_helpers.dart';

/// Thin wrapper kept for backward compatibility with [home_screen.dart] and
/// any other call-sites that already import this file.
///
/// All real logic now lives in [CategoryHelpers] — do not add new logic here.
class CategoryUtils {
  CategoryUtils._();

  /// Returns the icon for [category] name.
  static IconData getIcon(String category) =>
      CategoryHelpers.findByName(category).icon;

  /// Returns the themed colour for [category] name.
  static Color getColor(String category) =>
      CategoryHelpers.colorForName(category);
}
