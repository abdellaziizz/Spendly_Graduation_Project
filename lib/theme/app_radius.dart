import 'package:flutter/material.dart';

/// Centralised border-radius scale.
abstract final class AppRadius {
  AppRadius._();

  static const double xs  = 4.0;
  static const double sm  = 8.0;
  static const double md  = 12.0;
  static const double lg  = 16.0;
  static const double xl  = 20.0;
  static const double xxl = 24.0;
  static const double full = 100.0; // pill shape

  // Convenience BorderRadius objects
  static final BorderRadius xsBorderRadius  = BorderRadius.circular(xs);
  static final BorderRadius smBorderRadius  = BorderRadius.circular(sm);
  static final BorderRadius mdBorderRadius  = BorderRadius.circular(md);
  static final BorderRadius lgBorderRadius  = BorderRadius.circular(lg);
  static final BorderRadius xlBorderRadius  = BorderRadius.circular(xl);
  static final BorderRadius xxlBorderRadius = BorderRadius.circular(xxl);
  static final BorderRadius fullBorderRadius = BorderRadius.circular(full);

  // Typical bottom-sheet top rounding
  static const BorderRadius bottomSheetRadius = BorderRadius.vertical(
    top: Radius.circular(xxl),
  );
}
