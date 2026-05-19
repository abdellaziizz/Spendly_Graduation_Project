import 'package:flutter/material.dart';
import 'package:spendly/features/Report/Widgets/common/card_box.dart';
import 'package:spendly/features/Report/Widgets/common/muted_text.dart';
import 'package:spendly/features/Report/Widgets/common/section_label.dart';
import 'package:spendly/features/Report/Widgets/insights/action_list.dart';
import 'package:spendly/features/Report/Widgets/insights/budget_status_card.dart';
import 'package:spendly/features/Report/Widgets/insights/category_bars.dart';
import 'package:spendly/features/Report/Widgets/insights/comparison_snapshot.dart';
import 'package:spendly/features/Report/Widgets/insights/forecast_card.dart';
import 'package:spendly/features/Report/Widgets/insights/generate_report.dart';
import 'package:spendly/features/Report/Widgets/insights/goal_snapshot.dart';
import 'package:spendly/features/Report/Widgets/insights/outlook_list.dart';
import 'package:spendly/features/Report/Widgets/insights/report_preview.dart';
import 'package:spendly/features/Report/domain/models/live_insights_data.dart';

class InsightsTab extends StatelessWidget {
  const InsightsTab({
    required this.liveData,
    required this.onGenerate,
    required this.reportError,
    required this.generatedReport,
  });

  final LiveInsightsData liveData;
  final VoidCallback onGenerate;
  final String? reportError;
  final Map<String, dynamic>? generatedReport;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel(title: 'Analysis'),
            const SizedBox(height: 8),
            CardBox(child: BudgetStatusCard(data: liveData)),
            const SizedBox(height: 10),
            CardBox(child: ForecastCard(data: liveData)),
            const SizedBox(height: 10),
            // const SectionLabel(title: 'Summary'),
            // MutedText(liveData.summary),
            const SizedBox(height: 10),
            const SectionLabel(title: 'Currency Vs Projected'),
            ComparisonSnapshot(data: liveData),
            const SizedBox(height: 10),
            const SectionLabel(title: 'Goal Progress'),
            GoalSnapshot(goals: liveData.goals),
            const SizedBox(height: 10),
            Center(child: const SectionLabel(title: 'Add The Charts Here')),

            const SectionLabel(title: 'Current Spending by Category'),
            CategoryBars(categories: liveData.categoryBreakdown),
            const SizedBox(height: 10),
            const SectionLabel(title: 'Next Month Category Outlook'),
            OutlookList(items: liveData.outlookItems),
            const SizedBox(height: 10),
            const SectionLabel(title: 'Actionable Recommendations'),
            ActionList(items: liveData.recommendations),
            const SizedBox(height: 10),
            const SectionLabel(title: 'Alerts'),
            AlertList(items: liveData.alerts),
            const SizedBox(height: 10),
            const SectionLabel(title: 'Generate Report'),
            GenerateReportCard(
              generatedReport: generatedReport,
              reportError: reportError,
              onGenerate: onGenerate,
            ),
         
            if (generatedReport != null) ...[
              const SizedBox(height: 10),
              const SectionLabel(title: 'Latest Report Output'),
              ReportPreview(report: generatedReport!),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
