import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MainFinanceData {
  final double budget;
  final double totalIncome;
  final double totalExpenses;
  final double netBalance;

  const MainFinanceData({
    required this.budget,
    required this.totalIncome,
    required this.totalExpenses,
    required this.netBalance,
  });
}

final mainFinanceProvider = FutureProvider<MainFinanceData>((ref) async {
  final supabase = Supabase.instance.client;

  // Current month as YYYY-MM-01
  final now = DateTime.now();
  final monthStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-01';

  // ── Query 1: monthly budget ──────────────────────────────────────────
  // SQL: SELECT amount FROM public.monthly_budgets
  //      WHERE users_id = auth.uid() AND budget_month = '2025-05-01'
  final budgetRes = await supabase
      .from('monthly_budgets')
      .select('amount')
      .eq('budget_month', monthStr)
      .maybeSingle();

  final budget =
      double.tryParse(budgetRes?['amount']?.toString() ?? '0') ?? 0.0;

  // ── Query 2: monthly totals from view ───────────────────────────────
  // SQL: SELECT total_income, total_expenses, net_balance
  //      FROM public.v_monthly_totals
  //      WHERE users_id = auth.uid() AND spending_month = '2025-05-01'
  final totalsRes = await supabase
      .from('v_monthly_totals')
      .select('total_income, total_expenses, net_balance')
      .eq('spending_month', monthStr)
      .maybeSingle();

  final totalIncome =
      double.tryParse(totalsRes?['total_income']?.toString() ?? '0') ?? 0.0;
  final totalExpenses =
      double.tryParse(totalsRes?['total_expenses']?.toString() ?? '0') ?? 0.0;

  // Net balance rule from spec
  final double netBalance;
  if (totalIncome == 0 && totalExpenses == 0) {
    netBalance = budget;
  } else {
    netBalance = totalIncome - totalExpenses;
  }

  return MainFinanceData(
    budget: budget,
    totalIncome: totalIncome,
    totalExpenses: totalExpenses,
    netBalance: netBalance,
  );
});
