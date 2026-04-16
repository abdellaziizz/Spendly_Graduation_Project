import 'package:flutter/material.dart';
import 'package:tspendly/features/wallet/models/goal_model.dart';
import 'progress_bar.dart';

class GoalCard extends StatelessWidget {
  final GoalModel goal;

  const GoalCard({Key? key, required this.goal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = goal.targetAmount > 0
        ? (goal.savedAmount / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Icon(goal.icon, color: Colors.blue, size: 28),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'EGP ${goal.savedAmount.toStringAsFixed(2)} / ${goal.targetAmount.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12.0),
                  ),
                  const SizedBox(height: 8.0),
                  ProgressBar(progress: progress),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
