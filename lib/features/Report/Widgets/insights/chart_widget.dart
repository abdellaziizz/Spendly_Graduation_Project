import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:spendly/features/Report/controllers/chart_provider.dart';
import 'package:spendly/theme/colors.dart';
import 'package:spendly/theme/app_radius.dart';
import 'package:spendly/theme/theme_extensions.dart';

class WeeklySpendingCard extends ConsumerWidget {
  const WeeklySpendingCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartData = ref.watch(weeklySpendingProvider);
    final isDark = context.isDark;

    final spots = chartData.spendingList
        .map((data) => FlSpot(data.x, data.amount))
        .toList();

    // ── Adaptive colours ──────────────────────────────────────────────────
    const lineColor = Color(0xFF0077b6); // Indigo-600, visible in both modes
    final cardBg = isDark ? AppColors.darkSurface : Colors.white;
    final titleClr = isDark
        ? AppColors.textPrimaryDark
        : const Color(0xFF1E2022);
    // Inactive day label: readable in both modes
    final inactiveDay = isDark
        ? AppColors
              .textSecondaryDark // ~A0A0A0 — visible on dark bg
        : const Color(0xFF8F9BB3); // muted blue-grey on white

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadius.xxlBorderRadius,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Spending',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: titleClr,
                ),
              ),
              Text(
                '\$${chartData.totalSpending.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: lineColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24.0),

          // ── Chart ────────────────────────────────────────────────────
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 34,
                      interval: 1,
                      getTitlesWidget: (value, meta) => _bottomTitle(
                        value,
                        meta,
                        chartData.highestSpendingDayIndex,
                        inactiveDay,
                      ),
                    ),
                  ),
                ),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: chartData.maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: lineColor,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        if (spot.x == chartData.highestSpendingDayIndex) {
                          return FlDotCirclePainter(
                            radius: 6,
                            color: lineColor,
                            strokeWidth: 0,
                          );
                        }
                        return FlDotCirclePainter(
                          radius: 0,
                          color: Colors.transparent,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          lineColor.withValues(alpha: isDark ? 0.20 : 0.12),
                          lineColor.withValues(alpha: 0.00),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomTitle(
    double value,
    TitleMeta meta,
    int peakIndex,
    Color inactiveColor,
  ) {
    const weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final index = value.toInt();
    if (index < 0 || index >= weekdays.length) return const SizedBox.shrink();

    final isPeak = index == peakIndex;

    return SideTitleWidget(
      meta: meta,
      space: 8,
      child: Text(
        weekdays[index],
        style: TextStyle(
          fontSize: 14,
          fontWeight: isPeak ? FontWeight.w700 : FontWeight.w600,
          color: isPeak ? const Color(0xFF0077b6) : inactiveColor,
        ),
      ),
    );
  }
}
