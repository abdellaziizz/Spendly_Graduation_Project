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
    // Use ref.watch so this card rebuilds whenever walletProvider state changes
    // (e.g. after a transaction is added and the provider refreshes).
    final budgets = ref.watch(walletProvider);
    // Find the up-to-date version of this budget from the provider state.
    // Falls back to the passed prop if not found (should not happen in practice).
    final currentBudget =
        budgets.firstWhere((b) => b.id == budget.id, orElse: () => budget);

    final double progress = currentBudget.limitAmount > 0
        ? currentBudget.spentAmount / currentBudget.limitAmount
        : 0.0;
    final bool hasLimit = currentBudget.limitAmount > 0;

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
        currentBudget.color ?? Theme.of(context).colorScheme.primary;

    // Progress colour: green < 70%, orange 70–100%, red > 100%
    Color progressColor() {
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
          // ── Warning badge for over-limit categories ──────────────────────
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

          // ── Delete button ────────────────────────────────────────────────
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
                    content: Text(
                      'This will remove "${currentBudget.title}" from your wallet categories.',
                    ),
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
                    await ref
                        .read(walletProvider.notifier)
                        .deleteBudget(currentBudget.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${currentBudget.title} deleted'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to delete category: $e'),
                        ),
                      );
                    }
                  }
                }
              },
              icon: Icon(
                Icons.delete_outline,
                size: 18,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.75),
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.05),
                minimumSize: const Size(40, 40),
                padding: EdgeInsets.zero,
              ),
            ),
          ),

          // ── Card body ────────────────────────────────────────────────────
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 8.0),

                // ── Icon circle — circular progress only when limit is set ──
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Only render the progress ring when a limit exists.
                    // When there is no limit, value: null makes Flutter render
                    // an indeterminate spinner, which is visually wrong.
                    if (hasLimit)
                      SizedBox(
                        width: 78,
                        height: 78,
                        child: CircularProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          strokeWidth: 6.0,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progressColor(),
                          ),
                          backgroundColor: primaryColor.withOpacity(0.12),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: primaryColor.withOpacity(0.3),
                          width: 1.0,
                        ),
                      ),
                      // Always display the user-selected icon from the model.
                      child: Icon(
                        currentBudget.icon,
                        color: primaryColor,
                        size: 28,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),

                // ── Category name ─────────────────────────────────────────
                Text(
                  currentBudget.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.0,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4.0),

                // ── Spent / Limit amounts ──────────────────────────────────
                Text(
                  hasLimit
                      ? '$curSymbol${currentBudget.spentAmount.toStringAsFixed(2)} / $curSymbol${currentBudget.limitAmount.toStringAsFixed(2)}'
                      : '$curSymbol${currentBudget.spentAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: usageColor,
                    fontWeight: hasLimit && progress > 0.75
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 6.0),

                // ── Usage text ─────────────────────────────────────────────
                Text(
                  usageText,
                  style: TextStyle(fontSize: 12.0, color: usageColor),
                ),
                const SizedBox(height: 12.0),

                // ── Set Limit button ───────────────────────────────────────
                InkWell(
                  onTap: () async {
                    final controller = TextEditingController(
                      text: currentBudget.limitAmount > 0
                          ? currentBudget.limitAmount.toString()
                          : '',
                    );
                    final result = await showDialog<double?>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Set category limit'),
                        content: TextField(
                          controller: controller,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^[0-9]*\.?[0-9]{0,2}'),
                            ),
                          ],
                          decoration: const InputDecoration(
                            hintText: 'Enter limit amount',
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(null),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              final v = double.tryParse(
                                controller.text.trim(),
                              );
                              Navigator.of(ctx).pop(v);
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    );

                    if (result != null) {
                      try {
                        final updated = currentBudget.copyWith(
                          limitAmount: result,
                        );
                        await ref
                            .read(walletProvider.notifier)
                            .updateBudget(updated);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to save limit: $e'),
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: Text(
                    hasLimit ? 'Edit Limit' : 'Set Limit',
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
