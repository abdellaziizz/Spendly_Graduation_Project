import 'package:spendly/features/authentication/providers/currency_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:spendly/features/Report/Widgets/common/card_box.dart';
import 'package:spendly/features/Report/Widgets/common/snapshot_tile.dart';
import 'package:spendly/features/Report/Widgets/common/tag.dart';
import 'package:spendly/features/Report/domain/models/outlook_item.dart';

// Next Month Category Watchout
class OutlookList extends ConsumerWidget {
  const OutlookList({required this.items});

  final List<OutlookItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curSymbol = ref.watch(currencySymbolProvider);
    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CardBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Tag(text: 'WATCH'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: SnapshotTile(
                            label: 'Now',
                            value: '${curSymbol}${item.now.toStringAsFixed(2)}',
                            accent: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SnapshotTile(
                            label: 'Next month',
                            value: '${curSymbol}${item.nextMonth.toStringAsFixed(2)}',
                            accent: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SnapshotTile(
                            label: 'Change',
                            value: '${curSymbol}${item.change.toStringAsFixed(2)}',
                            accent: Colors.white,
                          ),
                        ),
                      ],
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
