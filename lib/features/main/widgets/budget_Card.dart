import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/features/Profile/Model/InfoCardModel%20.dart';
import 'package:spendly/features/main/providers/main_finance_provider.dart';
import 'package:spendly/features/main/widgets/set_budget_bottom_sheet.dart';
import 'package:spendly/features/main/providers/budget_provider.dart';

class BudgetCard extends ConsumerWidget {
  const BudgetCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final financeAsync = ref.watch(mainFinanceProvider);

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
      loading: () => const CircularProgressIndicator(color: Colors.white),
      error: (e, _) => Text('Error', style: TextStyle(color: Colors.white)),
      data: (finance) {
        final netbalance = finance.netBalance;
        final income = finance.totalIncome;
        final expense = finance.totalExpenses;
        return Container(
          margin: const EdgeInsets.all(16),
          height: 220,
          width: 400,
          decoration: BoxDecoration(
            color: Color(0xff265685),
            borderRadius: BorderRadius.circular(28),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                // 🔹 Top Shape
                Positioned(
                  top: -60,
                  left: -80,
                  child: Image.asset(
                    "assets/images/shape_upper.png",
                    width: 300,
                    fit: BoxFit.cover,
                  ),
                ),

                // 🔹 Bottom Shape
                Positioned(
                  bottom: -100,
                  left: -20,
                  child: Image.asset(
                    "assets/images/shape_down.png",
                    width: 300,
                    fit: BoxFit.cover,
                  ),
                ),

                // 🔹 Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Remaining Budget",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),

                          GestureDetector(
                            onTap: () {
                              showSetBudgetSheet(context);
                            },
                            child: Container(
                              height: 47,
                              width: 120,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xff397BBD),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: const [
                                  Icon(
                                    Icons.settings,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Set Budget",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
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
                        "\$${formatAmount(netbalance)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text(
                                "Income",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "\$$income",
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                "Expenses",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "\$$expense",
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
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

void showSetBudgetSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const SetBudgetSheet(),
  );
}
