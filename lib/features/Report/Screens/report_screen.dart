import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/features/Report/Widgets/insights/insights_tab.dart';
import 'package:spendly/features/Report/Widgets/insights/report_pdf_preview.dart';
import 'package:spendly/features/Report/controllers/report_controller.dart';
import 'package:spendly/features/Report/Widgets/reports/reports_tab.dart';
import 'package:spendly/features/Report/domain/models/live_insights_data.dart';
import 'package:spendly/features/main/providers/main_finance_provider.dart';
import 'package:spendly/features/main/providers/transactions_list_provider.dart';
import 'package:spendly/features/wallet/providers/category_provider.dart';
import 'package:spendly/features/wallet/providers/goal_provider.dart';
import 'package:spendly/services/backend_api.dart';
import 'package:spendly/theme/app_radius.dart';
import 'package:spendly/theme/theme_extensions.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _isGenerating = false;
  String? _reportError;
  Map<String, dynamic>? _generatedReport;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final financeAsync      = ref.watch(mainFinanceProvider);
    final transactionsAsync = ref.watch(transactionsListProvider);
    final goalsAsync        = ref.watch(goalProvider);
    final categories        = ref.watch(walletProvider);

    final liveData = LiveInsightsData.fromState(
      finance:      financeAsync.valueOrNull,
      transactions: transactionsAsync.valueOrNull ?? const [],
      goals:        goalsAsync.valueOrNull ?? const [],
      categories:   categories,
    );

    return Scaffold(
      appBar: AppBar(
        actions: [
          Image.asset('assets/logo/logo.png', width: 42, height: 42),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            color: context.theme.scaffoldBackgroundColor,
            padding: const EdgeInsets.all(8),
            child: _SegmentedToggle(
              tabController: _tabController,
              onTabChanged: () => setState(() {}),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          InsightsTab(
            liveData:        liveData,
            reportError:     _reportError,
            generatedReport: _generatedReport,
            onGenerate: () => _onGeneratePressed(liveData),
          ),
          ReportsTab(liveData: liveData),
        ],
      ),
    );
  }

  Future<void> _generateReport(LiveInsightsData liveData) async {
    setState(() {
      _isGenerating = true;
      _reportError  = null;
    });

    final payload = liveData.toBackendPayload();

    try {
      final api    = BackendApi.create();
      final result = await api.generateReport(payload);
      setState(() => _generatedReport = result);
    } catch (error) {
      setState(() {
        _generatedReport = liveData.toLocalReport();
        _reportError =
            'Using local analysis because the backend report failed: $error';
      });
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _onGeneratePressed(LiveInsightsData liveData) async {
    // Let user choose frequency
    final freq = await showModalBottomSheet<ReportFrequency>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Daily'),
                onTap: () => Navigator.of(ctx).pop(ReportFrequency.daily),
              ),
              ListTile(
                title: const Text('Weekly'),
                onTap: () => Navigator.of(ctx).pop(ReportFrequency.weekly),
              ),
              ListTile(
                title: const Text('Monthly'),
                onTap: () => Navigator.of(ctx).pop(ReportFrequency.monthly),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (freq == null) return;

    // Ensure we have a generated report (try backend first)
    if (_generatedReport == null) {
      await _generateReport(liveData);
    }

    try {
      final controller = ReportController();
      final bytes = await controller.buildPdf(liveData, freq);
      await controller.savePdfAndRecord(bytes, freq);

      // Show preview screen where user can print or share
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ReportPdfPreview(data: liveData, freq: freq),
      ));
    } catch (e) {
      setState(() {
        _reportError = 'PDF preview failed: $e';
      });
    }
  }
}

/// Custom segmented control that replaces the hardcoded Color literals.
class _SegmentedToggle extends StatelessWidget {
  const _SegmentedToggle({
    required this.tabController,
    required this.onTabChanged,
  });

  final TabController tabController;
  final VoidCallback  onTabChanged;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = tabController.index;
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: AppRadius.fullBorderRadius,
      ),
      child: Stack(
        children: [
          // Sliding highlight
          AnimatedAlign(
            alignment: selectedIndex == 0
                ? Alignment.centerLeft
                : Alignment.centerRight,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.45,
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: context.colors.primary,
                borderRadius: AppRadius.fullBorderRadius,
              ),
            ),
          ),
          // Labels
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    tabController.animateTo(0);
                    onTabChanged();
                  },
                  child: Center(
                    child: Text(
                      'Insights',
                      style: TextStyle(
                        color: selectedIndex == 0
                            ? Colors.white
                            : context.subtitleColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    tabController.animateTo(1);
                    onTabChanged();
                  },
                  child: Center(
                    child: Text(
                      'Reports',
                      style: TextStyle(
                        color: selectedIndex == 1
                            ? Colors.white
                            : context.subtitleColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Keep the LinearForecast helper ───────────────────────────────────────────

class _LinearForecast {
  const _LinearForecast({
    required this.predicted,
    required this.trendDescription,
    required this.growthRate,
  });

  final double predicted;
  final String trendDescription;
  final double growthRate;
}

_LinearForecast LinearForecast(List<double> values) {
  if (values.isEmpty) {
    return const _LinearForecast(
      predicted: 0.0,
      trendDescription: 'No data available',
      growthRate: 0.0,
    );
  }

  if (values.length == 1) {
    return _LinearForecast(
      predicted: values.first,
      trendDescription: 'Insufficient data for trend analysis',
      growthRate: 0.0,
    );
  }

  final n = values.length;
  double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;

  for (var i = 0; i < n; i++) {
    final x = i.toDouble();
    final y = values[i];
    sumX += x; sumY += y; sumXY += x * y; sumX2 += x * x;
  }

  final denominator = (n * sumX2) - (sumX * sumX);
  final slope       = denominator == 0
      ? 0.0
      : ((n * sumXY) - (sumX * sumY)) / denominator;
  final intercept       = (sumY - (slope * sumX)) / n;
  final nextMonthIndex  = n.toDouble();
  final predicted       = math.max(0.0, slope * nextMonthIndex + intercept);
  final previous        = values[n - 2] == 0 ? 1.0 : values[n - 2];
  final growthRate      = (values[n - 1] - previous) / previous;

  return _LinearForecast(
    predicted: predicted,
    trendDescription: growthRate > 0.05
        ? 'Increasing'
        : growthRate < -0.05
        ? 'Decreasing'
        : 'Stable',
    growthRate: growthRate,
  );
}
