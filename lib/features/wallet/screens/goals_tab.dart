import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/goal_provider.dart';
import '../widgets/goal_card.dart';

class GoalsTab extends ConsumerWidget {
  const GoalsTab({Key? key}) : super(key: key);

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
        onPressed: () {
          // Add goal logic here
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
