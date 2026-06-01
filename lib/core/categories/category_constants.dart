import 'package:flutter/material.dart';
import 'package:spendly/core/categories/category_model.dart';

// ── The one and only category list for the whole app ────────────────────────
//
// Rules:
//   • [iconKey]  → exact string stored in `categories.icon` in Supabase.
//   • [name]     → exact string stored in `categories.name` in Supabase.
//   • All parsers (voice / scan) and all UI screens MUST pick categories
//     only from this list.  Never hardcode category strings elsewhere.

/// All expense categories.
const List<AppCategory> kExpenseCategories = [
  AppCategory(
    iconKey: 'restaurant_rounded',
    name: 'Food',
    type: CategoryType.expense,
    icon: Icons.restaurant_rounded,
  ),
  AppCategory(
    iconKey: 'directions_car_rounded',
    name: 'Transportation',
    type: CategoryType.expense,
    icon: Icons.directions_car_rounded,
  ),
  AppCategory(
    iconKey: 'shopping_bag_rounded',
    name: 'Shopping',
    type: CategoryType.expense,
    icon: Icons.shopping_bag_rounded,
  ),
  AppCategory(
    iconKey: 'movie_rounded',
    name: 'Entertainment',
    type: CategoryType.expense,
    icon: Icons.movie_rounded,
  ),
  AppCategory(
    iconKey: 'local_hospital_rounded',
    name: 'Health',
    type: CategoryType.expense,
    icon: Icons.local_hospital_rounded,
  ),
  AppCategory(
    iconKey: 'fitness_center_rounded',
    name: 'Gym',
    type: CategoryType.expense,
    icon: Icons.fitness_center_rounded,
  ),
  AppCategory(
    iconKey: 'school_rounded',
    name: 'Education',
    type: CategoryType.expense,
    icon: Icons.school_rounded,
  ),
  AppCategory(
    iconKey: 'receipt_long_rounded',
    name: 'Bills',
    type: CategoryType.expense,
    icon: Icons.receipt_long_rounded,
  ),
  AppCategory(
    iconKey: 'flight_rounded',
    name: 'Travel',
    type: CategoryType.expense,
    icon: Icons.flight_rounded,
  ),
  AppCategory(
    iconKey: 'category_rounded',
    name: 'Other',
    type: CategoryType.expense,
    icon: Icons.category_rounded,
  ),
];

/// All income categories.
const List<AppCategory> kIncomeCategories = [
  AppCategory(
    iconKey: 'work_rounded',
    name: 'Salary',
    type: CategoryType.income,
    icon: Icons.work_rounded,
  ),
  AppCategory(
    iconKey: 'laptop_mac_rounded',
    name: 'Freelance',
    type: CategoryType.income,
    icon: Icons.laptop_mac_rounded,
  ),
  AppCategory(
    iconKey: 'store_rounded',
    name: 'Business',
    type: CategoryType.income,
    icon: Icons.store_rounded,
  ),
  AppCategory(
    iconKey: 'trending_up_rounded',
    name: 'Investment',
    type: CategoryType.income,
    icon: Icons.trending_up_rounded,
  ),
  AppCategory(
    iconKey: 'card_giftcard_rounded',
    name: 'Gift',
    type: CategoryType.income,
    icon: Icons.card_giftcard_rounded,
  ),
  AppCategory(
    iconKey: 'people_rounded',
    name: 'Family',
    type: CategoryType.income,
    icon: Icons.people_rounded,
  ),
  AppCategory(
    iconKey: 'star_rounded',
    name: 'Bonus',
    type: CategoryType.income,
    icon: Icons.star_rounded,
  ),
  AppCategory(
    iconKey: 'replay_rounded',
    name: 'Refund',
    type: CategoryType.income,
    icon: Icons.replay_rounded,
  ),
  AppCategory(
    iconKey: 'attach_money_rounded',
    name: 'Other',
    type: CategoryType.income,
    icon: Icons.attach_money_rounded,
  ),
];

/// Combined list — every category in the app.
const List<AppCategory> kAllCategories = [
  ...kExpenseCategories,
  ...kIncomeCategories,
];

/// Maps every [AppCategory.iconKey] → [IconData].
/// Used by [categoryIconMap] in the provider layer to restore icons from DB.
const Map<String, IconData> categoryIconMap = {
  // Expense
  'restaurant_rounded': Icons.restaurant_rounded,
  'directions_car_rounded': Icons.directions_car_rounded,
  'shopping_bag_rounded': Icons.shopping_bag_rounded,
  'movie_rounded': Icons.movie_rounded,
  'local_hospital_rounded': Icons.local_hospital_rounded,
  'fitness_center_rounded': Icons.fitness_center_rounded,
  'school_rounded': Icons.school_rounded,
  'receipt_long_rounded': Icons.receipt_long_rounded,
  'flight_rounded': Icons.flight_rounded,
  'category_rounded': Icons.category_rounded,
  // Income
  'work_rounded': Icons.work_rounded,
  'laptop_mac_rounded': Icons.laptop_mac_rounded,
  'store_rounded': Icons.store_rounded,
  'trending_up_rounded': Icons.trending_up_rounded,
  'card_giftcard_rounded': Icons.card_giftcard_rounded,
  'people_rounded': Icons.people_rounded,
  'star_rounded': Icons.star_rounded,
  'replay_rounded': Icons.replay_rounded,
  'attach_money_rounded': Icons.attach_money_rounded,
  // Legacy icon keys (kept for backward-compat with old DB rows)
  'restaurant': Icons.restaurant,
  'shopping_bag': Icons.shopping_bag,
  'directions_car': Icons.directions_car,
  'flight': Icons.flight,
  'fitness_center': Icons.fitness_center,
  'computer': Icons.computer,
  'work': Icons.work,
  'movie': Icons.movie,
  'account_balance_wallet': Icons.account_balance_wallet,
  'category_rounded_old': Icons.category_rounded,
  'shopping_basket_rounded': Icons.shopping_basket_rounded,
  'receipt_long': Icons.receipt_long,
  'local_hospital': Icons.local_hospital,
};
