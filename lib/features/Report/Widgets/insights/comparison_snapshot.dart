import 'package:spendly/features/authentication/providers/currency_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:spendly/features/Report/Widgets/common/tag.dart';
import 'package:spendly/features/Report/domain/models/live_insights_data.dart';
import 'package:spendly/theme/colors.dart';
import 'package:spendly/theme/app_radius.dart';
import 'package:spendly/theme/theme_extensions.dart';

class ComparisonSnapshot extends ConsumerWidget {
  const ComparisonSnapshot({required this.data});

  final LiveInsightsData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curSymbol = ref.watch(currencySymbolProvider);
    final isDark = context.isDark;
    final cardBg  = isDark ? AppColors.darkSurface : Colors.white;
    final labelClr = isDark ? AppColors.textSecondaryDark : const Color(0xFF1B1B24);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: AppRadius.mdBorderRadius,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Total',
                      style: TextStyle(color: labelClr, fontSize: 10),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$curSymbol${data.currentSpending.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Tag(text: 'Watch: ${data.watchCategory}'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: AppRadius.mdBorderRadius,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Projected Next Month',
                      style: TextStyle(color: labelClr, fontSize: 10),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$curSymbol${data.monthlyForecast.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
