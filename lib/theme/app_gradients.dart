import 'package:flutter/material.dart';
import 'package:spendly/theme/colors.dart';

/// Centralised gradient definitions.
abstract final class AppGradients {
  AppGradients._();

  /// Main brand gradient (primary → darker primary).
  static const LinearGradient primary = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Budget card hero gradient.
  static const LinearGradient budgetCard = LinearGradient(
    colors: [Color(0xFF265685), Color(0xFF397BBD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Chatbot AI avatar / send button gradient.
  static const LinearGradient chatBot = LinearGradient(
    colors: [Color(0xFF397BBD), Color(0xFF274C77)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Goals promo banner gradient (purple accent, kept by design).
  static const LinearGradient goalsPromo = LinearGradient(
    colors: [Color(0xFF3B38D0), Color(0xFF6C63FF), Color(0xFF9B59B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Dark mode toggle track gradient.
  static const LinearGradient toggleDark = LinearGradient(
    colors: [Color(0xFF041326), Color(0xFF0E314C)],
  );

  /// Light mode toggle track gradient.
  static const LinearGradient toggleLight = LinearGradient(
    colors: [Color(0xFF77C2D0), Color(0xFF3D91A7)],
  );
}
