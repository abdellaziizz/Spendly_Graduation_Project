import 'package:spendly/features/authentication/providers/currency_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:spendly/features/Report/Widgets/common/card_box.dart';
import 'package:spendly/features/Report/Widgets/common/snapshot_tile.dart';
import 'package:spendly/features/Report/Widgets/common/tag.dart';
import 'package:spendly/features/Report/domain/models/live_insights_data.dart';

// Predict Next Month SPending and what category to watch
class ComparisonSnapshot extends ConsumerWidget {
  const ComparisonSnapshot({required this.data});

  final LiveInsightsData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curSymbol = ref.watch(currencySymbolProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Total',
                      style: const TextStyle(
                        color: Color(0xff1B1B24),
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${curSymbol}${data.currentSpending.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6),
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
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Projected Next Month',
                      style: const TextStyle(
                        color: Color(0xff1B1B24),
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${curSymbol}${data.monthlyForecast.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              // child: SnapshotTile(
              //   label: 'Projected Next Month',
              //   value: '${curSymbol}${data.monthlyForecast.toStringAsFixed(2)}',
              //   accent: Colors.orangeAccent,
              // ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
