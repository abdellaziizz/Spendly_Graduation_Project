import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/core/categories/category_helpers.dart';
import 'package:spendly/features/wallet/models/budget_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Icon resolution — now delegates to the centralized CategoryHelpers so there
// is only ONE icon map in the whole app (category_constants.dart).
// ─────────────────────────────────────────────────────────────────────────────

IconData _iconForKey(String? iconKey) =>
    CategoryHelpers.iconDataForKey(iconKey);

String _iconKeyForIcon(IconData icon) =>
    CategoryHelpers.iconKeyForData(icon);

// ─────────────────────────────────────────────────────────────────────────────

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
        // Use centralized icon resolution
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

    // Persist the category row (name + icon key from centralized system)
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
