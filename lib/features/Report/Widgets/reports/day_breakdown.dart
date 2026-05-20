import 'package:flutter/material.dart';
import 'package:spendly/features/Report/Widgets/common/card_box.dart';
import 'package:spendly/features/Report/Widgets/common/day_row.dart';
import 'package:spendly/features/Report/domain/models/day_spend.dart';

class DayBreakdown extends StatelessWidget {
  const DayBreakdown({required this.days});

  final List<DaySpend> days;

  @override
  Widget build(BuildContext context) {
    final total = days.fold<double>(0, (sum, item) => sum + item.amount);
    return CardBox(
      child: Column(
        children: days
            .map(
              (day) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: DayRow(day: day, total: total),
              ),
            )
            .toList(),
      ),
    );
  }
}
