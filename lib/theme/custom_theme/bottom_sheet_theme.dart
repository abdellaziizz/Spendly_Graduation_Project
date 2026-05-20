import 'package:flutter/material.dart';
import 'package:spendly/theme/colors.dart';
import 'package:spendly/theme/app_radius.dart';

abstract final class TBottomSheetTheme {
  TBottomSheetTheme._();

  static BottomSheetThemeData lightBottomSheet = BottomSheetThemeData(
    backgroundColor: AppColors.lightSurface,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    modalElevation: 0,
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.bottomSheetRadius),
    dragHandleColor: const Color(0xFFD1D1D6),
    dragHandleSize: const Size(40, 4),
    showDragHandle: false, // sheets build their own handle for fine control
    modalBarrierColor: Colors.black54,
  );

  static BottomSheetThemeData darkBottomSheet = BottomSheetThemeData(
    backgroundColor: AppColors.darkSurface,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    modalElevation: 0,
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.bottomSheetRadius),
    dragHandleColor: const Color(0xFF3A4A55),
    dragHandleSize: const Size(40, 4),
    showDragHandle: false,
    modalBarrierColor: Colors.black54,
  );
}
