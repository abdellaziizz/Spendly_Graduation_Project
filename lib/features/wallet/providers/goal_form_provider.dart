import 'package:flutter_riverpod/flutter_riverpod.dart';

class GoalFormState {
  final String goalName;
  final String? selectedIcon; // icon key string, e.g. "laptop"

  const GoalFormState({this.goalName = '', this.selectedIcon});

  GoalFormState copyWith({String? goalName, String? selectedIcon}) {
    return GoalFormState(
      goalName: goalName ?? this.goalName,
      selectedIcon: selectedIcon ?? this.selectedIcon,
    );
  }
}

class GoalFormNotifier extends StateNotifier<GoalFormState> {
  GoalFormNotifier() : super(const GoalFormState());

  void setGoalName(String name) {
    state = state.copyWith(goalName: name);
  }

  void setIcon(String icon) {
    state = state.copyWith(selectedIcon: icon);
  }

  void reset() {
    state = const GoalFormState();
  }
}

final goalFormProvider =
    StateNotifierProvider.autoDispose<GoalFormNotifier, GoalFormState>(
  (ref) => GoalFormNotifier(),
);
