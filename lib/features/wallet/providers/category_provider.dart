import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/features/wallet/models/budget_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Comprehensive icon map that covers every key produced by:
///   - CreateCategorySheet (user-picked icons)
///   - resolveOrCreateCategory in category_repository.dart
///   - scan_receipt_provider._defaultIconFor
/// Keys must match exactly what is stored in the `categories.icon` DB column.
const Map<String, IconData> _categoryIconMap = {
  // Keys used by CreateCategorySheet / user-picked icons
  'shopping_bag': Icons.shopping_bag,
  'restaurant': Icons.restaurant,
  'directions_car': Icons.directions_car,
  'flight': Icons.flight,
  'fitness_center': Icons.fitness_center,
  'computer': Icons.computer,
  'work': Icons.work,
  'movie': Icons.movie,
  'account_balance_wallet': Icons.account_balance_wallet,
  // Keys produced by resolveOrCreateCategory (category_repository.dart)
  'category_rounded': Icons.category_rounded,
  // Keys produced by scan_receipt_provider._defaultIconFor
  'restaurant_rounded': Icons.restaurant_rounded,
  'shopping_basket_rounded': Icons.shopping_basket_rounded,
  'directions_car_rounded': Icons.directions_car_rounded,
  'receipt_long_rounded': Icons.receipt_long_rounded,
  'shopping_bag_rounded': Icons.shopping_bag_rounded,
  'local_hospital_rounded': Icons.local_hospital_rounded,
  'fitness_center_rounded': Icons.fitness_center_rounded,
};

/// Converts a stored icon key back to [IconData].
/// Falls back to a generic category icon so we never silently lose data.
IconData _iconForKey(String? iconKey) {
  return _categoryIconMap[iconKey] ?? Icons.category_rounded;
}

/// Converts an [IconData] to its stored key string for persistence.
String _iconKeyForIcon(IconData icon) {
  for (final entry in _categoryIconMap.entries) {
    if (entry.value == icon) return entry.key;
  }
  return 'account_balance_wallet';
}

final walletLoadingProvider = StateProvider<bool>((ref) => true);

class CategoryNotifier extends StateNotifier<List<BudgetModel>> {
  CategoryNotifier(this.ref) : super([]) {
    _loadFromSupabase();
  }

  final Ref ref;

  Future<void> _loadFromSupabase() async {
    try {
      ref.read(walletLoadingProvider.notifier).state = true;
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        state = [];
        return;
      }

      final now = DateTime.now();
      final monthStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-01';

      // ── 1. Load per-category spending for the current month ──────────────
      final spends = await supabase
          .from('v_monthly_category_spending')
          .select('category_id, total_spent')
          .eq('spending_month', monthStr)
          .eq('users_id', userId) as List<dynamic>?;

      // ── 2. Load category limits for the current month ────────────────────
      // IMPORTANT: Only categories that have a row in category_limits are
      // "tracked" categories — i.e., the user explicitly created them via the
      // Track tab. Categories auto-created by resolveOrCreateCategory (voice /
      // manual / scan flows) never get a category_limits row and must NOT
      // appear in the Track tab.
      final limits = await supabase
          .from('category_limits')
          .select('category_id, amount')
          .eq('limit_month', monthStr)
          .eq('users_id', userId) as List<dynamic>?;

      // Build spend map: category_id → total spent
      final spendMap = <String, double>{};
      for (final s in (spends ?? [])) {
        final cid = s['category_id'] as String?;
        if (cid != null) {
          spendMap[cid] = double.tryParse(s['total_spent'].toString()) ?? 0.0;
        }
      }

      // Build limit map: category_id → limit amount.
      // Only category IDs present in this map are shown in the Track tab.
      final limitMap = <String, double>{};
      for (final l in (limits ?? [])) {
        final cid = l['category_id'] as String?;
        if (cid != null) {
          limitMap[cid] = double.tryParse(l['amount'].toString()) ?? 0.0;
        }
      }

      // ── 3. Fetch only the categories that have an explicit limit row ──────
      if (limitMap.isEmpty) {
        state = [];
        return;
      }

      final trackedIds = limitMap.keys.toList();
      final cats = await supabase
          .from('categories')
          .select('id, name, icon')
          .eq('users_id', userId)
          .inFilter('id', trackedIds) as List<dynamic>?;

      // ── 4. Build BudgetModel list ─────────────────────────────────────────
      final list = <BudgetModel>[];
      for (final c in (cats ?? [])) {
        final id = c['id'] as String;
        final title = c['name'] as String? ?? '';
        final iconKey = c['icon'] as String?;
        final icon = _iconForKey(iconKey);
        final spent = spendMap[id] ?? 0.0;
        final limit = limitMap[id] ?? 0.0;
        list.add(
          BudgetModel(
            id: id,
            title: title,
            spentAmount: spent,
            limitAmount: limit,
            icon: icon,
            color: Colors.indigoAccent,
          ),
        );
      }

      state = list;
    } catch (e) {
      // Preserve existing state on error so the UI doesn't blank out.
    } finally {
      ref.read(walletLoadingProvider.notifier).state = false;
    }
  }

  /// Adds a new tracked category and persists the limit for the current month.
  Future<void> addBudget(BudgetModel budget) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    // Persist the category row (name + icon key)
    final inserted = await supabase
        .from('categories')
        .insert({
          'users_id': userId,
          'name': budget.title,
          'icon': _iconKeyForIcon(budget.icon),
        })
        .select('id')
        .single();

    final categoryId = inserted['id'] as String;

    // Upsert category_limits — this is what marks the category as "tracked"
    final now = DateTime.now();
    final monthStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-01';
    await supabase.from('category_limits').upsert(
      {
        'users_id': userId,
        'category_id': categoryId,
        'limit_month': monthStr,
        'amount': budget.limitAmount,
      },
      onConflict: 'users_id,category_id,limit_month',
    );

    await _loadFromSupabase();
  }

  Future<void> deleteBudget(String categoryId) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    // Remove the limit row first (marks the category as no longer tracked)
    await supabase
        .from('category_limits')
        .delete()
        .eq('users_id', userId)
        .eq('category_id', categoryId);

    // Remove the category itself
    await supabase
        .from('categories')
        .delete()
        .eq('users_id', userId)
        .eq('id', categoryId);

    // Optimistic local removal
    state = state.where((b) => b.id != categoryId).toList();
  }

  /// Updates the spending limit for a tracked category.
  Future<void> updateBudget(BudgetModel updatedBudget) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final now = DateTime.now();
    final monthStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-01';

    await supabase.from('category_limits').upsert(
      {
        'users_id': userId,
        'category_id': updatedBudget.id,
        'limit_month': monthStr,
        'amount': updatedBudget.limitAmount,
      },
      onConflict: 'users_id,category_id,limit_month',
    );

    // Optimistic local update
    state = [
      for (final b in state) if (b.id == updatedBudget.id) updatedBudget else b,
    ];
  }

  /// Public refresh helper — call this after any transaction mutation so that
  /// the spent amounts displayed in the Track tab are up-to-date.
  Future<void> refresh() async {
    await _loadFromSupabase();
  }
}

final walletProvider =
    StateNotifierProvider<CategoryNotifier, List<BudgetModel>>((ref) {
  return CategoryNotifier(ref);
});
