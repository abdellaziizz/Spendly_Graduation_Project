import 'package:flutter/material.dart';

/// The two transaction types supported by the app.
enum CategoryType { expense, income }

/// A single category definition — the single source of truth for every
/// screen (manual, voice, scan) and for what gets persisted to Supabase.
class AppCategory {
  /// Unique snake_case key — this is the exact string stored in Supabase's
  /// `categories.icon` column.  Must match the entries in [categoryIconMap].
  final String iconKey;

  /// Human-readable display name — stored as `categories.name` in Supabase.
  final String name;

  /// Whether this category belongs to expense or income transactions.
  final CategoryType type;

  /// The Material [IconData] shown in the UI.
  final IconData icon;

  const AppCategory({
    required this.iconKey,
    required this.name,
    required this.type,
    required this.icon,
  });

  bool get isExpense => type == CategoryType.expense;
  bool get isIncome => type == CategoryType.income;
}
