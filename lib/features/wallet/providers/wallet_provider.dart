import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/budget_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WalletNotifier extends StateNotifier<List<BudgetModel>> {
  WalletNotifier()
    : super([
        BudgetModel(
          id: '1',
          title: 'Education',
          spentAmount: 0.0,
          limitAmount: 12000.0,
          icon: Icons.menu_book,
        ),
        BudgetModel(
          id: '2',
          title: 'Entertainment',
          spentAmount: 100.0,
          limitAmount: 1500.0,
          icon: Icons.sports_esports,
        ),
        BudgetModel(
          id: '3',
          title: 'Fitness',
          spentAmount: 1450.0,
          limitAmount: 1550.0,
          icon: Icons.fitness_center,
        ),
        BudgetModel(
          id: '4',
          title: 'Food',
          spentAmount: 3500.0,
          limitAmount: 7000.0,
          icon: Icons.restaurant,
        ),
        BudgetModel(
          id: '5',
          title: 'Fuel',
          spentAmount: 4500.0,
          limitAmount: 4500.0,
          icon: Icons.local_gas_station,
        ),
      ]);

  void addBudget(BudgetModel budget) {
    state = [...state, budget];
  }

  void updateBudget(BudgetModel updatedBudget) {
    state = [
      for (final budget in state)
        if (budget.id == updatedBudget.id) updatedBudget else budget,
    ];
  }

  double calculateProgress(BudgetModel budget) {
    if (budget.limitAmount == 0) return 0.0;
    return (budget.spentAmount / budget.limitAmount).clamp(0.0, 1.0);
  }
}

final walletProvider = StateNotifierProvider<WalletNotifier, List<BudgetModel>>(
  (ref) {
    return WalletNotifier();
  },
);
