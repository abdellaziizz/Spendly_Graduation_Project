import 'package:spendly/features/authentication/providers/currency_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:spendly/features/Report/Widgets/common/card_box.dart';
import 'package:spendly/features/wallet/models/goal_model.dart';
import 'package:spendly/theme/colors.dart';
import 'package:spendly/theme/app_radius.dart';
import 'package:spendly/theme/theme_extensions.dart';
import 'package:spendly/features/wallet/widgets/add_funds_sheet.dart';

class GoalSnapshot extends ConsumerWidget {
  const GoalSnapshot({required this.goals});

  final List<GoalModel> goals;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curSymbol = ref.watch(currencySymbolProvider);
    final isDark = context.isDark;

    if (goals.isEmpty) {
      return const CardBox(
        child: Text(
          'No active goals yet. Set a goal in the Wallet tab and it will appear here.',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
      );
    }

    final totalTarget  = goals.fold<double>(0, (s, g) => s + g.targetAmount);
    final totalCurrent = goals.fold<double>(0, (s, g) => s + g.currentAmount);
    final totalLeft    = goals.fold<double>(0, (s, g) => s + g.amountLeft);

    final cardBg    = isDark ? AppColors.darkSurface : Colors.white;
    final titleClr  = isDark ? AppColors.textPrimaryDark  : const Color(0xFF1A1A1A);
    final labelClr  = isDark ? AppColors.textSecondaryDark : const Color(0xFF747485);
    final pctClr    = isDark ? AppColors.textSecondaryDark : const Color(0xFF4A4A5A);
    final dividerClr= isDark ? AppColors.dividerDark : const Color(0xFFF0F0F5);
    final iconBg    = AppColors.goalsAccent.withValues(alpha: isDark ? 0.25 : 0.12);
    final barBg     = isDark ? Colors.white10 : const Color(0xFFF0F0F7);

    return Card(
      elevation: 0,
      color: cardBg,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xxlBorderRadius),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Goal Progress',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w400,
                color: titleClr,
              ),
            ),
            const SizedBox(height: 24),

            // Metrics row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMetricColumn('Saved',
                    '$curSymbol${totalCurrent.toStringAsFixed(2)}',
                    AppColors.goalsAccent, labelClr),
                _buildDivider(dividerClr),
                _buildMetricColumn('Target',
                    '$curSymbol${totalTarget.toStringAsFixed(2)}',
                    titleClr, labelClr),
                _buildDivider(dividerClr),
                _buildMetricColumn('Remaining',
                    '$curSymbol${totalLeft.toStringAsFixed(2)}',
                    AppColors.warning, labelClr),
              ],
            ),
            const SizedBox(height: 20),
            Divider(color: dividerClr, thickness: 1.5),
            const SizedBox(height: 16),

            ...goals.map(
              (goal) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: iconBg,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            goal.iconData,
                            color: AppColors.goalsAccent,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            goal.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: titleClr,
                            ),
                          ),
                        ),
                        Text(
                          '${(goal.progress * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: pctClr,
                          ),
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => AddFundsSheet(goal: goal),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.goalsAccent.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.add, color: AppColors.goalsAccent, size: 20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: goal.progress,
                        minHeight: 10,
                        backgroundColor: barBg,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.goalsAccent),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildDivider(Color color) =>
    Container(height: 40, width: 1, color: color);

Widget _buildMetricColumn(
    String label, String value, Color valueColor, Color labelColor) {
  return Expanded(
    child: Column(
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w400, color: labelColor)),
        const SizedBox(height: 6),
        Text(value,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w700, color: valueColor)),
      ],
    ),
  );
}