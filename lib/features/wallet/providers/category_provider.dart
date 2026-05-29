import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/features/wallet/models/budget_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const Map<String, IconData> _categoryIconMap = {
  'shopping_bag': Icons.shopping_bag,
  'restaurant': Icons.restaurant,
  'directions_car': Icons.directions_car,
  'flight': Icons.flight,
  'fitness_center': Icons.fitness_center,
  'computer': Icons.computer,
  'work': Icons.work,
  'movie': Icons.movie,
  'account_balance_wallet': Icons.account_balance_wallet,
};

String _iconKeyForIcon(IconData icon) {
  for (final entry in _categoryIconMap.entries) {
    if (entry.value == icon) return entry.key;
  }
  return 'account_balance_wallet';
}

IconData _iconForKey(String? iconKey) {
  return _categoryIconMap[iconKey] ?? Icons.account_balance_wallet;
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
        final iconKey = c['icon'] as String?;
        final icon = _iconForKey(iconKey);
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
    } finally {
      ref.read(walletLoadingProvider.notifier).state = false;
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
      'icon': _iconKeyForIcon(budget.icon),
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

  Future<void> deleteBudget(String categoryId) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    await supabase
        .from('category_limits')
        .delete()
        .eq('users_id', userId)
      .eq('category_id', categoryId);

    await supabase
        .from('categories')
        .delete()
        .eq('users_id', userId)
        .eq('id', categoryId);

    state = state.where((b) => b.id != categoryId).toList();
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

  /// Public refresh helper to reload data from Supabase.
  Future<void> refresh() async {
    await _loadFromSupabase();
  }

  double calculateProgress(BudgetModel budget) {
    if (budget.limitAmount == 0) return 0.0;
    return budget.spentAmount / budget.limitAmount;
  }
}

final walletProvider = StateNotifierProvider<CategoryNotifier, List<BudgetModel>>((ref) {
  return CategoryNotifier(ref);
});
