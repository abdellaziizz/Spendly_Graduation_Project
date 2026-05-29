import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/theme/colors.dart';
import 'package:spendly/features/authentication/providers/currency_provider.dart';
import '../models/budget_model.dart';
import '../providers/category_provider.dart';
import 'package:flutter/services.dart';

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
              ? AppColors.expense
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))
        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4);

    final curSymbol = ref.watch(currencySymbolProvider);

    final Color primaryColor =
        budget.color ?? Theme.of(context).colorScheme.primary;

    // Determine progress color: green < 70%, orange 70-100%, red >100%
    Color progressColor() {
      if (!hasLimit) return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2);
      if (progress >= 1.0) return AppColors.expense;
      if (progress >= 0.7) return Colors.orangeAccent;
      return Colors.green;
    }

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
      child: Stack(
        children: [
          if (hasLimit && progress >= 0.75)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: progress >= 1.0 ? AppColors.expense : Colors.orange,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.9),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '!',
                    style: TextStyle(
                      color: Colors.white,
                        fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              tooltip: 'Delete category',
              onPressed: () async {
                final shouldDelete = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete category?'),
                    content: Text('This will remove "${budget.title}" from your wallet categories.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.expense,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (shouldDelete == true && context.mounted) {
                  try {
                    await ref.read(walletProvider.notifier).deleteBudget(budget.id);
                    await ref.read(walletProvider.notifier).refresh();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${budget.title} deleted')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to delete category: $e')),
                      );
                    }
                  }
                }
              },
              icon: Icon(
                Icons.delete_outline,
                size: 18,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.05),
                minimumSize: const Size(40, 40),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 8.0),
                // Icon Circle with circular progress and overflow badge
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 78,
                      height: 78,
                      child: CircularProgressIndicator(
                        value: hasLimit ? (progress.clamp(0.0, 1.0)) : null,
                        strokeWidth: 6.0,
                        valueColor: AlwaysStoppedAnimation<Color>(progressColor()),
                        backgroundColor: primaryColor.withOpacity(0.12),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(color: primaryColor.withOpacity(0.3), width: 1.0),
                      ),
                      child: Icon(budget.icon, color: primaryColor, size: 28),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                Text(
                  budget.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.0,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  hasLimit
                      ? '${curSymbol}${budget.spentAmount.toStringAsFixed(2)} / ${curSymbol}${budget.limitAmount.toStringAsFixed(2)}'
                      : '${curSymbol}${budget.spentAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: usageColor,
                    fontWeight: hasLimit && progress > 0.75 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 6.0),
                Text(
                  usageText,
                  style: TextStyle(
                    fontSize: 12.0,
                    color: usageColor,
                  ),
                ),
                const SizedBox(height: 12.0),
                InkWell(
                  onTap: () async {
                    final controller = TextEditingController(text: budget.limitAmount > 0 ? budget.limitAmount.toString() : '');
                    final result = await showDialog<double?>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Set category limit'),
                        content: TextField(
                          controller: controller,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*\.?[0-9]{0,2}'))],
                          decoration: const InputDecoration(hintText: 'Enter limit amount'),
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(ctx).pop(null), child: const Text('Cancel')),
                          ElevatedButton(
                            onPressed: () {
                              final v = double.tryParse(controller.text.trim());
                              Navigator.of(ctx).pop(v);
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    );

                    if (result != null) {
                      try {
                        final updated = budget.copyWith(limitAmount: result);
                        await ref.read(walletProvider.notifier).updateBudget(updated);
                      } catch (e) {
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save limit: $e')));
                      }
                    }
                  },
                  child: Text(
                    'Set Limit',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
