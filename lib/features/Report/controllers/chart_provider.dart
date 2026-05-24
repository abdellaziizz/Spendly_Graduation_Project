import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/features/Report/domain/models/live_insights_data.dart';
import 'package:spendly/features/main/providers/main_finance_provider.dart';
import 'package:spendly/features/main/providers/transactions_list_provider.dart';
import 'package:spendly/features/wallet/providers/category_provider.dart';
import 'package:spendly/features/wallet/providers/goal_provider.dart';

// 1. Model to represent individual daily spending data
class DailySpending {
  final double x; // Represents the day index (0 for Mon, 1 for Tue, etc.)
  final double amount;

  DailySpending(this.x, this.amount);
}

// 2. Model to encapsulate all computed chart-ready data for UI
class ChartData {
  final List<DailySpending> spendingList;
  final double maxY;
  final double totalSpending;
  final int highestSpendingDayIndex;

  ChartData({
    required this.spendingList,
    required this.maxY,
    required this.totalSpending,
    required this.highestSpendingDayIndex,
  });
}

// 3. Provider to compile all core state sources into LiveInsightsData reactively
final liveInsightsDataProvider = Provider<LiveInsightsData>((ref) {
  final financeAsync = ref.watch(mainFinanceProvider);
  final transactionsAsync = ref.watch(transactionsListProvider);
  final goalsAsync = ref.watch(goalProvider);
  final categories = ref.watch(walletProvider);

  return LiveInsightsData.fromState(
    finance: financeAsync.valueOrNull,
    transactions: transactionsAsync.valueOrNull ?? const [],
    goals: goalsAsync.valueOrNull ?? const [],
    categories: categories,
  );
});

// 4. Notifier to handle weekly spending state and compute statistics
class WeeklySpendingNotifier extends Notifier<ChartData> {
  @override
  ChartData build() {
    // Watch live insights data reactively
    final liveData = ref.watch(liveInsightsDataProvider);

    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    // Map the actual breakdown dynamically, handling null/empty safely
    final dailyList = liveData.dailyBreakdown;
    final breakdownMap = {
      for (final item in dailyList) item.day: item.amount
    };

    // Ensure all 7 days are represented, substituting 0.0 for days with no transactions
    final spendingList = List.generate(7, (index) {
      final dayName = weekdays[index];
      final amount = breakdownMap[dayName] ?? 0.0;
      return DailySpending(index.toDouble(), amount);
    });

    // Calculate total weekly spending from daily values
    final totalSpending = spendingList.fold<double>(0.0, (sum, item) => sum + item.amount);

    // Identify the highest spending day (the peak) and its index
    double maxSpent = 0.0;
    int highestSpendingDayIndex = 0;
    for (int i = 0; i < spendingList.length; i++) {
      if (spendingList[i].amount > maxSpent) {
        maxSpent = spendingList[i].amount;
        highestSpendingDayIndex = i;
      }
    }

    // Automatically calculate dynamic maxY with beautiful padding (e.g., 15% above peak)
    // Default to 1000.0 if there is no spending data to keep a nice layout
    final maxY = maxSpent > 0 ? maxSpent * 1.15 : 1000.0;

    return ChartData(
      spendingList: spendingList,
      maxY: maxY,
      totalSpending: totalSpending,
      highestSpendingDayIndex: highestSpendingDayIndex,
    );
  }
}

// 5. Global Provider
final weeklySpendingProvider = NotifierProvider<WeeklySpendingNotifier, ChartData>(() {
  return WeeklySpendingNotifier();
});