import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:spendly/features/Report/Widgets/common/card_box.dart';
import 'package:spendly/features/Report/Widgets/common/snapshot_tile.dart';
import 'package:spendly/features/Report/Widgets/common/tag.dart';
import 'package:spendly/features/Report/domain/models/live_insights_data.dart';

class CardBox extends StatelessWidget {
  const CardBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF397BBD),
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}

class ComparisonOutlook extends StatelessWidget {
  const ComparisonOutlook({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF397BBD),
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}
