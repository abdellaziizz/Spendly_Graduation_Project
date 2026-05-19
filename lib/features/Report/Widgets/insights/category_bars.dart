import 'package:flutter/material.dart';
import 'package:spendly/features/Report/Widgets/common/card_box.dart';
import 'package:spendly/features/Report/Widgets/common/progress_row.dart';
import 'package:spendly/features/Report/domain/models/category_insights_item.dart';

// Track how much did you spend in each category
class CategoryBars extends StatelessWidget {
  const CategoryBars({required this.categories});

  final List<CategoryInsightsItem> categories;

  @override
  Widget build(BuildContext context) {
    final total = categories.fold<double>(0, (sum, item) => sum + item.amount);

    return CardBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total spend: \$${total.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          ...categories.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ProgressRow(category: item, total: total),
            ),
          ),
        ],
      ),
    );
  }
}
