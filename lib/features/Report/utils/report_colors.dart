import 'dart:ui';

import 'package:flutter/material.dart';

Color colorForCategory(String category) {
  switch (category.toLowerCase()) {
    case 'food':
      return const Color(0xFF4CAF50);
    case 'transport':
      return const Color(0xFF42A5F5);
    case 'shopping':
      return const Color(0xFF26A69A);
    case 'utilities':
    case 'bills':
      return const Color(0xFFFF9800);
    case 'health':
      return const Color(0xFFBDBDBD);
    case 'entertainment':
      return const Color(0xFF8D6E63);
    default:
      return Colors.indigoAccent;
  }
}
