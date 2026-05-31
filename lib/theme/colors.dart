import 'package:flutter/material.dart';

/// All app color tokens in one place.
/// Never use raw Color(0x…) literals in UI code — reference these instead.
abstract final class AppColors {
  AppColors._();

  // ── Primary Brand ───────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF397BBD);
  static const Color primaryDark = Color(0xFF274C77);

  // ── Backgrounds ─────────────────────────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFEEF0F2);
  static const Color backgroundDark = Color(0xFF051923);

  // ── Surfaces (cards, bottom sheets, dialogs) ────────────────────────────────
  static const Color lightSurface = Colors.white;
  static const Color darkSurface = Color(0xFF1B2B36);

  /// Elevated surface in dark mode (slightly lighter than darkSurface).
  static const Color darkSurfaceElevated = Color(0xFF253545);

  // ── Text ────────────────────────────────────────────────────────────────────
  static const Color textPrimaryLight = Color(0xFF1C1C1C);
  static const Color textPrimaryDark = Colors.white;
  static const Color textSecondaryLight = Color(0xFF6B6B6B);
  static const Color textSecondaryDark = Color(0xFFA0A0A0);

  // ── Status ──────────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFFBC02D);
  static const Color income = Color(0xFF2E7D32);
  static const Color expense = Color(0xFFD32F2F);

  // ── Buttons ─────────────────────────────────────────────────────────────────
  static const Color buttonLight = Color(0xFF274C77);
  static const Color buttonDark = Color(0xFF82A0BC);

  // ── Accent: Goals / Wallet (purple, kept by design) ────────────────────────
  static const Color goalsAccent = Color(0xFF3B38D0);
  static const Color goalsAccentVariant = Color(0xFF6C63FF);

  // ── Chat screen ──────────────────────────────────────────────────────────────
  /// User message bubble background.
  static const Color chatUserBubble = Color(0xFF006BE5);

  /// AI message bubble background (light mode).
  static const Color chatAiBubbleLight = Color(0xFFF2F4F5);

  /// AI message bubble background (dark mode).
  static const Color chatAiBubbleDark = Color(0xFF1E2A35);

  /// Chat screen background (light).
  static const Color chatBgLight = Color(0xFFF8F8F8);

  /// Chat screen background (dark).
  static const Color chatBgDark = Color(0xFF0A1820);

  // ── Scan receipt screen ──────────────────────────────────────────────────────
  /// Scan corner/progress colour — always green regardless of mode.
  static const Color scanAccent = Color(0xFF4CAF50);

  // ── Divider / outline ────────────────────────────────────────────────────────
  static const Color dividerLight = Color(0xFFE5E5EA);
  static const Color dividerDark = Color(0xFF2A3A45);

  // ── Input fill ───────────────────────────────────────────────────────────────
  static const Color inputFillLight = Colors.white;
  static const Color inputFillDark = Color(0xFF1B2B36);
}
