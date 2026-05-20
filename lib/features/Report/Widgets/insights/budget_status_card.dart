import 'package:flutter/material.dart';
import 'package:spendly/features/Report/domain/models/live_insights_data.dart';

// Comparing Spending vs Predicted Spending
class BudgetStatusCard extends StatelessWidget {
  const BudgetStatusCard({required this.data});

  final LiveInsightsData data;

  @override
  Widget build(BuildContext context) {
    final remaining = data.budgetLimit - data.currentSpending;
    final safe = data.projectedSpending <= data.budgetLimit;
    final statusColor = safe ? Colors.greenAccent : Colors.orangeAccent;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Budget Status',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Current Spending',
                style: TextStyle(color: Colors.black, fontSize: 10),
              ),
              Text(
                '\$${data.currentSpending.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                safe
                    ? ' You\'re on track to stay within budget (\$${remaining.toStringAsFixed(2)} remaining)'
                    : ' You are likely to exceed your current budget.',
                style: const TextStyle(color: Colors.black, fontSize: 11),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: safe
                    ? Colors.green.withOpacity(0.2)
                    : Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                safe ? 'LOW' : 'HIGH',
                style: TextStyle(
                  color: safe ? Colors.greenAccent : Colors.orangeAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Projected Spending',
              style: TextStyle(color: Colors.black, fontSize: 10),
            ),
            Text(
              '\$${data.projectedSpending.toStringAsFixed(2)}',
              style: TextStyle(
                color: statusColor,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Budget Limit',
              style: TextStyle(color: Colors.black, fontSize: 10),
            ),
            Text(
              '\$${data.budgetLimit.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
