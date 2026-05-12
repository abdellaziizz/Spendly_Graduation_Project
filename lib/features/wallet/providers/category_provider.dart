import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tspendly/features/wallet/models/budget_model.dart';

class CategoryNotifier extends StateNotifier<List<BudgetModel>> {
  CategoryNotifier()
    : super([
        BudgetModel(
          id: '1',
          title: 'Food',
          spentAmount: 800.0,
          limitAmount: 1000.0,
          icon: Icons.restaurant,
          color: Colors.red,
        ),
        BudgetModel(
          id: '2',
          title: 'Transport',
          spentAmount: 350.0,
          limitAmount: 1000.0,
          icon: Icons.directions_car,
          color: Colors.blue,
        ),
        BudgetModel(
          id: '3',
          title: 'Shopping',
          spentAmount: 650.0,
          limitAmount: 1000.0,
          icon: Icons.shopping_bag,
          color: Colors.brown,
        ),
        BudgetModel(
          id: '4',
          title: 'Bills',
          spentAmount: 200.0,
          limitAmount: 1000.0,
          icon: Icons.receipt,
          color: Colors.teal,
        ),
        BudgetModel(
          id: '5',
          title: 'Entertainment',
          spentAmount: 0.0,
          limitAmount: 0.0,
          icon: Icons.movie,
          color: Colors.purple,
        ),
        BudgetModel(
          id: '6',
          title: 'Health',
          spentAmount: 100.0,
          limitAmount: 1000.0,
          icon: Icons.medical_services,
          color: Colors.pink,
        ),
        BudgetModel(
          id: '7',
          title: 'Other',
          spentAmount: 0.0,
          limitAmount: 0.0,
          icon: Icons.more_horiz,
          color: Colors.grey,
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

final walletProvider =
    StateNotifierProvider<CategoryNotifier, List<BudgetModel>>((ref) {
      return CategoryNotifier();
    });
