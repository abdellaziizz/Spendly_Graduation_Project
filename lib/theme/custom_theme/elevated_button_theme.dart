import 'package:flutter/material.dart';

class EElevatedButtonTheme {
  EElevatedButtonTheme._();
  static ElevatedButtonThemeData lightElevated = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xff274C77),
      fixedSize: const Size(335, 55),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(20),
      ),
      textStyle: TextStyle(color: Colors.white),
    ),
  );

  static ElevatedButtonThemeData darkElevated = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xff82A0BC),
      fixedSize: const Size(335, 55),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(20),
      ),
      textStyle: TextStyle(color: Color(0xff21295C)),
    ),
  );
}
