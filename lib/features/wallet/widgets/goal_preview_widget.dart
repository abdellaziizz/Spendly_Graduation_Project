import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/goal_form_provider.dart';

class GoalPreviewCard extends ConsumerWidget {
  const GoalPreviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalState = ref.watch(goalFormProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.08)),
        ],
      ),
      child: Row(
        children: [
          Icon(
            goalState.selectedIcon ?? Icons.emoji_events,
            size: 40,
            color: Colors.amber,
          ),
          const SizedBox(width: 12),
          Text(
            goalState.goalName.isEmpty ? "Goal Name" : goalState.goalName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
