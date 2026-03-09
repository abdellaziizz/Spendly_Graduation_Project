import 'package:flutter/material.dart';

class GoalModel {
  final String id;
  final String title;
  final double savedAmount;
  final double targetAmount;
  final IconData icon;

  GoalModel({
    required this.id,
    required this.title,
    required this.savedAmount,
    required this.targetAmount,
    required this.icon,
  });

  GoalModel copyWith({
    String? id,
    String? title,
    double? savedAmount,
    double? targetAmount,
    IconData? icon,
  }) {
    return GoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      savedAmount: savedAmount ?? this.savedAmount,
      targetAmount: targetAmount ?? this.targetAmount,
      icon: icon ?? this.icon,
    );
  }
}
