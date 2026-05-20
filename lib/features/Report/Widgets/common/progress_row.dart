import 'package:spendly/features/authentication/providers/currency_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:spendly/features/Report/domain/models/category_insights_item.dart';

class ProgressRow extends ConsumerWidget {
  const ProgressRow({required this.category, required this.total});

  final CategoryInsightsItem category;
  final double total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curSymbol = ref.watch(currencySymbolProvider);
    final fraction = total <= 0
        ? 0.0
        : (category.amount / total).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              category.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${curSymbol}${category.amount.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 6,
            value: fraction,
            backgroundColor: Colors.white10,
            color: category.color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${category.percent.toStringAsFixed(1)}% of current spending',
          style: const TextStyle(color: Colors.white54, fontSize: 10),
        ),
      ],
    );
  }
}
