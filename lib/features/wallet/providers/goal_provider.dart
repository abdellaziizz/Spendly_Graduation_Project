import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:tspendly/features/wallet/models/goal_model.dart';

class GoalNotifier extends StateNotifier<List<GoalModel>> {
  GoalNotifier()
    : super([
        GoalModel(
          id: '1',
          title: 'Having A Baby',
          savedAmount: 1000.0,
          targetAmount: 2000.0,
          icon: Icons.child_care,
        ),
        GoalModel(
          id: '2',
          title: 'Getting Married',
          savedAmount: 2000.0,
          targetAmount: 10000.0,
          icon: Icons.favorite,
        ),
        GoalModel(
          id: '3',
          title: 'Travel to Spain',
          savedAmount: 3000.0,
          targetAmount: 20000.0,
          icon: Icons.flight_takeoff,
        ),
        GoalModel(
          id: '4',
          title: 'Buying Playstation 5',
          savedAmount: 3000.0,
          targetAmount: 20000.0,
          icon: Icons.sports_esports,
        ),
        GoalModel(
          id: '5',
          title: 'Vacation',
          savedAmount: 3000.0,
          targetAmount: 20000.0,
          icon: Icons.beach_access,
        ),
      ]);

  void addGoal(GoalModel goal) {
    state = [...state, goal];
  }

  void updateGoalProgress(String id, double additionalAmount) {
    state = [
      for (final goal in state)
        if (goal.id == id)
          goal.copyWith(
            savedAmount: (goal.savedAmount + additionalAmount).clamp(
              0.0,
              goal.targetAmount,
            ),
          )
        else
          goal,
    ];
  }
}

final goalProvider = StateNotifierProvider<GoalNotifier, List<GoalModel>>((
  ref,
) {
  return GoalNotifier();
});
