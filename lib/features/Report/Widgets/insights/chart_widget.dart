import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:spendly/features/Report/controllers/chart_provider.dart';

class WeeklySpendingCard extends ConsumerWidget {
  const WeeklySpendingCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read your dynamic spending data and statistics from Riverpod
    final chartData = ref.watch(weeklySpendingProvider);

    // Map dynamic daily spending data elements directly into fl_chart FlSpot format
    final spots = chartData.spendingList
        .map((data) => FlSpot(data.x, data.amount))
        .toList();

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weekly Spending',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E2022),
                ),
              ),
              Text(
                '\$${chartData.totalSpending.toStringAsFixed(2)}', // Dynamically calculated using state
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4F46E5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24.0),
          
          // Chart Wrapper container
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false), // No grid lines
                borderData: FlBorderData(show: false),   // No outer borders
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) =>
                          _bottomTitlesWidget(value, meta, chartData.highestSpendingDayIndex),
                    ),
                  ),
                ),
                // Adjust min/max bounds dynamically to pad values beautifully
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: chartData.maxY,
                lineBarsData: [
                  LineChartBarData( 
                    spots: spots,
                    isCurved: true,              // Gives you that smooth spline look
                    curveSmoothness: 0.35,
                    color: const Color(0xFF4F46E5), // Primary line color
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        // Highlight only the peak node dynamically (highest spending day)
                        if (spot.x == chartData.highestSpendingDayIndex) {
                          return FlDotCirclePainter(
                            radius: 6,
                            color: const Color(0xFF4F46E5),
                            strokeWidth: 0,
                          );
                        }
                        return FlDotCirclePainter(radius: 0, color: Colors.transparent);
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      // Soft mesh gradient area beneath the line
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF4F46E5).withOpacity(0.12),
                          const Color(0xFF4F46E5).withOpacity(0.00),
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

  // Maps X-axis index coordinates to the custom weekday layout labels, highlighting the peak day
  Widget _bottomTitlesWidget(double value, TitleMeta meta, int highestSpendingDayIndex) {
    const weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final int index = value.toInt();

    if (index < 0 || index >= weekdays.length) {
      return const SizedBox.shrink();
    }

    final isPeak = index == highestSpendingDayIndex;

    return SideTitleWidget(
      meta: meta,
      space: 12,
      child: Text(
        weekdays[index],
        style: TextStyle(
          fontSize: 14,
          fontWeight: isPeak ? FontWeight.bold : FontWeight.w500,
          color: isPeak
              ? const Color(0xFF4F46E5)
              : const Color(0xFF8F9BB3).withOpacity(0.6),
        ),
      ),
    );
  }
}