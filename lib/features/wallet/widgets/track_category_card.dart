import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/budget_model.dart';
import '../providers/wallet_provider.dart';

class TrackCategoryCard extends ConsumerWidget {
  final BudgetModel budget;

  const TrackCategoryCard({Key? key, required this.budget}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref
        .read(walletProvider.notifier)
        .calculateProgress(budget);
    final bool hasLimit = budget.limitAmount > 0;

    // Derived values for display
    final String usageText = hasLimit
        ? '${(progress * 100).toInt()}% used'
        : 'No limit set';

    final Color usageColor = hasLimit
        ? (progress > 0.75
              ? Colors.red
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.6))
        : Theme.of(context).colorScheme.onSurface.withOpacity(0.4);

    final Color primaryColor =
        budget.color ?? Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon Circle
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: primaryColor, width: 4.0),
            ),
            child: Icon(budget.icon, color: primaryColor, size: 28),
          ),
          const SizedBox(height: 12.0),
          // Category Title
          Text(
            budget.title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16.0,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4.0),
          // Usage Text
          Text(
            usageText,
            style: TextStyle(
              fontSize: 12.0,
              color: usageColor,
              fontWeight: hasLimit && progress > 0.75
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 12.0),
          // Set Limit Button
          InkWell(
            onTap: () {
              // Add/edit limit logic
            },
            child: Text(
              'Set Limit',
              style: TextStyle(
                color: Colors.blueAccent.shade400,
                fontWeight: FontWeight.w600,
                fontSize: 14.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
