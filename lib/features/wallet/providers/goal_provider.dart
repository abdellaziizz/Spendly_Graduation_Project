import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/features/wallet/models/goal_model.dart';
import 'package:spendly/main.dart';

/// Fetches and manages goals from public.goals in Supabase.
class GoalNotifier extends AsyncNotifier<List<GoalModel>> {
  @override
  Future<List<GoalModel>> build() async {
    return _fetchGoals();
  }

  Future<List<GoalModel>> _fetchGoals() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await supabase
        .from('goals')
        .select()
        .eq('users_id', userId)
        .order('created_at', ascending: false);

    return (data as List<dynamic>)
        .map((e) => GoalModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Insert a new goal into Supabase then refresh the list.
  Future<void> addGoal(GoalModel goal) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await supabase.from('goals').insert(goal.toInsertJson(userId: userId));

    // Re-fetch to get the DB-generated id and any server-side defaults.
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchGoals);
  }

  /// Update saved progress for a goal in Supabase.
  Future<void> updateGoalProgress(String id, double newAmount) async {
    await supabase
        .from('goals')
        .update({'current_amount': newAmount})
        .eq('id', id);

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchGoals);
  }
}

final goalProvider = AsyncNotifierProvider<GoalNotifier, List<GoalModel>>(
  GoalNotifier.new,
);
