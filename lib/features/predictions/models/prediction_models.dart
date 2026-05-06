import 'package:flutter/material.dart';

/// Prediction models for ML features

class OverrunPrediction {
  final bool willOverrun;
  final double confidence;
  final double projectedSpending;
  final double budgetLimit;
  final double currentSpending;
  final String riskLevel;
  final int daysLeft;
  final double dailyRate;
  final String message;

  OverrunPrediction({
    required this.willOverrun,
    required this.confidence,
    required this.projectedSpending,
    required this.budgetLimit,
    required this.currentSpending,
    required this.riskLevel,
    required this.daysLeft,
    required this.dailyRate,
    required this.message,
  });

  factory OverrunPrediction.fromJson(Map<String, dynamic> json) {
    return OverrunPrediction(
      willOverrun: json['will_overrun'] ?? false,
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      projectedSpending: (json['projected_spending'] ?? 0.0).toDouble(),
      budgetLimit: (json['budget_limit'] ?? 0.0).toDouble(),
      currentSpending: (json['current_spending'] ?? 0.0).toDouble(),
      riskLevel: json['risk_level'] ?? 'low',
      daysLeft: json['days_left'] ?? 0,
      dailyRate: (json['daily_rate'] ?? 0.0).toDouble(),
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'will_overrun': willOverrun,
    'confidence': confidence,
    'projected_spending': projectedSpending,
    'budget_limit': budgetLimit,
    'current_spending': currentSpending,
    'risk_level': riskLevel,
    'days_left': daysLeft,
    'daily_rate': dailyRate,
    'message': message,
  };

  String get riskIcon {
    switch (riskLevel) {
      case 'high':
        return '🔴';
      case 'medium':
        return '🟠';
      case 'low':
        return '🟢';
      default:
        return '⚪';
    }
  }
}


class MonthlForecast {
  final double predictedAmount;
  final double confidence;
  final String trend;
  final String trendDescription;
  final double average;
  final int monthsAnalyzed;
  final double? minSpending;
  final double? maxSpending;
  final double? currentMonth;

  MonthlForecast({
    required this.predictedAmount,
    required this.confidence,
    required this.trend,
    required this.trendDescription,
    required this.average,
    required this.monthsAnalyzed,
    this.minSpending,
    this.maxSpending,
    this.currentMonth,
  });

  factory MonthlForecast.fromJson(Map<String, dynamic> json) {
    return MonthlForecast(
      predictedAmount: (json['predicted_amount'] ?? 0.0).toDouble(),
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      trend: json['trend'] ?? 'stable',
      trendDescription: json['trend_description'] ?? '',
      average: (json['average'] ?? 0.0).toDouble(),
      monthsAnalyzed: json['months_analyzed'] ?? 0,
      minSpending: json['min_spending'] != null ? (json['min_spending'] as num).toDouble() : null,
      maxSpending: json['max_spending'] != null ? (json['max_spending'] as num).toDouble() : null,
      currentMonth: json['current_month'] != null ? (json['current_month'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'predicted_amount': predictedAmount,
    'confidence': confidence,
    'trend': trend,
    'trend_description': trendDescription,
    'average': average,
    'months_analyzed': monthsAnalyzed,
    'min_spending': minSpending,
    'max_spending': maxSpending,
    'current_month': currentMonth,
  };
}


class CategoryPrediction {
  final String category;
  final double confidence;
  final List<AlternativeCategory> alternatives;

  CategoryPrediction({
    required this.category,
    required this.confidence,
    required this.alternatives,
  });

  factory CategoryPrediction.fromJson(Map<String, dynamic> json) {
    return CategoryPrediction(
      category: json['category'] ?? 'other',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      alternatives: (json['alternatives'] as List?)
          ?.map((alt) => AlternativeCategory.fromJson(alt))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'category': category,
    'confidence': confidence,
    'alternatives': alternatives.map((alt) => alt.toJson()).toList(),
  };
}


class AlternativeCategory {
  final String category;
  final double confidence;

  AlternativeCategory({
    required this.category,
    required this.confidence,
  });

  factory AlternativeCategory.fromJson(Map<String, dynamic> json) {
    return AlternativeCategory(
      category: json['category'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'category': category,
    'confidence': confidence,
  };
}


class InsightCard {
  final String title;
  final String description;
  final String type;
  final String? icon;
  final String? action;
  final String priority;

  InsightCard({
    required this.title,
    required this.description,
    required this.type,
    this.icon,
    this.action,
    required this.priority,
  });

  factory InsightCard.fromJson(Map<String, dynamic> json) {
    return InsightCard(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'info',
      icon: json['icon'],
      action: json['action'],
      priority: json['priority'] ?? 'medium',
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'type': type,
    'icon': icon,
    'action': action,
    'priority': priority,
  };

  Color get priorityColor {
    switch (priority) {
      case 'high':
        return Color(0xFFD32F2F);
      case 'medium':
        return Color(0xFFFF9800);
      case 'low':
        return Color(0xFF2E7D32);
      default:
        return Color(0xFF397BBD);
    }
  }
}

class PredictionResponse {
  final OverrunPrediction? overrunPrediction;
  final MonthlForecast? forecast;
  final InsightData? insights;
  final List<ExpenseWithCategory>? classifiedExpenses;
  final String? error;

  PredictionResponse({
    this.overrunPrediction,
    this.forecast,
    this.insights,
    this.classifiedExpenses,
    this.error,
  });

  factory PredictionResponse.fromJson(Map<String, dynamic> json) {
    return PredictionResponse(
      overrunPrediction: json['overrunPrediction'] != null 
          ? OverrunPrediction.fromJson(json['overrunPrediction'])
          : null,
      forecast: json['forecast'] != null 
          ? MonthlForecast.fromJson(json['forecast'])
          : null,
      insights: json['insights'] != null 
          ? InsightData.fromJson(json['insights'])
          : null,
      classifiedExpenses: (json['classifiedExpenses'] as List?)
          ?.map((e) => ExpenseWithCategory.fromJson(e))
          .toList(),
      error: json['error'],
    );
  }

  bool get hasError => error != null;
}


class InsightData {
  final List<InsightCard>? budgetInsights;
  final Map<String, dynamic>? spendingPatterns;
  final List<InsightCard>? recommendations;
  final List<InsightCard>? alerts;
  final List<CategoryOutlook>? categoryOutlooks;
  final Map<String, dynamic>? comparisonSummary;
  final String? summary;

  InsightData({
    this.budgetInsights,
    this.spendingPatterns,
    this.recommendations,
    this.alerts,
    this.categoryOutlooks,
    this.comparisonSummary,
    this.summary,
  });

  factory InsightData.fromJson(Map<String, dynamic> json) {
    return InsightData(
      budgetInsights: (json['budget_insights'] as List?)
          ?.map((item) => InsightCard.fromJson(item))
          .toList(),
      spendingPatterns: json['spending_patterns'],
      recommendations: (json['recommendations'] as List?)
          ?.map((item) => InsightCard.fromJson(item))
          .toList(),
      alerts: (json['alerts'] as List?)
          ?.map((item) => InsightCard.fromJson(item))
          .toList(),
      categoryOutlooks: (json['category_outlooks'] as List?)
          ?.map((item) => CategoryOutlook.fromJson(item))
          .toList(),
      comparisonSummary: json['comparison_summary'],
      summary: json['summary'],
    );
  }
}

class CategoryOutlook {
  final String category;
  final double currentAmount;
  final double currentShare;
  final double projectedNextMonth;
  final double delta;
  final String outlook;
  final String trendAlignment;
  final String reason;
  final String budgetSignal;

  CategoryOutlook({
    required this.category,
    required this.currentAmount,
    required this.currentShare,
    required this.projectedNextMonth,
    required this.delta,
    required this.outlook,
    required this.trendAlignment,
    required this.reason,
    required this.budgetSignal,
  });

  factory CategoryOutlook.fromJson(Map<String, dynamic> json) {
    return CategoryOutlook(
      category: json['category'] ?? 'other',
      currentAmount: (json['current_amount'] ?? 0.0).toDouble(),
      currentShare: (json['current_share'] ?? 0.0).toDouble(),
      projectedNextMonth: (json['projected_next_month'] ?? 0.0).toDouble(),
      delta: (json['delta'] ?? 0.0).toDouble(),
      outlook: json['outlook'] ?? 'stable',
      trendAlignment: json['trend_alignment'] ?? 'stable',
      reason: json['reason'] ?? '',
      budgetSignal: json['budget_signal'] ?? 'stable',
    );
  }
}


class ExpenseWithCategory {
  final String description;
  final double amount;
  final String date;
  final String category;

  ExpenseWithCategory({
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
  });

  factory ExpenseWithCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseWithCategory(
      description: json['description'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      date: json['date'] ?? '',
      category: json['category'] ?? 'other',
    );
  }
}


/// Daily spending data for reports
class DailySpendData {
  final String day;
  final double amount;
  final int transactionCount;

  DailySpendData({
    required this.day,
    required this.amount,
    required this.transactionCount,
  });
}


/// Weekly spending breakdown
class WeeklySpendData {
  final String week;
  final double totalAmount;
  final Map<String, double> byCategory;
  final int transactionCount;

  WeeklySpendData({
    required this.week,
    required this.totalAmount,
    required this.byCategory,
    required this.transactionCount,
  });
}


/// Monthly spending breakdown
class MonthlySpendData {
  final String month;
  final double totalAmount;
  final Map<String, double> byCategory;
  final int transactionCount;

  MonthlySpendData({
    required this.month,
    required this.totalAmount,
    required this.byCategory,
    required this.transactionCount,
  });
}
