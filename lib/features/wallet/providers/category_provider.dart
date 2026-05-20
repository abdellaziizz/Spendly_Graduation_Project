import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/features/wallet/models/budget_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryNotifier extends StateNotifier<List<BudgetModel>> {
  CategoryNotifier() : super([]) {
    _loadFromSupabase();
  }

  Future<void> _loadFromSupabase() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final now = DateTime.now();
      final monthStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-01';

      // Load categories
      final cats = await supabase
          .from('categories')
          .select('id, name, icon')
          .eq('users_id', userId) as List<dynamic>?;

      // Load per-category spending for the month
      final spends = await supabase
          .from('v_monthly_category_spending')
          .select('category_id, total_spent')
          .eq('spending_month', monthStr)
          .eq('users_id', userId) as List<dynamic>?;

      // Load category limits for the month
      final limits = await supabase
          .from('category_limits')
          .select('category_id, amount')
          .eq('limit_month', monthStr)
          .eq('users_id', userId) as List<dynamic>?;

      final spendMap = <String, double>{};
      for (final s in (spends ?? [])) {
        final cid = s['category_id'] as String?;
        if (cid != null) spendMap[cid] = double.tryParse(s['total_spent'].toString()) ?? 0.0;
      }

      final limitMap = <String, double>{};
      for (final l in (limits ?? [])) {
        final cid = l['category_id'] as String?;
        if (cid != null) limitMap[cid] = double.tryParse(l['amount'].toString()) ?? 0.0;
      }

      final list = <BudgetModel>[];
      for (final c in (cats ?? [])) {
        final id = c['id'] as String;
        final title = c['name'] as String? ?? '';
        final iconKey = c['icon'] as String? ?? '';
        // Basic icon mapping: keep a default icon for now
        final icon = Icons.account_balance_wallet;
        final spent = spendMap[id] ?? 0.0;
        final limit = limitMap[id] ?? 0.0;
        list.add(BudgetModel(
          id: id,
          title: title,
          spentAmount: spent,
          limitAmount: limit,
          icon: icon,
          color: Colors.blue,
        ));
      }

      state = list;
    } catch (e) {
      // ignore and keep state empty
    }
  }

  /// Adds a new category and persists the per-category limit for the current month.
  Future<void> addBudget(BudgetModel budget) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    // Create category
    final inserted = await supabase.from('categories').insert({
      'users_id': userId,
      'name': budget.title,
      'icon': 'category_rounded',
    }).select('id').single();

    final categoryId = inserted['id'] as String;

    // Upsert category_limits for current month
    final now = DateTime.now();
    final monthStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-01';
    await supabase.from('category_limits').upsert({
      'users_id': userId,
      'category_id': categoryId,
      'limit_month': monthStr,
      'amount': budget.limitAmount,
    }, onConflict: 'users_id,category_id,limit_month');

    // Refresh state
    await _loadFromSupabase();
  }

  Future<void> updateBudget(BudgetModel updatedBudget) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final now = DateTime.now();
    final monthStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-01';

    await supabase.from('category_limits').upsert({
      'users_id': userId,
      'category_id': updatedBudget.id,
      'limit_month': monthStr,
      'amount': updatedBudget.limitAmount,
    }, onConflict: 'users_id,category_id,limit_month');

    // Update local state optimistically
    state = [
      for (final b in state) if (b.id == updatedBudget.id) updatedBudget else b,
    ];
  }

  double calculateProgress(BudgetModel budget) {
    if (budget.limitAmount == 0) return 0.0;
    return (budget.spentAmount / budget.limitAmount).clamp(0.0, 1.0);
  }
}

final walletProvider = StateNotifierProvider<CategoryNotifier, List<BudgetModel>>((ref) {
  return CategoryNotifier();
});
