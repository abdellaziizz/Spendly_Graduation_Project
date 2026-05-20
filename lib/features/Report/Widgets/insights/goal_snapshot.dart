import 'package:spendly/features/authentication/providers/currency_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:spendly/features/Report/Widgets/common/card_box.dart';
import 'package:spendly/features/Report/Widgets/common/snapshot_tile.dart';
import 'package:spendly/features/wallet/models/goal_model.dart';

// Tracking Goal Progress
class GoalSnapshot extends ConsumerWidget {
  const GoalSnapshot({required this.goals});

  final List<GoalModel> goals;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curSymbol = ref.watch(currencySymbolProvider);
    if (goals.isEmpty) {
      return const CardBox(
        child: Text(
          'No active goals yet. Set a goal in the Wallet tab and it will appear here.',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
      );
    }

    final totalTarget = goals.fold<double>(
      0,
      (sum, goal) => sum + goal.targetAmount,
    );
    final totalCurrent = goals.fold<double>(
      0,
      (sum, goal) => sum + goal.currentAmount,
    );
    final totalRemaining = goals.fold<double>(
      0,
      (sum, goal) => sum + goal.amountLeft,
    );

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Goal Progress',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w400,
                color: Color(0xff1a1a1a),
              ),
            ),
            const SizedBox(height: 24),

            // Metrics Row (Saved | Target | Remaining)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMetricColumn(
                  'Saved',
                  '${curSymbol}${totalCurrent.toStringAsFixed(2)}',
                  const Color(0xff3b30e1),
                ),
                _buildDivider(),
                _buildMetricColumn(
                  'Target',
                  '${curSymbol}${totalTarget.toStringAsFixed(2)}',
                  const Color(0xff1a1a1a),
                ),
                _buildDivider(),
                _buildMetricColumn(
                  'Remaining',
                  '${curSymbol}${totalRemaining.toStringAsFixed(2)}',
                  const Color(0xffb25e13),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: Color(0xfff0f0f5), thickness: 1.5),
            const SizedBox(height: 16),
            ...goals.map(
              (goal) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Icon Container
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Color(0xff3525CD).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            goal.iconData,
                            color: Color(0xff3525CD),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Title
                        Expanded(
                          child: Text(
                            goal.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff1a1a1a),
                            ),
                          ),
                        ),

                        // Percentage Text
                        Text(
                          '${(goal.progress * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff4a4a5a),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: goal.progress,
                        minHeight: 10,
                        backgroundColor: const Color(0xfff0f0f7),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xff3525CD),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Individual Goal Progress Items
          ],
        ),
      ),
    );
  }
}

Widget _buildDivider() {
  return Container(height: 40, width: 1, color: const Color(0xffe2e2ea));
}

Widget _buildMetricColumn(String label, String value, Color valueColor) {
  return Expanded(
    child: Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xff747485),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    ),
  );
}
// Row(
//                   children: [
//                     Icon(goal.iconData, color: Colors.black, size: 18),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         goal.title,
//                         style: const TextStyle(
//                           color: Colors.black,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ),
//                     Text(
//                       '${(goal.progress * 100).toStringAsFixed(0)}%',
//                       style: const TextStyle(
//                         color: Colors.black,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ],
//                 )