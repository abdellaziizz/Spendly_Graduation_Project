import 'package:flutter/material.dart';
import 'package:spendly/features/Report/Widgets/common/section_label.dart';
import 'package:spendly/features/Report/Widgets/reports/day_breakdown.dart';
import 'package:spendly/features/Report/Widgets/reports/month_breakdown.dart';
import 'package:spendly/features/Report/Widgets/reports/week_breakdown.dart';
import 'package:spendly/features/Report/domain/models/live_insights_data.dart';
import 'package:spendly/features/Report/Widgets/reports/report_history.dart';

class ReportsTab extends StatelessWidget {
  const ReportsTab({required this.liveData});

  final LiveInsightsData liveData;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReportHistoryScreen()));
            },
            icon: const Icon(Icons.history),
            label: const Text('Report History'),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionLabel(title: 'Daily Breakdown'),
                  DayBreakdown(days: liveData.dailyBreakdown),
                  const SizedBox(height: 20),
                  const SectionLabel(title: 'Weekly Breakdown'),
                  WeekBreakdown(weeks: liveData.weeklyBreakdown),
                  const SizedBox(height: 20),
                  const SectionLabel(title: 'Monthly Breakdown'),
                  MonthBreakdown(months: liveData.monthlyBreakdown),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
