import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/features/authentication/providers/currency_provider.dart';
import 'package:spendly/features/Report/domain/models/live_insights_data.dart';
import 'package:spendly/theme/colors.dart';
import 'package:spendly/theme/app_radius.dart';
import 'package:spendly/theme/theme_extensions.dart';

class BudgetStatusCard extends ConsumerWidget {
  const BudgetStatusCard({Key? key, required this.data}) : super(key: key);

  final LiveInsightsData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curSymbol = ref.watch(currencySymbolProvider);
    final isDark = context.isDark;

    final remaining = data.budgetLimit - data.projectedSpending;
    final safe = data.projectedSpending <= data.budgetLimit;

    final formattedForecast =
        '$curSymbol${data.projectedSpending.toStringAsFixed(0)}';
    final formattedLimit = '$curSymbol${data.budgetLimit.toStringAsFixed(0)}';
    final formattedRemaining =
        '$curSymbol${remaining.abs().toStringAsFixed(0)}';

    final cardBg   = isDark ? AppColors.darkSurface : Colors.white;
    final titleClr = isDark ? AppColors.textPrimaryDark : const Color(0xFF1E1E24);
    final bodyClr  = isDark ? AppColors.textSecondaryDark : const Color(0xFF4A4A52);
    final labelClr = isDark ? AppColors.textSecondaryDark : const Color(0xFF7A7A85);
    final badgeBg  = isDark
        ? AppColors.goalsAccent.withValues(alpha: 0.2)
        : const Color(0xFFE8E5FF);
    final dividerClr = isDark ? AppColors.dividerDark : const Color(0xFFD1CBD9);

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadius.xxlBorderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: Color(0xFF4A3AFF),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AI Analysis',
                    style: TextStyle(
                      color: titleClr,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  safe ? 'Budget OK' : 'Over Budget',
                  style: const TextStyle(
                    color: Color(0xFF4A3AFF),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Main body
          RichText(
            text: TextSpan(
              style: TextStyle(
                color: bodyClr,
                fontSize: 16,
                height: 1.4,
                fontWeight: FontWeight.w400,
              ),
              children: [
                const TextSpan(
                    text:
                        "Based on your spending patterns, you're projected to end the month "),
                TextSpan(
                  text: safe
                      ? '$formattedRemaining under budget'
                      : '$formattedRemaining over budget',
                  style: TextStyle(
                    color: safe
                        ? AppColors.success
                        : AppColors.error,
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Status / Forecast row
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status',
                          style: TextStyle(color: labelClr, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(
                        safe ? 'On Track' : 'At Risk',
                        style: TextStyle(
                          color: titleClr,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                VerticalDivider(
                    color: dividerClr, thickness: 1, width: 32),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Forecast',
                          style: TextStyle(color: labelClr, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(
                        '$formattedForecast / $formattedLimit',
                        style: TextStyle(
                          color: titleClr,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
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