import 'package:flutter/material.dart';
import 'package:spendly/core/categories/category_constants.dart';
import 'package:spendly/core/categories/category_model.dart';

/// Utility helpers for looking up categories by name or icon key.
/// All logic that previously existed across [CategoryUtils], parsers, and
/// providers is now consolidated here so nothing is duplicated.
class CategoryHelpers {
  CategoryHelpers._(); // static-only class

  // ── Lookup by name ────────────────────────────────────────────────────────

  /// Returns the [AppCategory] whose [name] matches [categoryName]
  /// (case-insensitive).  Falls back to the first "Other" expense category.
  static AppCategory findByName(String categoryName) {
    final lower = categoryName.toLowerCase().trim();
    for (final cat in kAllCategories) {
      if (cat.name.toLowerCase() == lower) return cat;
    }
    // Graceful fallback — never returns null
    return kExpenseCategories.firstWhere((c) => c.name == 'Other');
  }

  /// Returns the [AppCategory] for [iconKey].
  /// Falls back to the "Other" expense category.
  static AppCategory findByIconKey(String? iconKey) {
    if (iconKey == null) {
      return kExpenseCategories.firstWhere((c) => c.name == 'Other');
    }
    for (final cat in kAllCategories) {
      if (cat.iconKey == iconKey) return cat;
    }
    return kExpenseCategories.firstWhere((c) => c.name == 'Other');
  }

  // ── Icon resolution ───────────────────────────────────────────────────────

  /// Converts a DB icon key back to [IconData].
  /// Checks [categoryIconMap] first (covers legacy keys), then searches
  /// [kAllCategories] directly.
  static IconData iconDataForKey(String? iconKey) {
    if (iconKey == null) return Icons.category_rounded;
    final fromMap = categoryIconMap[iconKey];
    if (fromMap != null) return fromMap;
    // Fallback: search canonical list
    for (final cat in kAllCategories) {
      if (cat.iconKey == iconKey) return cat.icon;
    }
    return Icons.category_rounded;
  }

  /// Returns the icon key string for a given [IconData].
  static String iconKeyForData(IconData icon) {
    for (final cat in kAllCategories) {
      if (cat.icon == icon) return cat.iconKey;
    }
    // Also check the full legacy map
    for (final entry in categoryIconMap.entries) {
      if (entry.value == icon) return entry.key;
    }
    return 'category_rounded';
  }

  // ── Category colour ───────────────────────────────────────────────────────

  /// Returns a themed colour for [categoryName].
  static Color colorForName(String categoryName) {
    switch (categoryName) {
      // Expense
      case 'Food':
        return const Color(0xFFFF9800);
      case 'Transportation':
        return const Color(0xFFF44336);
      case 'Shopping':
        return const Color(0xFF9C27B0);
      case 'Entertainment':
        return const Color(0xFF3F51B5);
      case 'Health':
        return const Color(0xFF4CAF50);
      case 'Gym':
        return const Color(0xFFE91E63);
      case 'Education':
        return const Color(0xFF9E9E9E);
      case 'Bills':
        return const Color(0xFF2196F3);
      case 'Travel':
        return const Color(0xFF009688);
      // Income
      case 'Salary':
        return const Color(0xFF1A237E);
      case 'Freelance':
        return const Color(0xFF607D8B);
      case 'Business':
        return const Color(0xFF00796B);
      case 'Investment':
        return const Color(0xFF388E3C);
      case 'Gift':
        return const Color(0xFFFFEB3B);
      case 'Family':
        return const Color(0xFF7B1FA2);
      case 'Bonus':
        return const Color(0xFFF57C00);
      case 'Refund':
        return const Color(0xFF0288D1);
      default:
        return const Color(0xFF607D8B);
    }
  }

  // ── Filtered lists ────────────────────────────────────────────────────────

  /// Returns only expense categories.
  static List<AppCategory> get expenseCategories => kExpenseCategories;

  /// Returns only income categories.
  static List<AppCategory> get incomeCategories => kIncomeCategories;

  // ── Canonical name resolution ─────────────────────────────────────────────

  /// Maps a raw detected category string (from parsers or legacy data) to
  /// the canonical [AppCategory.name].  Returns 'Other' if no match found.
  ///
  /// This is the gateway that converts arbitrary parser output into a name
  /// that is guaranteed to exist in [kAllCategories].
  static String canonicalise(String raw, {bool isExpense = true}) {
    // Direct name match (covers most cases)
    final lower = raw.toLowerCase().trim();
    for (final cat in kAllCategories) {
      if (cat.name.toLowerCase() == lower) return cat.name;
    }

    // Legacy alias map — old parser strings → new canonical names
    const aliases = <String, String>{
      'food / dining': 'Food',
      'dining out': 'Food',
      'groceries': 'Food',
      'grocery': 'Food',
      'gym / fitness': 'Gym',
      'bills & subscriptions': 'Bills',
      'bills and subscriptions': 'Bills',
      'transport': 'Transportation',
      'personal transfer': 'Family',
    };

    final alias = aliases[lower];
    if (alias != null) return alias;

    // If the type doesn't match, return "Other" for that type
    return isExpense ? 'Other' : 'Other';
  }
}
