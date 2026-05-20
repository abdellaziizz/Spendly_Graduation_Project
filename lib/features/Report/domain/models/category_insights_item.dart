import 'package:flutter/material.dart';

class CategoryInsightsItem {
  const CategoryInsightsItem({
    required this.name,
    required this.amount,
    required this.percent,
    required this.budgetLimit,
    required this.color,
  });

  final String name;
  final double amount;
  final double percent;
  final double budgetLimit;
  final Color color;
}
