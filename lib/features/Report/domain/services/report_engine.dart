import 'package:spendly/features/Report/domain/models/day_spend.dart';
import 'package:spendly/features/Report/domain/models/time_bucket.dart';
import 'package:spendly/features/main/models/transaction_model.dart';

List<double> buildMonthlyHistory(List<TransactionModel> transactions) {
  final monthlyTotals = <String, double>{};
  for (final tx in transactions) {
    final key = monthKey(tx.dateTime);
    monthlyTotals[key] = (monthlyTotals[key] ?? 0) + tx.amount;
  }

  final keys = monthlyTotals.keys.toList()..sort();
  return keys.map((key) => monthlyTotals[key] ?? 0.0).toList();
}

List<DaySpend> buildDailyBreakdown(List<TransactionModel> transactions) {
  final totals = <String, double>{};
  final counts = <String, int>{};

  for (final tx in transactions) {
    final label = weekdayName(tx.dateTime.weekday);
    totals[label] = (totals[label] ?? 0) + tx.amount;
    counts[label] = (counts[label] ?? 0) + 1;
  }

  const order = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return order
      .where((day) => totals.containsKey(day))
      .map((day) => DaySpend(day, totals[day] ?? 0.0, counts[day] ?? 0))
      .toList();
}

List<TimeBucket> buildWeeklyBreakdown(List<TransactionModel> transactions) {
  final buckets = <String, Map<String, dynamic>>{};
  for (final tx in transactions) {
    final label = 'Week ${((tx.dateTime.day - 1) ~/ 7) + 1}';
    final bucket = buckets.putIfAbsent(
      label,
      () => {'total': 0.0, 'count': 0, 'categories': <String, double>{}},
    );
    bucket['total'] = (bucket['total'] as double) + tx.amount;
    bucket['count'] = (bucket['count'] as int) + 1;
    final categories = bucket['categories'] as Map<String, double>;
    categories[tx.category] = (categories[tx.category] ?? 0) + tx.amount;
  }

  final keys = buckets.keys.toList()..sort();
  return keys
      .map(
        (key) => TimeBucket(
          label: key,
          total: buckets[key]?['total'] as double? ?? 0.0,
          count: buckets[key]?['count'] as int? ?? 0,
          categories: Map<String, double>.from(
            buckets[key]?['categories'] as Map? ?? const {},
          ),
        ),
      )
      .toList();
}

Map<String, double> sumByCategory(List<TransactionModel> transactions) {
  final totals = <String, double>{};
  for (final tx in transactions) {
    final key = tx.category.trim().toLowerCase().isEmpty
        ? 'other'
        : tx.category.trim().toLowerCase();
    totals[key] = (totals[key] ?? 0) + tx.amount;
  }
  return totals;
}

String monthKey(DateTime dateTime, {bool fullLabel = false}) {
  if (fullLabel) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${monthNames[dateTime.month - 1]} ${dateTime.year}';
  }
  return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}';
}

String weekdayName(int weekday) {
  const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return names[(weekday - 1).clamp(0, 6)];
}

List<TimeBucket> buildMonthlyBreakdown(List<TransactionModel> transactions) {
  final buckets = <String, Map<String, dynamic>>{};
  for (final tx in transactions) {
    final label = monthKey(tx.dateTime, fullLabel: true);
    final bucket = buckets.putIfAbsent(
      label,
      () => {'total': 0.0, 'count': 0, 'categories': <String, double>{}},
    );
    bucket['total'] = (bucket['total'] as double) + tx.amount;
    bucket['count'] = (bucket['count'] as int) + 1;
    final categories = bucket['categories'] as Map<String, double>;
    categories[tx.category] = (categories[tx.category] ?? 0) + tx.amount;
  }

  final keys = buckets.keys.toList()..sort();
  return keys
      .map(
        (key) => TimeBucket(
          label: key,
          total: buckets[key]?['total'] as double? ?? 0.0,
          count: buckets[key]?['count'] as int? ?? 0,
          categories: Map<String, double>.from(
            buckets[key]?['categories'] as Map? ?? const {},
          ),
        ),
      )
      .toList();
}
