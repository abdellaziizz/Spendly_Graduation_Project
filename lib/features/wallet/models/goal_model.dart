import 'package:flutter/material.dart';

const Map<String, IconData> goalIconMap = {
  'savings': Icons.savings_outlined,
  'home': Icons.home_outlined,
  'car': Icons.directions_car_outlined,
  'flight': Icons.flight_outlined,
  'gift': Icons.card_giftcard_outlined,
  'laptop': Icons.laptop_mac_outlined,
  'beach': Icons.beach_access_outlined,
  'heart': Icons.favorite_outline,
  'phone': Icons.smartphone_outlined,
  'school': Icons.school_outlined,
};

class GoalModel {
  final String id;
  final String title;
  final double currentAmount;
  final double targetAmount;
  final String icon; // string key stored in DB
  final String status;
  final DateTime? deadlineDate;

  const GoalModel({
    required this.id,
    required this.title,
    required this.currentAmount,
    required this.targetAmount,
    required this.icon,
    this.status = 'active',
    this.deadlineDate,
  });

  /// Percentage saved (0.0 – 1.0).
  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  /// Amount still needed.
  double get amountLeft =>
      (targetAmount - currentAmount).clamp(0.0, double.infinity);

  /// Resolve the stored string key to an [IconData] for rendering.
  IconData get iconData => goalIconMap[icon] ?? Icons.savings_outlined;

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'] as String,
      title: json['title'] as String,
      currentAmount: (json['current_amount'] as num).toDouble(),
      targetAmount: (json['target_amount'] as num).toDouble(),
      icon: json['icon'] as String? ?? 'savings',
      status: json['status'] as String? ?? 'active',
      deadlineDate: json['deadline_date'] != null
          ? DateTime.tryParse(json['deadline_date'] as String)
          : null,
    );
  }

  /// Payload for Supabase INSERT (excludes auto-generated id).
  Map<String, dynamic> toInsertJson({required String userId}) {
    return {
      'users_id': userId,
      'title': title,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'icon': icon,
      'status': status,
      if (deadlineDate != null)
        'deadline_date':
            '${deadlineDate!.year}-${deadlineDate!.month.toString().padLeft(2, '0')}-${deadlineDate!.day.toString().padLeft(2, '0')}',
    };
  }

  GoalModel copyWith({
    String? id,
    String? title,
    double? currentAmount,
    double? targetAmount,
    String? icon,
    String? status,
    DateTime? deadlineDate,
  }) {
    return GoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      currentAmount: currentAmount ?? this.currentAmount,
      targetAmount: targetAmount ?? this.targetAmount,
      icon: icon ?? this.icon,
      status: status ?? this.status,
      deadlineDate: deadlineDate ?? this.deadlineDate,
    );
  }
}
