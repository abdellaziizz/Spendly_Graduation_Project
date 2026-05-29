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

  double get remainingBudget => budget + totalIncome - totalExpenses;
}

final mainFinanceProvider =
    AsyncNotifierProvider<MainFinanceNotifier, MainFinanceData>(
      MainFinanceNotifier.new,
    );

class MainFinanceNotifier extends AsyncNotifier<MainFinanceData> {
  final supabase = Supabase.instance.client;

  @override
  Future<MainFinanceData> build() async {
    return _fetchFinance();
  }

  Future<void> refreshFinance() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchFinance());
  }

  Future<MainFinanceData> _fetchFinance() async {
    final userId = supabase.auth.currentUser!.id;

    final now = DateTime.now();
    final monthStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-01';

    final budgetRes = await supabase
        .from('monthly_budgets')
        .select('amount')
        .eq('users_id', userId)
        .eq('budget_month', monthStr)
        .maybeSingle();

    final budget =
        double.tryParse(budgetRes?['amount']?.toString() ?? '0') ?? 0.0;

    final totalsRes = await supabase
        .from('v_monthly_totals')
        .select('total_income, total_expenses')
        .eq('users_id', userId)
        .eq('spending_month', monthStr)
        .maybeSingle();

    final totalIncome =
        double.tryParse(totalsRes?['total_income']?.toString() ?? '0') ?? 0.0;
    final totalExpenses =
        double.tryParse(totalsRes?['total_expenses']?.toString() ?? '0') ?? 0.0;

    final netBalance = budget + totalIncome - totalExpenses;

    return MainFinanceData(
      budget: budget,
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      netBalance: netBalance,
    );
  }

  Future<void> setBudget(double amount) async {
    final userId = supabase.auth.currentUser!.id;

    final now = DateTime.now();
    final monthStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-01';

    await supabase.from('monthly_budgets').upsert({
      'users_id': userId,
      'budget_month': monthStr,
      'amount': amount,
    });

    state = const AsyncLoading();
    state = AsyncData(await _fetchFinance());
  }
}
// final mainFinanceProvider = FutureProvider<MainFinanceData>((ref) async {
//   final supabase = Supabase.instance.client;
//   final userId = supabase.auth.currentUser!.id;
//   // Current month as YYYY-MM-01
//   final now = DateTime.now();
//   final monthStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-01';

//   // ── Query 1: monthly budget ──────────────────────────────────────────

//   final budgetRes = await supabase
//       .from('monthly_budgets')
//       .select('amount')
//       .eq('users_id', userId)
//       .eq('budget_month', monthStr)
//       .maybeSingle();

//   final budget =
//       double.tryParse(budgetRes?['amount']?.toString() ?? '0') ?? 0.0;

//   // ── Query 2: monthly totals from view ───────────────────────────────

//   final totalsRes = await supabase
//       .from('v_monthly_totals')
//       .select('total_income, total_expenses, net_balance')
//       .eq('users_id', userId)
//       .eq('spending_month', monthStr)
//       .maybeSingle();

//   final totalIncome =
//       double.tryParse(totalsRes?['total_income']?.toString() ?? '0') ?? 0.0;
//   final totalExpenses =
//       double.tryParse(totalsRes?['total_expenses']?.toString() ?? '0') ?? 0.0;

//   // Net balance rule from spec
//   final double netBalance;
//   if (totalIncome == 0 && totalExpenses == 0) {
//     netBalance = budget;
//   } else {
//     netBalance = totalIncome - totalExpenses;
//   }

//   return MainFinanceData(
//     budget: budget,
//     totalIncome: totalIncome,
//     totalExpenses: totalExpenses,
//     netBalance: netBalance,
//   );
// });
