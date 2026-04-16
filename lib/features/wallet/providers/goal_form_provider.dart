import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter/material.dart';

class GoalFormState {
  final String goalName;
  final IconData? selectedIcon;

  GoalFormState({this.goalName = '', this.selectedIcon});

  GoalFormState copyWith({String? goalName, IconData? selectedIcon}) {
    return GoalFormState(
      goalName: goalName ?? this.goalName,
      selectedIcon: selectedIcon ?? this.selectedIcon,
    );
  }
}

class GoalFormNotifier extends StateNotifier<GoalFormState> {
  GoalFormNotifier() : super(GoalFormState());

  void setGoalName(String name) {
    state = state.copyWith(goalName: name);
  }

  void setIcon(IconData icon) {
    state = state.copyWith(selectedIcon: icon);
  }
}

final goalFormProvider = StateNotifierProvider<GoalFormNotifier, GoalFormState>(
  (ref) => GoalFormNotifier(),
);
