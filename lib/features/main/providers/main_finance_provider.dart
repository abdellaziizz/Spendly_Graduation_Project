import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spendly/services/cache/local_cache_service.dart';
import 'package:spendly/services/connectivity/connectivity_provider.dart';

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
    final isOnline = ref.read(connectivityServiceProvider).isOnline;
    final cache = LocalCacheService.instance;

    if (!isOnline) {
      final cached = await cache.getCachedFinanceData();
      if (cached != null) {
        // Adjust cached finance data with pending transactions
        final pendingQueue = await cache.getPendingQueue();
        double netOffset = 0;
        double incOffset = 0;
        double expOffset = 0;

        for (final p in pendingQueue) {
          if (p.type == 'income') {
            incOffset += p.amount;
            netOffset += p.amount;
          } else {
            expOffset += p.amount;
            netOffset -= p.amount;
          }
        }

        return MainFinanceData(
          budget: cached.budget,
          totalIncome: cached.totalIncome + incOffset,
          totalExpenses: cached.totalExpenses + expOffset,
          netBalance: cached.netBalance + netOffset,
        );
      }
      return const MainFinanceData(
        budget: 0,
        totalIncome: 0,
        totalExpenses: 0,
        netBalance: 0,
      );
    }

    try {
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
          double.tryParse(totalsRes?['total_expenses']?.toString() ?? '0') ??
          0.0;

      final netBalance = budget + totalIncome - totalExpenses;
      final data = MainFinanceData(
        budget: budget,
        totalIncome: totalIncome,
        totalExpenses: totalExpenses,
        netBalance: netBalance,
      );

      // Save to cache
      await cache.cacheFinanceData(data);

      // Check if there are pending transactions to adjust the currently fetched totals
      // Since pending transactions haven't been synced to backend yet.
      final pendingQueue = await cache.getPendingQueue();
      double netOffset = 0;
      double incOffset = 0;
      double expOffset = 0;

      for (final p in pendingQueue) {
        if (p.type == 'income') {
          incOffset += p.amount;
          netOffset += p.amount;
        } else {
          expOffset += p.amount;
          netOffset -= p.amount;
        }
      }

      return MainFinanceData(
        budget: data.budget,
        totalIncome: data.totalIncome + incOffset,
        totalExpenses: data.totalExpenses + expOffset,
        netBalance: data.netBalance + netOffset,
      );
    } catch (e) {
      final cached = await cache.getCachedFinanceData();
      if (cached != null) return cached;
      return const MainFinanceData(
        budget: 0,
        totalIncome: 0,
        totalExpenses: 0,
        netBalance: 0,
      );
    }
  }

  Future<void> setBudget(double amount) async {
    final userId = supabase.auth.currentUser!.id;

    final now = DateTime.now();
    final monthStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-01';

    await supabase.from('monthly_budgets').upsert({
      'users_id': userId,
      'budget_month': monthStr,
      'amount': amount,
    }, onConflict: 'users_id,budget_month');

    state = const AsyncLoading();
    state = AsyncData(await _fetchFinance());
  }
}
