import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tspendly/features/wallet/models/goal_model.dart';
import '../providers/goal_form_provider.dart';

/// A small preview card shown while the user fills the Add Goal form.
class GoalPreviewCard extends ConsumerWidget {
  const GoalPreviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalState = ref.watch(goalFormProvider);
    final iconKey = goalState.selectedIcon ?? 'savings';
    final iconData = goalIconMap[iconKey] ?? Icons.savings_outlined;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withValues(alpha: 0.08),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(iconData, size: 40, color: const Color(0xFF3B38D0)),
          const SizedBox(width: 12),
          Text(
            goalState.goalName.isEmpty ? 'Goal Name' : goalState.goalName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
