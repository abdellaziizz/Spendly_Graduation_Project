import 'package:flutter/material.dart';
import 'package:spendly/theme/colors.dart';
import 'package:spendly/theme/theme_extensions.dart';

class CardBox extends StatelessWidget {
  const CardBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.isDark ? AppColors.darkSurface : AppColors.primary,
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
        color: context.isDark ? AppColors.darkSurface : AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}
