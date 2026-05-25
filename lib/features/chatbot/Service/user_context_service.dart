import 'package:supabase_flutter/supabase_flutter.dart';

/// Fetches real-time user financial data from Supabase and formats it as a
/// compact text snapshot injected into the first Gemini message of each session.
class UserContextService {
  final SupabaseClient _supabase;

  UserContextService() : _supabase = Supabase.instance.client;

  /// Builds the full context snapshot. Returns an empty string if the user is
  /// not authenticated or if an error occurs (graceful degradation).
  Future<String> buildContext() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return '';

      final results = await Future.wait([
        _fetchProfile(),
        _fetchMonthlyFinances(userId),
        _fetchRecentTransactions(userId),
        _fetchBudgetCategories(userId),
        _fetchSavingsGoals(userId),
      ]);

      final parts = results.cast<String>().where((s) => s.isNotEmpty).join('\n');

      return '[USER DATA SNAPSHOT — use this to personalise your response]\n$parts\n[END SNAPSHOT]';
    } catch (_) {
      return '';
    }
  }

  // ─── Profile ─────────────────────────────────────────────────────────────

  Future<String> _fetchProfile() async {
    try {
      final data = await _supabase
          .from('users')
          .select('full_name, gender, email')
          .single();
      final name   = (data['full_name'] as String? ?? 'Unknown').trim();
      final gender = (data['gender']    as String? ?? 'unknown').trim();
      return 'Profile: $name ($gender)';
    } catch (_) {
      return '';
    }
  }

  // ─── Monthly finances ────────────────────────────────────────────────────

  Future<String> _fetchMonthlyFinances(String userId) async {
    try {
      final now      = DateTime.now();
      final monthStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-01';

      final budgetRes = await _supabase
          .from('monthly_budgets')
          .select('amount')
          .eq('users_id', userId)
          .eq('budget_month', monthStr)
          .maybeSingle();

      final totalsRes = await _supabase
          .from('v_monthly_totals')
          .select('total_income, total_expenses')
          .eq('users_id', userId)
          .eq('spending_month', monthStr)
          .maybeSingle();

      final budget   = _toDouble(budgetRes?['amount']);
      final income   = _toDouble(totalsRes?['total_income']);
      final expenses = _toDouble(totalsRes?['total_expenses']);
      final balance  = budget - expenses + income;

      return 'Finances (this month): budget=\$${_fmt(budget)}, '
          'income=\$${_fmt(income)}, expenses=\$${_fmt(expenses)}, '
          'net=\$${_fmt(balance)}';
    } catch (_) {
      return '';
    }
  }

  // ─── Recent transactions (last 10 for token efficiency) ─────────────────

  Future<String> _fetchRecentTransactions(String userId) async {
    try {
      final data = await _supabase
          .from('transactions')
          .select('type, amount, title, transaction_date, categories(name)')
          .eq('users_id', userId)
          .order('transaction_date', ascending: false)
          .order('created_at', ascending: false)
          .limit(10);

      if ((data as List).isEmpty) return '';

      final lines = data.map((row) {
        final type    = (row['type']   as String? ?? 'expense')[0]; // 'e' or 'i'
        final amount  = _toDouble(row['amount']);
        final title   = row['title']   as String? ?? 'Untitled';
        final date    = (row['transaction_date'] as String? ?? '').substring(0, 10);
        final cat     = (row['categories'] as Map<String, dynamic>?)?['name'] as String? ?? '';
        final sign    = type == 'i' ? '+' : '-';
        return '$sign\$${_fmt(amount)} $cat/$title ($date)';
      }).join(', ');

      return 'Last 10 transactions: $lines';
    } catch (_) {
      return '';
    }
  }

  // ─── Budget categories ───────────────────────────────────────────────────

  Future<String> _fetchBudgetCategories(String userId) async {
    try {
      final now      = DateTime.now();
      final monthStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-01';

      final cats = await _supabase
          .from('categories')
          .select('id, name')
          .eq('users_id', userId) as List<dynamic>?;

      if (cats == null || cats.isEmpty) return '';

      final spends = await _supabase
          .from('v_monthly_category_spending')
          .select('category_id, total_spent')
          .eq('spending_month', monthStr)
          .eq('users_id', userId) as List<dynamic>?;

      final limits = await _supabase
          .from('category_limits')
          .select('category_id, amount')
          .eq('limit_month', monthStr)
          .eq('users_id', userId) as List<dynamic>?;

      final spendMap = <String, double>{};
      for (final s in (spends ?? [])) {
        final cid = s['category_id'] as String?;
        if (cid != null) spendMap[cid] = _toDouble(s['total_spent']);
      }
      final limitMap = <String, double>{};
      for (final l in (limits ?? [])) {
        final cid = l['category_id'] as String?;
        if (cid != null) limitMap[cid] = _toDouble(l['amount']);
      }

      final parts = cats.map((c) {
        final id    = c['id']   as String;
        final name  = c['name'] as String? ?? 'Unknown';
        final spent = spendMap[id] ?? 0.0;
        final limit = limitMap[id] ?? 0.0;
        final pct   = limit > 0 ? '${((spent / limit) * 100).round()}%' : 'no limit';
        return '$name: \$${_fmt(spent)}/\$${_fmt(limit)} ($pct)';
      }).join(', ');

      return 'Budget categories: $parts';
    } catch (_) {
      return '';
    }
  }

  // ─── Savings goals ───────────────────────────────────────────────────────

  Future<String> _fetchSavingsGoals(String userId) async {
    try {
      final data = await _supabase
          .from('goals')
          .select('title, current_amount, target_amount, deadline_date')
          .eq('users_id', userId)
          .eq('status', 'active')
          .order('created_at', ascending: false)
          .limit(5) as List<dynamic>?;

      if (data == null || data.isEmpty) return '';

      final parts = data.map((g) {
        final title   = g['title']          as String? ?? 'Goal';
        final current = _toDouble(g['current_amount']);
        final target  = _toDouble(g['target_amount']);
        final pct     = target > 0 ? '${((current / target) * 100).round()}%' : '0%';
        final dl      = g['deadline_date']  as String?;
        final dlPart  = dl != null ? ' due $dl' : '';
        return '$title: \$${_fmt(current)}/\$${_fmt(target)} ($pct$dlPart)';
      }).join(', ');

      return 'Savings goals: $parts';
    } catch (_) {
      return '';
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  double _toDouble(dynamic value) =>
      double.tryParse(value?.toString() ?? '0') ?? 0.0;

  String _fmt(double value) {
    final s = value.toStringAsFixed(2);
    if (s.endsWith('.00')) return s.substring(0, s.length - 3);
    if (s.endsWith('0')) return s.substring(0, s.length - 1);
    return s;
  }
}
