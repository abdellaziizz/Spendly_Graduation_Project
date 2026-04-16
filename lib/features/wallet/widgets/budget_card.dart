import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tspendly/features/wallet/models/budget_model.dart';
import '../providers/wallet_provider.dart';
import 'progress_bar.dart';

class BudgetCard extends ConsumerWidget {
  final BudgetModel budget;

  const BudgetCard({Key? key, required this.budget}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref
        .read(walletProvider.notifier)
        .calculateProgress(budget);

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
              child: Icon(budget.icon, color: Color(0xff0466C8), size: 28),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    budget.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'EGP ${budget.spentAmount.toStringAsFixed(2)} of ${budget.limitAmount.toStringAsFixed(2)}',
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
