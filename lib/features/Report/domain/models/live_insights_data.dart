import 'package:spendly/features/Report/Screens/report_screen.dart';
import 'package:spendly/features/Report/domain/models/category_insights_item.dart';
import 'package:spendly/features/Report/domain/models/day_spend.dart';
import 'package:spendly/features/Report/domain/models/outlook_item.dart';
import 'package:spendly/features/Report/domain/models/time_bucket.dart';
import 'package:spendly/features/Report/domain/services/report_engine.dart';
import 'package:spendly/features/Report/utils/report_colors.dart';
import 'package:spendly/features/main/providers/main_finance_provider.dart';
import 'package:spendly/features/main/models/transaction_model.dart';
import 'package:spendly/features/wallet/models/budget_model.dart';
import 'package:spendly/features/wallet/models/goal_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LiveInsightsData {
  const LiveInsightsData({
    required this.currentSpending,
    required this.budgetLimit,
    required this.projectedSpending,
    required this.monthlyForecast,
    required this.average,
    required this.trend,
    required this.summary,
    required this.projectedIncrease,
    required this.watchCategory,
    required this.categoryBreakdown,
    required this.outlookItems,
    required this.alerts,
    required this.recommendations,
    required this.dailyBreakdown,
    required this.weeklyBreakdown,
    required this.monthlyBreakdown,
    required this.goals,
    required this.transactions,
  });

  final double currentSpending;
  final double budgetLimit;
  final double projectedSpending;
  final double monthlyForecast;
  final double average;
  final String trend;
  final String summary;
  final double projectedIncrease;
  final String watchCategory;
  final List<CategoryInsightsItem> categoryBreakdown;
  final List<OutlookItem> outlookItems;
  final List<String> alerts;
  final List<String> recommendations;
  final List<DaySpend> dailyBreakdown;
  final List<TimeBucket> weeklyBreakdown;
  final List<TimeBucket> monthlyBreakdown;
  final List<GoalModel> goals;
  final List<TransactionModel> transactions;

  factory LiveInsightsData.fromState({
    required MainFinanceData? finance,
    required List<TransactionModel> transactions,
    required List<GoalModel> goals,
    required List<BudgetModel> categories,
  }) {
    final expenseTransactions = transactions
        .where((tx) => tx.type.toLowerCase() != 'income')
        .toList();
    final currentSpendingByCategory = sumByCategory(expenseTransactions);
    final budgetsByCategory = {
      for (final category in categories)
        category.title.toLowerCase(): category.limitAmount,
    };

    final totalBudgetFromCategories = budgetsByCategory.values.fold<double>(
      0,
      (sum, value) => sum + value,
    );
    final totalSpentFromTransactions = expenseTransactions.fold<double>(
      0,
      (sum, tx) => sum + tx.amount,
    );
    final overallBudget = (finance?.budget ?? 0) > 0
        ? finance!.budget
        : totalBudgetFromCategories;
    final currentSpending =
        finance?.totalExpenses ?? totalSpentFromTransactions;

    final monthlyHistory = buildMonthlyHistory(expenseTransactions);
    final forecast = LinearForecast(
      monthlyHistory.isEmpty ? [currentSpending] : monthlyHistory,
    );
    final monthlyForecast = forecast.predicted;
    final average = monthlyHistory.isEmpty
        ? currentSpending
        : monthlyHistory.fold<double>(0, (sum, value) => sum + value) /
              monthlyHistory.length;

    final categoryItems = currentSpendingByCategory.entries.map((entry) {
      final budget = budgetsByCategory[entry.key] ?? 0.0;
      final percent = currentSpending <= 0
          ? 0.0
          : (entry.value / currentSpending) * 100;
      return CategoryInsightsItem(
        name: entry.key,
        amount: entry.value,
        percent: percent,
        budgetLimit: budget,
        color: colorForCategory(entry.key),
      );
    }).toList()..sort((a, b) => b.amount.compareTo(a.amount));

    final topCategory = categoryItems.isNotEmpty
        ? categoryItems.first.name
        : 'none';
    final growthRate = forecast.growthRate;
    final outlook = categoryItems.map((item) {
      final nextMonth = item.amount * (1 + growthRate.clamp(-0.15, 0.20));
      return OutlookItem(
        name: item.name,
        description: item.budgetLimit > 0 && item.amount > item.budgetLimit
            ? 'This category is already above budget.'
            : item.amount > 0
            ? 'This category is likely to keep trending with your current pace.'
            : 'No recent activity in this category.',
        now: item.amount,
        nextMonth: nextMonth,
        change: nextMonth - item.amount,
      );
    }).toList();

    final alerts = <String>[
      if (overallBudget > 0 && currentSpending >= overallBudget * 0.75)
        ' You have used ${(currentSpending / overallBudget * 100).toStringAsFixed(1)}% of your monthly budget.',
      if (growthRate > 0.05) '📈 Increasing spending trend detected.',
      if (goals.any((goal) => goal.progress < 1.0))
        ' You have active savings goals in Wallet.',
      if (topCategory != 'none')
        'Watch: $topCategory is your biggest pressure point.',
    ];

    final recommendations = <String>[
      if (topCategory != 'none')
        'Focus on $topCategory first to reduce pressure quickly.',
      if (goals.isNotEmpty)
        'Tie one savings goal to your biggest expense category to accelerate progress.',
      'Review budget vs spending after every new expense entry.',
    ];

    return LiveInsightsData(
      currentSpending: currentSpending,
      budgetLimit: overallBudget,
      projectedSpending: monthlyForecast,
      monthlyForecast: monthlyForecast,
      average: average,
      trend: forecast.trendDescription,
      summary: currentSpending <= overallBudget
          ? ' Your budget is on track, but your spending is increasing.'
          : ' Your current spending is above the active budget.',
      projectedIncrease: monthlyForecast - currentSpending,
      watchCategory: topCategory,
      categoryBreakdown: categoryItems,
      outlookItems: outlook,
      alerts: alerts.isEmpty ? ['No major alerts right now.'] : alerts,
      recommendations: recommendations,
      dailyBreakdown: buildDailyBreakdown(expenseTransactions),
      weeklyBreakdown: buildWeeklyBreakdown(expenseTransactions),
      monthlyBreakdown: buildMonthlyBreakdown(expenseTransactions),
      goals: goals,
      transactions: transactions,
    );
  }

  Map<String, dynamic> toBackendPayload() {
    final budgets = <String, dynamic>{};
    for (final item in categoryBreakdown) {
      if (item.budgetLimit > 0) {
        budgets[item.name] = item.budgetLimit;
      }
    }

    final currentSpendingMap = <String, dynamic>{
      for (final item in categoryBreakdown) item.name: item.amount,
    };

    final expenses = transactions
        .where((tx) => tx.type.toLowerCase() != 'income')
        .map(
          (tx) => {
            'date': tx.dateTime.toIso8601String(),
            'amount': tx.amount,
            'category': tx.category,
            'description': tx.description,
          },
        )
        .toList();

    return {
      'userId': Supabase.instance.client.auth.currentUser?.id ?? 'local-user',
      'expenses': expenses,
      'budgets': budgets,
      'currentSpending': currentSpendingMap,
      'historicalMonthly': buildMonthlyHistory(
        transactions.where((tx) => tx.type.toLowerCase() != 'income').toList(),
      ),
      'daysInMonth': DateTime(
        DateTime.now().year,
        DateTime.now().month + 1,
        0,
      ).day,
      'currentDay': DateTime.now().day,
      'goals': goals
          .map(
            (goal) => {
              'title': goal.title,
              'currentAmount': goal.currentAmount,
              'targetAmount': goal.targetAmount,
              'progress': goal.progress,
            },
          )
          .toList(),
    };
  }

  Map<String, dynamic> toLocalReport() {
    final now = DateTime.now();
    return {
      'userId': Supabase.instance.client.auth.currentUser?.id ?? 'local-user',
      'periodStart': DateTime(now.year, now.month, 1).toIso8601String(),
      'periodEnd': now.toIso8601String(),
      'totalSpending': currentSpending,
      'totalBudget': budgetLimit,
      'overallProgress': budgetLimit > 0 ? currentSpending / budgetLimit : 0.0,
      'overrunPrediction': {
        'willOverrun': projectedSpending > budgetLimit,
        'confidence': 0.7,
        'projectedSpending': projectedSpending,
        'budgetLimit': budgetLimit,
        'daysRemaining': DateTime(now.year, now.month + 1, 0).day - now.day,
        'riskLevel': projectedSpending > budgetLimit ? 'high' : 'low',
        'message': projectedSpending > budgetLimit
            ? 'Projected spending is above your budget.'
            : 'You are on track to stay within budget.',
      },
      'monthlyForecast': {
        'predictedAmount': monthlyForecast,
        'confidence': 0.7,
        'historicalData': buildMonthlyHistory(
          transactions
              .where((tx) => tx.type.toLowerCase() != 'income')
              .toList(),
        ),
        'trend': monthlyForecast - currentSpending,
        'trendDescription': trend,
      },
      'smartTips': recommendations
          .map(
            (text) => {
              'title': text,
              'description': text,
              'recommendation': text,
              'priority': 'medium',
              'iconType': 'info',
            },
          )
          .toList(),
      'insights': [
        {
          'title': 'Live goal snapshot',
          'description': summary,
          'insights': [summary, 'Goals tracked: ${goals.length}'],
          'recommendations': recommendations,
          'confidence': 0.9,
          'category': 'live_state',
          'generatedAt': now.toIso8601String(),
        },
      ],
      'categoryBreakdown': {
        for (final item in categoryBreakdown) item.name: item.amount,
      },
    };
  }
}
