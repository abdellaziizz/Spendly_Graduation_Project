import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:spendly/features/main/providers/main_finance_provider.dart';
import 'package:spendly/features/authentication/providers/currency_provider.dart';
import 'package:spendly/features/main/widgets/set_budget_bottom.dart';
import 'package:spendly/theme/app_gradients.dart';
import 'package:spendly/theme/app_radius.dart';

class BudgetCard extends ConsumerWidget {
  const BudgetCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final financeAsync = ref.watch(mainFinanceProvider);
    final curSymbol = ref.watch(currencySymbolProvider);

    String formatAmount(double amount) {
      String str = amount.toStringAsFixed(2);
      List<String> parts = str.split('.');
      String formattedWhole = parts[0].replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
      return '$formattedWhole.${parts[1]}';
    }

    return financeAsync.when(
      loading: () => Skeletonizer(
        enabled: true,
        child: Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: AppGradients.budgetCard,
            borderRadius: AppRadius.xxlBorderRadius,
          ),
        ),
      ),
      error: (e, _) =>
          Text(e.toString(), style: const TextStyle(color: Colors.white)),
      data: (finance) {
        final netbalance = finance.remainingBudget;
        final income = finance.totalIncome;
        final expense = finance.totalExpenses;
        final budget = finance.budget;

        return Container(
          margin: const EdgeInsets.all(16),
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: AppGradients.budgetCard,
            borderRadius: AppRadius.xxlBorderRadius,
          ),
          child: ClipRRect(
            borderRadius: AppRadius.xxlBorderRadius,
            child: Stack(
              children: [
                // Decorative shapes
                Positioned(
                  top: -60,
                  left: -80,
                  child: Image.asset(
                    'assets/images/shape_upper.png',
                    width: 300,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: -100,
                  left: -20,
                  child: Image.asset(
                    'assets/images/shape_down.png',
                    width: 300,
                    fit: BoxFit.cover,
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Remaining Budget',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => showSetBudgetSheet(context),
                            child: Container(
                              height: 40,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: AppRadius.fullBorderRadius,
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.settings,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Set Budget',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$curSymbol${formatAmount(netbalance)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _StatColumn(
                            label: 'Income',
                            value: '$curSymbol${formatAmount(income)}',
                          ),
                          _StatColumn(
                            label: 'Expenses',
                            value: '$curSymbol${formatAmount(expense)}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.white70),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

void showSetBudgetSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const SetBudgetSheet(),
  );
}
