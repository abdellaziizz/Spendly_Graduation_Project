import 'package:flutter/material.dart';

class BudgetModel {
  final String id;
  final String title;
  final double spentAmount;
  final double limitAmount;
  final IconData icon;
  final Color? color;

  BudgetModel({
    required this.id,
    required this.title,
    required this.spentAmount,
    required this.limitAmount,
    required this.icon,
    this.color,
  });

  BudgetModel copyWith({
    String? id,
    String? title,
    double? spentAmount,
    double? limitAmount,
    IconData? icon,
    Color? color,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      title: title ?? this.title,
      spentAmount: spentAmount ?? this.spentAmount,
      limitAmount: limitAmount ?? this.limitAmount,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }
}
