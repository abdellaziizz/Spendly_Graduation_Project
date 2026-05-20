import 'package:spendly/features/authentication/providers/currency_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:spendly/features/Report/Widgets/common/card_box.dart';
import 'package:spendly/features/Report/domain/models/time_bucket.dart';

class WeekBreakdown extends ConsumerWidget {
  const WeekBreakdown({required this.weeks});

  final List<TimeBucket> weeks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curSymbol = ref.watch(currencySymbolProvider);
    return Column(
      children: weeks
          .map(
            (week) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CardBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          week.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${curSymbol}${week.total.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.lightBlueAccent),
                        ),
                      ],
                    ),
                    Text(
                      '${week.count} transactions',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...week.categories.entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              '${curSymbol}${entry.value.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
