import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:spendly/features/Report/Widgets/common/section_label.dart';
import 'package:spendly/features/Report/Widgets/insights/report_preview.dart';
import 'package:spendly/features/Report/Widgets/reports/day_breakdown.dart';
import 'package:spendly/features/Report/Widgets/reports/month_breakdown.dart';
import 'package:spendly/features/Report/Widgets/reports/week_breakdown.dart';
import 'package:spendly/features/Report/domain/models/live_insights_data.dart';
import 'package:spendly/features/Report/Widgets/reports/report_history.dart';
import 'package:spendly/theme/app_gradients.dart';
import 'package:spendly/theme/app_radius.dart';
import 'package:spendly/theme/colors.dart';
import 'package:spendly/theme/theme_extensions.dart';

class ReportsTab extends StatelessWidget {
  const ReportsTab({
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
    return Column(
      children: [
        // ── Report History button ────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ReportHistoryScreen()),
              );
            },
            icon: const Icon(Icons.history, size: 18),
            label: const Text('Report History'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.mdBorderRadius,
              ),
            ),
          ),
        ),

        // ── Scrollable content ───────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Breakdowns
                  const SectionLabel(title: 'Daily Breakdown'),
                  DayBreakdown(days: liveData.dailyBreakdown),
                  const SizedBox(height: 20),
                  const SectionLabel(title: 'Weekly Breakdown'),
                  WeekBreakdown(weeks: liveData.weeklyBreakdown),
                  const SizedBox(height: 20),
                  const SectionLabel(title: 'Monthly Breakdown'),
                  MonthBreakdown(months: liveData.monthlyBreakdown),
                  const SizedBox(height: 24),

                  // ── Generate Report card ─────────────────────────────
                  const SectionLabel(title: 'Generate Report'),
                  _GenerateReportCard(
                    generatedReport: generatedReport,
                    reportError: reportError,
                    onGenerate: onGenerate,
                  ),

                  // ── Report preview (only if generated) ──────────────
                  if (generatedReport != null) ...[
                    const SizedBox(height: 16),
                    const SectionLabel(title: 'Latest Report Output'),
                    ReportPreview(report: generatedReport!),
                  ],

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

// ─── Themed Generate Report card ──────────────────────────────────────────────

class _GenerateReportCard extends StatelessWidget {
  const _GenerateReportCard({
    required this.onGenerate,
    required this.reportError,
    required this.generatedReport,
  });

  final VoidCallback onGenerate;
  final String? reportError;
  final Map<String, dynamic>? generatedReport;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final borderColor = isDark
        ? AppColors.primary.withValues(alpha: 0.35)
        : const Color(0xFFB8CBE0);
    final bgColor = isDark ? AppColors.darkSurface : Colors.white;
    final iconBgColor = isDark
        ? AppColors.primary.withValues(alpha: 0.15)
        : const Color(0xFFE8F1F9);
    final subtitleColor = context.subtitleColor;

    return DottedBorder(
      color: borderColor,
      strokeWidth: 1.5,
      dashPattern: const [6, 6],
      borderType: BorderType.RRect,
      radius: const Radius.circular(AppRadius.xxl),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppRadius.xxlBorderRadius,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon circle with primary brand colour
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconBgColor,
              ),
              child: Icon(
                Icons.picture_as_pdf_rounded,
                size: 32,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Ready for review?',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.onSurface,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Export a detailed PDF breakdown of\nyour monthly finances for tax or\nbookkeeping.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: subtitleColor,
                height: 1.6,
              ),
            ),

            const SizedBox(height: 28),

            // Gradient generate button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  borderRadius: AppRadius.lgBorderRadius,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.30),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.lgBorderRadius,
                    ),
                  ),
                  onPressed: onGenerate,
                  child: Text(
                    generatedReport == null
                        ? 'Generate Report'
                        : 'Regenerate Report',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // Error message
            if (reportError != null) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline,
                      size: 13, color: AppColors.warning),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      reportError!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.warning,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
