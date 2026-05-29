import 'package:flutter/material.dart';

class CategoryUtils {
  static IconData getIcon(String category) {
    switch (category) {
      case 'Food':
      case 'Food / Dining':
      case 'Dining Out':
        return Icons.restaurant_rounded;
      case 'Groceries':
        return Icons.shopping_basket_rounded;
      case 'Transport':
      case 'Transportation':
        return Icons.directions_car_rounded;
      case 'Shopping':
        return Icons.shopping_bag_rounded;
      case 'Bills':
      case 'Bills & Subscriptions':
        return Icons.receipt_long_rounded;
      case 'Salary':
        return Icons.account_balance_wallet_rounded;
      case 'Health':
        return Icons.local_hospital_rounded;
      case 'Gym / Fitness':
        return Icons.fitness_center_rounded;
      case 'Laptop':
        return Icons.laptop_mac_outlined;
      case 'Beach':
        return Icons.beach_access_outlined;
      case 'Home':
        return Icons.home_outlined;
      case 'Flight':
        return Icons.flight_outlined;
      case 'Gift':
        return Icons.card_giftcard_outlined;
      case 'Date':
        return Icons.favorite_outline;
      case 'Phone':
        return Icons.smartphone_outlined;
      case 'School':
        return Icons.school_outlined;
      default:
        return Icons.category_rounded;
    }
  }

  static Color getColor(String category) {
    switch (category) {
      case 'Food':
      case 'Food / Dining':
      case 'Dining Out':
        return const Color(0xFFFF9800);
      case 'Groceries':
        return const Color(0xFFFF5722);
      case 'Transport':
      case 'Transportation':
        return const Color(0xFFF44336);
      case 'Shopping':
        return const Color(0xFF9C27B0);
      case 'Bills':
      case 'Bills & Subscriptions':
        return const Color(0xFF2196F3);
      case 'Salary':
        return const Color(0xFF1A237E);
      case 'Health':
        return const Color(0xFF4CAF50);
      case 'Gym / Fitness':
        return const Color(0xFFE91E63);
      case 'Laptop':
        return const Color(0xFF607D8B);
      case 'Beach':
        return const Color(0xFF00BCD4);
      case 'Home':
        return const Color(0xFF795548);
      case 'Flight':
        return const Color(0xFF009688);
      case 'Gift':
        return const Color(0xFFFFEB3B);
      case 'Date':
        return const Color(0xFFE91E63);
      case 'Phone':
        return const Color(0xFF3F51B5);
      case 'School':
        return const Color(0xFF9E9E9E);
      default:
        return const Color(0xFF607D8B);
    }
  }
}
