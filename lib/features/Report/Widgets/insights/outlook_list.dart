import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/features/authentication/providers/currency_provider.dart';
import 'package:spendly/features/Report/domain/models/outlook_item.dart';
import 'package:spendly/theme/colors.dart';
import 'package:spendly/theme/theme_extensions.dart';

class OutlookList extends ConsumerWidget {
  const OutlookList({Key? key, required this.items}) : super(key: key);

  final List<OutlookItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curSymbol = ref.watch(currencySymbolProvider);
    final isDark    = context.isDark;
    final topItems  = items.take(3).toList();

    final cardBg    = isDark ? AppColors.darkSurfaceElevated : const Color(0xFFF9F6FE);
    final titleClr  = isDark ? AppColors.textPrimaryDark     : const Color(0xFF1E1E24);
    final bodyClr   = isDark ? AppColors.textSecondaryDark   : const Color(0xFF5A5A65);
    final tileBg    = isDark ? AppColors.darkSurface         : const Color(0xFFF1F0FA);
    final tileTextClr= isDark ? AppColors.textPrimaryDark    : const Color(0xFF1E1E24);
    const watchRed  = Color(0xFFC92A2A);
    final badgeBg   = isDark
        ? watchRed.withValues(alpha: 0.25)
        : const Color(0xFFFCE8E6);
    final changeBg  = isDark
        ? watchRed.withValues(alpha: 0.25)
        : const Color(0xFFFCE2DC);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'Category Outlook',
            style: TextStyle(
              color: titleClr,
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ...topItems.map((item) {
          final percentageText =
              '${item.change >= 0 ? '+' : ''}${item.change.toStringAsFixed(0)}%';

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(24),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  // Warning strip
                  Positioned(
                    left: 0, top: 0, bottom: 0,
                    child: Container(width: 5, color: watchRed),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              item.name,
                              style: TextStyle(
                                color: titleClr,
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: badgeBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'WATCH',
                                style: TextStyle(
                                  color: watchRed,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item.description,
                          style: TextStyle(
                            color: bodyClr,
                            fontSize: 16,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Metric tiles
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetricTile(
                                label: 'NOW',
                                value:
                                    '$curSymbol${item.now.toStringAsFixed(0)}',
                                backgroundColor: tileBg,
                                textColor: tileTextClr,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildMetricTile(
                                label: 'NEXT',
                                value:
                                    '$curSymbol${item.nextMonth.toStringAsFixed(0)}',
                                backgroundColor: tileBg,
                                textColor: tileTextClr,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildMetricTile(
                                label: 'CHANGE',
                                value: percentageText,
                                backgroundColor: changeBg,
                                textColor: watchRed,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.55),
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}