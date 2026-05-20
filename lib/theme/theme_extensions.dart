import 'package:flutter/material.dart';
import 'package:spendly/theme/colors.dart';

/// BuildContext extension for ergonomic, non-verbose theme access.
///
/// Usage:
///   context.colors.primary          → ColorScheme.primary
///   context.textTheme.bodyMedium    → TextTheme
///   context.isDark                  → true when dark mode is active
///   context.appColors               → AppColors static reference (light/dark)
extension ThemeX on BuildContext {
  ThemeData    get theme     => Theme.of(this);
  ColorScheme  get colors    => Theme.of(this).colorScheme;
  TextTheme    get textTheme => Theme.of(this).textTheme;
  bool         get isDark    => Theme.of(this).brightness == Brightness.dark;

  /// Convenience: surface colour (card backgrounds, bottom sheets …)
  Color get surface        => colors.surface;

  /// Convenience: main text colour on any surface.
  Color get onSurface      => colors.onSurface;

  /// Convenience: subdued text (60 % opacity of onSurface).
  Color get subtitleColor  => colors.onSurface.withValues(alpha: 0.6);

  /// Convenience: divider / placeholder (40 % opacity).
  Color get hintColor      => colors.onSurface.withValues(alpha: 0.4);

  /// The goals / wallet purple accent — always constant regardless of mode.
  Color get goalsAccent    => AppColors.goalsAccent;

  /// Success green.
  Color get successColor   => AppColors.success;

  /// Error red.
  Color get errorColor     => colors.error;
}
