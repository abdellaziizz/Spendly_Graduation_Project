import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tspendly/features/wallet/models/goal_model.dart';
import 'package:tspendly/features/wallet/widgets/setting_goal_pop.dart';
import '../providers/goal_provider.dart';
import '../widgets/goal_card.dart';

class GoalsTab extends ConsumerWidget {
  const GoalsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80.0),
        itemCount: goals.length,
        itemBuilder: (context, index) {
          return GoalCard(goal: goals[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newGoal = await Navigator.push<GoalModel>(
            context,
            MaterialPageRoute(builder: (context) => const AddGoal()),
          );

          if (newGoal != null) {
            ref.read(goalProvider.notifier).addGoal(newGoal);
          }
        },
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: const BorderSide(color: Colors.grey, width: 0.5),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

//  final List<GoalModel> Goals = [];

//   void _openAddGoalSheet() async {
//     final GoalModel? goalModel = await showModalBottomSheet<GoalModel>(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return const AddTransactionBottomSheet();
//       },
//     );

//     if (goalModel != null) {
//       setState(() {
//         _manualTransactions.insert(0, goalModel);
//       });
//     }
//   }
