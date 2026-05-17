import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spendly/features/main/models/transaction_model.dart';
import 'package:spendly/features/main/providers/main_finance_provider.dart';
import 'package:spendly/features/main/providers/transactions_list_provider.dart';
import 'package:spendly/features/wallet/models/budget_model.dart';
import 'package:spendly/features/wallet/models/goal_model.dart';
import 'package:spendly/features/wallet/providers/category_provider.dart';
import 'package:spendly/features/wallet/providers/goal_provider.dart';
import 'package:spendly/services/backend_api.dart';

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
    final financeAsync = ref.watch(mainFinanceProvider);
    final transactionsAsync = ref.watch(transactionsListProvider);
    final goalsAsync = ref.watch(goalProvider);
    final categories = ref.watch(walletProvider);

    final liveData = _LiveInsightsData.fromState(
      finance: financeAsync.valueOrNull,
      transactions: transactionsAsync.valueOrNull ?? const [],
      goals: goalsAsync.valueOrNull ?? const [],
      categories: categories,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0E1F2B),
      appBar: AppBar(
        title: const Text('Predictions & Reports'),
        centerTitle: false,
        backgroundColor: const Color(0xFF0B1A24),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Container(
            color: const Color(0xFF0B1A24),
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Insights'),
                Tab(text: 'Reports'),
              ],
              indicatorColor: Colors.blueAccent,
              labelColor: Colors.blueAccent,
              unselectedLabelColor: Colors.white54,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3B82F6),
        onPressed: _isGenerating ? null : () => _generateReport(liveData),
        child: _isGenerating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.refresh, color: Colors.white),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _InsightsTab(
            liveData: liveData,
            reportError: _reportError,
            generatedReport: _generatedReport,
            onGenerate: () => _generateReport(liveData),
          ),
          _ReportsTab(liveData: liveData),
        ],
      ),
    );
  }

  Future<void> _generateReport(_LiveInsightsData liveData) async {
    setState(() {
      _isGenerating = true;
      _reportError = null;
    });

    final payload = liveData.toBackendPayload();

    try {
      final api = BackendApi.create();
      final result = await api.generateReport(payload);
      setState(() {
        _generatedReport = result;
      });
    } catch (error) {
      setState(() {
        _generatedReport = liveData.toLocalReport();
        _reportError = 'Using local analysis because the backend report failed: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }
}

class _InsightsTab extends StatelessWidget {
  const _InsightsTab({
    required this.liveData,
    required this.onGenerate,
    required this.reportError,
    required this.generatedReport,
  });

  final _LiveInsightsData liveData;
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
            const _SectionLabel(title: 'AI-Powered Analysis'),
            const SizedBox(height: 8),
            _CardBox(child: _BudgetStatusCard(data: liveData)),
            const SizedBox(height: 10),
            _CardBox(child: _ForecastCard(data: liveData)),
            const SizedBox(height: 10),
            const _SectionLabel(title: 'Summary'),
            _MutedText(liveData.summary),
            const SizedBox(height: 10),
            const _SectionLabel(title: 'Comparison Snapshot'),
            _ComparisonSnapshot(data: liveData),
            const SizedBox(height: 10),
            const _SectionLabel(title: 'Goal Progress'),
            _GoalSnapshot(goals: liveData.goals),
            const SizedBox(height: 10),
            const _SectionLabel(title: 'Current Spending by Category'),
            _CategoryBars(categories: liveData.categoryBreakdown),
            const SizedBox(height: 10),
            const _SectionLabel(title: 'Next Month Category Outlook'),
            _OutlookList(items: liveData.outlookItems),
            const SizedBox(height: 10),
            const _SectionLabel(title: 'Actionable Recommendations'),
            _ActionList(items: liveData.recommendations),
            const SizedBox(height: 10),
            const _SectionLabel(title: 'Alerts'),
            _ActionList(items: liveData.alerts),
            const SizedBox(height: 10),
            const _SectionLabel(title: 'Generate Report'),
            _CardBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Use the same Python ML/report pipeline on live home and wallet data.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onGenerate,
                      icon: const Icon(Icons.assessment),
                      label: Text(
                        generatedReport == null ? 'Generate Report' : 'Regenerate Report',
                      ),
                    ),
                  ),
                  if (reportError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      reportError!,
                      style: const TextStyle(color: Colors.orangeAccent, fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
            if (generatedReport != null) ...[
              const SizedBox(height: 10),
              const _SectionLabel(title: 'Latest Report Output'),
              _ReportPreview(report: generatedReport!),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _ReportsTab extends StatelessWidget {
  const _ReportsTab({required this.liveData});

  final _LiveInsightsData liveData;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionLabel(title: 'Daily Breakdown'),
            _DayBreakdown(days: liveData.dailyBreakdown),
            const SizedBox(height: 20),
            const _SectionLabel(title: 'Weekly Breakdown'),
            _WeekBreakdown(weeks: liveData.weeklyBreakdown),
            const SizedBox(height: 20),
            const _SectionLabel(title: 'Monthly Breakdown'),
            _MonthBreakdown(months: liveData.monthlyBreakdown),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CardBox extends StatelessWidget {
  const _CardBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF233342),
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}

class _MutedText extends StatelessWidget {
  const _MutedText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12));
  }
}

class _BudgetStatusCard extends StatelessWidget {
  const _BudgetStatusCard({required this.data});

  final _LiveInsightsData data;

  @override
  Widget build(BuildContext context) {
    final remaining = data.budgetLimit - data.currentSpending;
    final safe = data.projectedSpending <= data.budgetLimit;
    final statusColor = safe ? Colors.greenAccent : Colors.orangeAccent;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Budget Status',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              const Text('Current Spending', style: TextStyle(color: Colors.white54, fontSize: 10)),
              Text(
                '\$${data.currentSpending.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                safe
                    ? '✅ You\'re on track to stay within budget (\$${remaining.toStringAsFixed(2)} remaining)'
                    : '⚠️ You are likely to exceed your current budget.',
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: safe ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                safe ? 'LOW' : 'HIGH',
                style: TextStyle(
                  color: safe ? Colors.greenAccent : Colors.orangeAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Projected Spending', style: TextStyle(color: Colors.white54, fontSize: 10)),
            Text(
              '\$${data.projectedSpending.toStringAsFixed(2)}',
              style: TextStyle(color: statusColor, fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 24),
            const Text('Budget Limit', style: TextStyle(color: Colors.white54, fontSize: 10)),
            Text(
              '\$${data.budgetLimit.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ],
    );
  }
}

class _ForecastCard extends StatelessWidget {
  const _ForecastCard({required this.data});

  final _LiveInsightsData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Monthly Forecast',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              const Text('Predicted Amount', style: TextStyle(color: Colors.white54, fontSize: 10)),
              Text(
                '\$${data.monthlyForecast.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Average', style: TextStyle(color: Colors.white54, fontSize: 10)),
              Text(
                '\$${data.average.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Trend', style: TextStyle(color: Colors.white54, fontSize: 10)),
              Text(
                data.trend,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ComparisonSnapshot extends StatelessWidget {
  const _ComparisonSnapshot({required this.data});

  final _LiveInsightsData data;

  @override
  Widget build(BuildContext context) {
    return _CardBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _SnapshotTile(
                  label: 'Current Total',
                  value: '\$${data.currentSpending.toStringAsFixed(2)}',
                  accent: Colors.lightBlueAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SnapshotTile(
                  label: 'Projected Next Month',
                  value: '\$${data.monthlyForecast.toStringAsFixed(2)}',
                  accent: Colors.orangeAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Projected increase: \$${data.projectedIncrease.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your current budget is still under control overall. The forecast suggests next month will be higher unless spending changes, and food is the biggest pressure point right now.',
            style: TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(height: 8),
          Align(alignment: Alignment.centerLeft, child: _Tag(text: 'Watch: ${data.watchCategory}')),
        ],
      ),
    );
  }
}

class _SnapshotTile extends StatelessWidget {
  const _SnapshotTile({required this.label, required this.value, required this.accent});

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF20303D),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: accent, fontSize: 16, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _GoalSnapshot extends StatelessWidget {
  const _GoalSnapshot({required this.goals});

  final List<GoalModel> goals;

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) {
      return const _CardBox(
        child: Text(
          'No active goals yet. Set a goal in the Wallet tab and it will appear here.',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
      );
    }

    final totalTarget = goals.fold<double>(0, (sum, goal) => sum + goal.targetAmount);
    final totalCurrent = goals.fold<double>(0, (sum, goal) => sum + goal.currentAmount);
    final totalRemaining = goals.fold<double>(0, (sum, goal) => sum + goal.amountLeft);

    return _CardBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _SnapshotTile(label: 'Saved', value: '\$${totalCurrent.toStringAsFixed(2)}', accent: Colors.greenAccent)),
              const SizedBox(width: 8),
              Expanded(child: _SnapshotTile(label: 'Target', value: '\$${totalTarget.toStringAsFixed(2)}', accent: Colors.white)),
              const SizedBox(width: 8),
              Expanded(child: _SnapshotTile(label: 'Remaining', value: '\$${totalRemaining.toStringAsFixed(2)}', accent: Colors.orangeAccent)),
            ],
          ),
          const SizedBox(height: 12),
          ...goals.map(
            (goal) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(goal.iconData, color: Colors.white70, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      goal.title,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                  Text(
                    '${(goal.progress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBars extends StatelessWidget {
  const _CategoryBars({required this.categories});

  final List<_CategoryInsightsItem> categories;

  @override
  Widget build(BuildContext context) {
    final total = categories.fold<double>(0, (sum, item) => sum + item.amount);

    return _CardBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total spend: \$${total.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          ...categories.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ProgressRow(category: item, total: total),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.category, required this.total});

  final _CategoryInsightsItem category;
  final double total;

  @override
  Widget build(BuildContext context) {
    final fraction = total <= 0 ? 0.0 : (category.amount / total).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(category.name, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            Text('\$${category.amount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 6,
            value: fraction,
            backgroundColor: Colors.white10,
            color: category.color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${category.percent.toStringAsFixed(1)}% of current spending',
          style: const TextStyle(color: Colors.white54, fontSize: 10),
        ),
      ],
    );
  }
}

class _OutlookList extends StatelessWidget {
  const _OutlookList({required this.items});

  final List<_OutlookItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _CardBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        const _Tag(text: 'WATCH'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(item.description, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _SnapshotTile(label: 'Now', value: '\$${item.now.toStringAsFixed(2)}', accent: Colors.white)),
                        const SizedBox(width: 8),
                        Expanded(child: _SnapshotTile(label: 'Next month', value: '\$${item.nextMonth.toStringAsFixed(2)}', accent: Colors.white)),
                        const SizedBox(width: 8),
                        Expanded(child: _SnapshotTile(label: 'Change', value: '\$${item.change.toStringAsFixed(2)}', accent: Colors.white)),
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

class _ActionList extends StatelessWidget {
  const _ActionList({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF172733),
                  border: Border.all(color: Colors.white12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(item, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _DayBreakdown extends StatelessWidget {
  const _DayBreakdown({required this.days});

  final List<_DaySpend> days;

  @override
  Widget build(BuildContext context) {
    final total = days.fold<double>(0, (sum, item) => sum + item.amount);
    return _CardBox(
      child: Column(
        children: days
            .map(
              (day) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _DayRow(day: day, total: total),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({required this.day, required this.total});

  final _DaySpend day;
  final double total;

  @override
  Widget build(BuildContext context) {
    final fraction = total <= 0 ? 0.0 : (day.amount / total).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(day.day, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            Text('\$${day.amount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white70)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 4,
            value: fraction,
            backgroundColor: Colors.white10,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(height: 2),
        Align(
          alignment: Alignment.centerRight,
          child: Text('${day.transactions} transactions', style: const TextStyle(color: Colors.white54, fontSize: 10)),
        ),
      ],
    );
  }
}

class _WeekBreakdown extends StatelessWidget {
  const _WeekBreakdown({required this.weeks});

  final List<_TimeBucket> weeks;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: weeks
          .map(
            (week) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CardBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(week.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        Text('\$${week.total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.lightBlueAccent)),
                      ],
                    ),
                    Text('${week.count} transactions', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                    const SizedBox(height: 8),
                    ...week.categories.entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry.key, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                            Text('\$${entry.value.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                          ],
                        ),
                      ),
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

class _MonthBreakdown extends StatelessWidget {
  const _MonthBreakdown({required this.months});

  final List<_TimeBucket> months;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: months
          .map(
            (month) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CardBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(month.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        Text('\$${month.total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.lightBlueAccent)),
                      ],
                    ),
                    Text('${month.count} transactions', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                    const SizedBox(height: 8),
                    ...month.categories.entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry.key, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                            Text('\$${entry.value.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                          ],
                        ),
                      ),
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

class _ReportPreview extends StatelessWidget {
  const _ReportPreview({required this.report});

  final Map<String, dynamic> report;

  @override
  Widget build(BuildContext context) {
    final overrun = Map<String, dynamic>.from(report['overrunPrediction'] as Map? ?? {});
    final forecast = Map<String, dynamic>.from(report['monthlyForecast'] as Map? ?? {});
    final insights = List<dynamic>.from(report['insights'] as List? ?? const []);

    return _CardBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Risk: ${overrun['riskLevel'] ?? 'unknown'}', style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 4),
          Text('Projected spending: \$${(overrun['projectedSpending'] as num?)?.toDouble().toStringAsFixed(2) ?? '0.00'}', style: const TextStyle(color: Colors.white70)),
          Text('Forecast: \$${(forecast['predictedAmount'] as num?)?.toDouble().toStringAsFixed(2) ?? '0.00'}', style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          if (insights.isNotEmpty)
            Text('Top insight: ${(insights.first as Map)['title'] ?? ''}', style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

class _LiveInsightsData {
  const _LiveInsightsData({
    required this.currentSpending,
    required this.budgetLimit,
    required this.projectedSpending,
    required this.monthlyForecast,
    required this.average,
    required this.trend,
    required this.summary,
    required this.projectedIncrease,
    required this.watchCategory,
    required this.categoryBreakdown,
    required this.outlookItems,
    required this.alerts,
    required this.recommendations,
    required this.dailyBreakdown,
    required this.weeklyBreakdown,
    required this.monthlyBreakdown,
    required this.goals,
    required this.transactions,
  });

  final double currentSpending;
  final double budgetLimit;
  final double projectedSpending;
  final double monthlyForecast;
  final double average;
  final String trend;
  final String summary;
  final double projectedIncrease;
  final String watchCategory;
  final List<_CategoryInsightsItem> categoryBreakdown;
  final List<_OutlookItem> outlookItems;
  final List<String> alerts;
  final List<String> recommendations;
  final List<_DaySpend> dailyBreakdown;
  final List<_TimeBucket> weeklyBreakdown;
  final List<_TimeBucket> monthlyBreakdown;
  final List<GoalModel> goals;
  final List<TransactionModel> transactions;

  factory _LiveInsightsData.fromState({
    required MainFinanceData? finance,
    required List<TransactionModel> transactions,
    required List<GoalModel> goals,
    required List<BudgetModel> categories,
  }) {
    final expenseTransactions = transactions.where((tx) => tx.type.toLowerCase() != 'income').toList();
    final currentSpendingByCategory = _sumByCategory(expenseTransactions);
    final budgetsByCategory = {
      for (final category in categories)
        category.title.toLowerCase(): category.limitAmount,
    };

    final totalBudgetFromCategories = budgetsByCategory.values.fold<double>(0, (sum, value) => sum + value);
    final totalSpentFromTransactions = expenseTransactions.fold<double>(0, (sum, tx) => sum + tx.amount);
    final overallBudget = (finance?.budget ?? 0) > 0 ? finance!.budget : totalBudgetFromCategories;
    final currentSpending = finance?.totalExpenses ?? totalSpentFromTransactions;

    final monthlyHistory = _buildMonthlyHistory(expenseTransactions);
    final forecast = _linearForecast(monthlyHistory.isEmpty ? [currentSpending] : monthlyHistory);
    final monthlyForecast = forecast.predicted;
    final average = monthlyHistory.isEmpty
        ? currentSpending
        : monthlyHistory.fold<double>(0, (sum, value) => sum + value) / monthlyHistory.length;

    final categoryItems = currentSpendingByCategory.entries.map((entry) {
      final budget = budgetsByCategory[entry.key] ?? 0.0;
      final percent = currentSpending <= 0 ? 0.0 : (entry.value / currentSpending) * 100;
      return _CategoryInsightsItem(
        name: entry.key,
        amount: entry.value,
        percent: percent,
        budgetLimit: budget,
        color: _colorForCategory(entry.key),
      );
    }).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    final topCategory = categoryItems.isNotEmpty ? categoryItems.first.name : 'none';
    final growthRate = forecast.growthRate;
    final outlook = categoryItems.map((item) {
      final nextMonth = item.amount * (1 + growthRate.clamp(-0.15, 0.20));
      return _OutlookItem(
        name: item.name,
        description: item.budgetLimit > 0 && item.amount > item.budgetLimit
            ? 'This category is already above budget.'
            : item.amount > 0
                ? 'This category is likely to keep trending with your current pace.'
                : 'No recent activity in this category.',
        now: item.amount,
        nextMonth: nextMonth,
        change: nextMonth - item.amount,
      );
    }).toList();

    final alerts = <String>[
      if (overallBudget > 0 && currentSpending >= overallBudget * 0.75)
        '⚠️ You have used ${(currentSpending / overallBudget * 100).toStringAsFixed(1)}% of your monthly budget.',
      if (growthRate > 0.05) '📈 Increasing spending trend detected.',
      if (goals.any((goal) => goal.progress < 1.0)) '🎯 You have active savings goals in Wallet.',
      if (topCategory != 'none') 'Watch: $topCategory is your biggest pressure point.',
    ];

    final recommendations = <String>[
      if (topCategory != 'none') 'Focus on $topCategory first to reduce pressure quickly.',
      if (goals.isNotEmpty) 'Tie one savings goal to your biggest expense category to accelerate progress.',
      'Review budget vs spending after every new expense entry.',
    ];

    return _LiveInsightsData(
      currentSpending: currentSpending,
      budgetLimit: overallBudget,
      projectedSpending: monthlyForecast,
      monthlyForecast: monthlyForecast,
      average: average,
      trend: forecast.trendDescription,
      summary: currentSpending <= overallBudget
          ? '✅ Your budget is on track, but your spending is increasing.'
          : '⚠️ Your current spending is above the active budget.',
      projectedIncrease: monthlyForecast - currentSpending,
      watchCategory: topCategory,
      categoryBreakdown: categoryItems,
      outlookItems: outlook,
      alerts: alerts.isEmpty ? ['No major alerts right now.'] : alerts,
      recommendations: recommendations,
      dailyBreakdown: _buildDailyBreakdown(expenseTransactions),
      weeklyBreakdown: _buildWeeklyBreakdown(expenseTransactions),
      monthlyBreakdown: _buildMonthlyBreakdown(expenseTransactions),
      goals: goals,
      transactions: transactions,
    );
  }

  Map<String, dynamic> toBackendPayload() {
    final budgets = <String, dynamic>{};
    for (final item in categoryBreakdown) {
      if (item.budgetLimit > 0) {
        budgets[item.name] = item.budgetLimit;
      }
    }

    final currentSpendingMap = <String, dynamic>{
      for (final item in categoryBreakdown) item.name: item.amount,
    };

    final expenses = transactions
        .where((tx) => tx.type.toLowerCase() != 'income')
        .map(
          (tx) => {
            'date': tx.dateTime.toIso8601String(),
            'amount': tx.amount,
            'category': tx.category,
            'description': tx.description,
          },
        )
        .toList();

    return {
      'userId': Supabase.instance.client.auth.currentUser?.id ?? 'local-user',
      'expenses': expenses,
      'budgets': budgets,
      'currentSpending': currentSpendingMap,
      'historicalMonthly': _buildMonthlyHistory(transactions.where((tx) => tx.type.toLowerCase() != 'income').toList()),
      'daysInMonth': DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day,
      'currentDay': DateTime.now().day,
      'goals': goals
          .map(
            (goal) => {
              'title': goal.title,
              'currentAmount': goal.currentAmount,
              'targetAmount': goal.targetAmount,
              'progress': goal.progress,
            },
          )
          .toList(),
    };
  }

  Map<String, dynamic> toLocalReport() {
    final now = DateTime.now();
    return {
      'userId': Supabase.instance.client.auth.currentUser?.id ?? 'local-user',
      'periodStart': DateTime(now.year, now.month, 1).toIso8601String(),
      'periodEnd': now.toIso8601String(),
      'totalSpending': currentSpending,
      'totalBudget': budgetLimit,
      'overallProgress': budgetLimit > 0 ? currentSpending / budgetLimit : 0.0,
      'overrunPrediction': {
        'willOverrun': projectedSpending > budgetLimit,
        'confidence': 0.7,
        'projectedSpending': projectedSpending,
        'budgetLimit': budgetLimit,
        'daysRemaining': DateTime(now.year, now.month + 1, 0).day - now.day,
        'riskLevel': projectedSpending > budgetLimit ? 'high' : 'low',
        'message': projectedSpending > budgetLimit
            ? 'Projected spending is above your budget.'
            : 'You are on track to stay within budget.',
      },
      'monthlyForecast': {
        'predictedAmount': monthlyForecast,
        'confidence': 0.7,
        'historicalData': _buildMonthlyHistory(transactions.where((tx) => tx.type.toLowerCase() != 'income').toList()),
        'trend': monthlyForecast - currentSpending,
        'trendDescription': trend,
      },
      'smartTips': recommendations
          .map(
            (text) => {
              'title': text,
              'description': text,
              'recommendation': text,
              'priority': 'medium',
              'iconType': 'info',
            },
          )
          .toList(),
      'insights': [
        {
          'title': 'Live goal snapshot',
          'description': summary,
          'insights': [summary, 'Goals tracked: ${goals.length}'],
          'recommendations': recommendations,
          'confidence': 0.9,
          'category': 'live_state',
          'generatedAt': now.toIso8601String(),
        }
      ],
      'categoryBreakdown': {for (final item in categoryBreakdown) item.name: item.amount},
    };
  }
}

class _CategoryInsightsItem {
  const _CategoryInsightsItem({
    required this.name,
    required this.amount,
    required this.percent,
    required this.budgetLimit,
    required this.color,
  });

  final String name;
  final double amount;
  final double percent;
  final double budgetLimit;
  final Color color;
}

class _OutlookItem {
  const _OutlookItem({
    required this.name,
    required this.description,
    required this.now,
    required this.nextMonth,
    required this.change,
  });

  final String name;
  final String description;
  final double now;
  final double nextMonth;
  final double change;
}

class _DaySpend {
  const _DaySpend(this.day, this.amount, this.transactions);

  final String day;
  final double amount;
  final int transactions;
}

class _TimeBucket {
  const _TimeBucket({
    required this.label,
    required this.total,
    required this.count,
    required this.categories,
  });

  final String label;
  final double total;
  final int count;
  final Map<String, double> categories;
}

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

_LinearForecast _linearForecast(List<double> values) {
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
  double sumX = 0;
  double sumY = 0;
  double sumXY = 0;
  double sumX2 = 0;

  for (var i = 0; i < n; i++) {
    final x = i.toDouble();
    final y = values[i];
    sumX += x;
    sumY += y;
    sumXY += x * y;
    sumX2 += x * x;
  }

  final denominator = (n * sumX2) - (sumX * sumX);
  final slope = denominator == 0 ? 0.0 : ((n * sumXY) - (sumX * sumY)) / denominator;
  final intercept = (sumY - (slope * sumX)) / n;
  final nextMonthIndex = n.toDouble();
  final predicted = math.max(0.0, slope * nextMonthIndex + intercept);
  final previous = values[n - 2] == 0 ? 1.0 : values[n - 2];
  final growthRate = (values[n - 1] - previous) / previous;

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

List<double> _buildMonthlyHistory(List<TransactionModel> transactions) {
  final monthlyTotals = <String, double>{};
  for (final tx in transactions) {
    final key = _monthKey(tx.dateTime);
    monthlyTotals[key] = (monthlyTotals[key] ?? 0) + tx.amount;
  }

  final keys = monthlyTotals.keys.toList()..sort();
  return keys.map((key) => monthlyTotals[key] ?? 0.0).toList();
}

List<_DaySpend> _buildDailyBreakdown(List<TransactionModel> transactions) {
  final totals = <String, double>{};
  final counts = <String, int>{};

  for (final tx in transactions) {
    final label = _weekdayName(tx.dateTime.weekday);
    totals[label] = (totals[label] ?? 0) + tx.amount;
    counts[label] = (counts[label] ?? 0) + 1;
  }

  const order = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return order
      .where((day) => totals.containsKey(day))
      .map((day) => _DaySpend(day, totals[day] ?? 0.0, counts[day] ?? 0))
      .toList();
}

List<_TimeBucket> _buildWeeklyBreakdown(List<TransactionModel> transactions) {
  final buckets = <String, Map<String, dynamic>>{};
  for (final tx in transactions) {
    final label = 'Week ${((tx.dateTime.day - 1) ~/ 7) + 1}';
    final bucket = buckets.putIfAbsent(
      label,
      () => {'total': 0.0, 'count': 0, 'categories': <String, double>{}},
    );
    bucket['total'] = (bucket['total'] as double) + tx.amount;
    bucket['count'] = (bucket['count'] as int) + 1;
    final categories = bucket['categories'] as Map<String, double>;
    categories[tx.category] = (categories[tx.category] ?? 0) + tx.amount;
  }

  final keys = buckets.keys.toList()..sort();
  return keys
      .map(
        (key) => _TimeBucket(
          label: key,
          total: buckets[key]?['total'] as double? ?? 0.0,
          count: buckets[key]?['count'] as int? ?? 0,
          categories: Map<String, double>.from(buckets[key]?['categories'] as Map? ?? const {}),
        ),
      )
      .toList();
}

List<_TimeBucket> _buildMonthlyBreakdown(List<TransactionModel> transactions) {
  final buckets = <String, Map<String, dynamic>>{};
  for (final tx in transactions) {
    final label = _monthKey(tx.dateTime, fullLabel: true);
    final bucket = buckets.putIfAbsent(
      label,
      () => {'total': 0.0, 'count': 0, 'categories': <String, double>{}},
    );
    bucket['total'] = (bucket['total'] as double) + tx.amount;
    bucket['count'] = (bucket['count'] as int) + 1;
    final categories = bucket['categories'] as Map<String, double>;
    categories[tx.category] = (categories[tx.category] ?? 0) + tx.amount;
  }

  final keys = buckets.keys.toList()..sort();
  return keys
      .map(
        (key) => _TimeBucket(
          label: key,
          total: buckets[key]?['total'] as double? ?? 0.0,
          count: buckets[key]?['count'] as int? ?? 0,
          categories: Map<String, double>.from(buckets[key]?['categories'] as Map? ?? const {}),
        ),
      )
      .toList();
}

Map<String, double> _sumByCategory(List<TransactionModel> transactions) {
  final totals = <String, double>{};
  for (final tx in transactions) {
    final key = tx.category.trim().toLowerCase().isEmpty ? 'other' : tx.category.trim().toLowerCase();
    totals[key] = (totals[key] ?? 0) + tx.amount;
  }
  return totals;
}

String _monthKey(DateTime dateTime, {bool fullLabel = false}) {
  if (fullLabel) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${monthNames[dateTime.month - 1]} ${dateTime.year}';
  }
  return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}';
}

String _weekdayName(int weekday) {
  const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return names[(weekday - 1).clamp(0, 6)];
}

Color _colorForCategory(String category) {
  switch (category.toLowerCase()) {
    case 'food':
      return const Color(0xFF4CAF50);
    case 'transport':
      return const Color(0xFF42A5F5);
    case 'shopping':
      return const Color(0xFF26A69A);
    case 'utilities':
    case 'bills':
      return const Color(0xFFFF9800);
    case 'health':
      return const Color(0xFFBDBDBD);
    case 'entertainment':
      return const Color(0xFF8D6E63);
    default:
      return Colors.indigoAccent;
  }
}import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spendly/features/main/models/transaction_model.dart';
import 'package:spendly/features/main/providers/main_finance_provider.dart';
import 'package:spendly/features/main/providers/transactions_list_provider.dart';
import 'package:spendly/features/wallet/models/budget_model.dart';
import 'package:spendly/features/wallet/models/goal_model.dart';
import 'package:spendly/features/wallet/providers/category_provider.dart';
import 'package:spendly/features/wallet/providers/goal_provider.dart';
import 'package:spendly/services/backend_api.dart';

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
    final financeAsync = ref.watch(mainFinanceProvider);
    final transactionsAsync = ref.watch(transactionsListProvider);
    final goalsAsync = ref.watch(goalProvider);
    final categories = ref.watch(walletProvider);

    final liveData = _LiveInsightsData.fromState(
      finance: financeAsync.valueOrNull,
      transactions: transactionsAsync.valueOrNull ?? const [],
      goals: goalsAsync.valueOrNull ?? const [],
      categories: categories,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0E1F2B),
      appBar: AppBar(
        title: const Text('Predictions & Reports'),
        centerTitle: false,
        backgroundColor: const Color(0xFF0B1A24),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Container(
            color: const Color(0xFF0B1A24),
            child: TabBar(
              controller: _tabController,
              tabs: const [Tab(text: 'Insights'), Tab(text: 'Reports')],
              indicatorColor: Colors.blueAccent,
              labelColor: Colors.blueAccent,
              unselectedLabelColor: Colors.white54,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3B82F6),
        onPressed: _isGenerating ? null : () => _generateReport(liveData),
        child: _isGenerating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.refresh, color: Colors.white),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _InsightsTab(
            liveData: liveData,
            reportError: _reportError,
            generatedReport: _generatedReport,
            onGenerate: () => _generateReport(liveData),
          ),
          _ReportsTab(liveData: liveData),
        ],
      ),
    );
  }

  Future<void> _generateReport(_LiveInsightsData liveData) async {
    setState(() {
      _isGenerating = true;
      _reportError = null;
    });

    final payload = liveData.toBackendPayload();

    try {
      final api = BackendApi.create();
      final result = await api.generateReport(payload);
      setState(() {
        _generatedReport = result;
      });
    } catch (error) {
      setState(() {
        _generatedReport = liveData.toLocalReport();
        _reportError = 'Using local analysis because the backend report failed: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }
}

class _InsightsTab extends StatelessWidget {
  const _InsightsTab({
    required this.liveData,
    required this.onGenerate,
    required this.reportError,
    required this.generatedReport,
  });

  final _LiveInsightsData liveData;
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
            const _SectionLabel(title: 'AI-Powered Analysis'),
            const SizedBox(height: 8),
            _CardBox(child: _BudgetStatusCard(data: liveData)),
            const SizedBox(height: 10),
            _CardBox(child: _ForecastCard(data: liveData)),
            const SizedBox(height: 10),
            const _SectionLabel(title: 'Summary'),
            _MutedText(liveData.summary),
            const SizedBox(height: 10),
            const _SectionLabel(title: 'Comparison Snapshot'),
            _ComparisonSnapshot(data: liveData),
            const SizedBox(height: 10),
            const _SectionLabel(title: 'Goal Progress'),
            _GoalSnapshot(goals: liveData.goals),
            const SizedBox(height: 10),
            const _SectionLabel(title: 'Current Spending by Category'),
            _CategoryBars(categories: liveData.categoryBreakdown),
            const SizedBox(height: 10),
            const _SectionLabel(title: 'Next Month Category Outlook'),
            _OutlookList(items: liveData.outlookItems),
            const SizedBox(height: 10),
            const _SectionLabel(title: 'Actionable Recommendations'),
            _ActionList(items: liveData.recommendations),
            const SizedBox(height: 10),
            const _SectionLabel(title: 'Alerts'),
            _ActionList(items: liveData.alerts),
            const SizedBox(height: 10),
            const _SectionLabel(title: 'Generate Report'),
            _CardBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Use the same Python ML/report pipeline on live home and wallet data.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onGenerate,
                      icon: const Icon(Icons.assessment),
                      label: Text(
                        generatedReport == null ? 'Generate Report' : 'Regenerate Report',
                      ),
                    ),
                  ),
                  if (reportError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      reportError!,
                      style: const TextStyle(color: Colors.orangeAccent, fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
            if (generatedReport != null) ...[
              const SizedBox(height: 10),
              const _SectionLabel(title: 'Latest Report Output'),
              _ReportPreview(report: generatedReport!),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _ReportsTab extends StatelessWidget {
  const _ReportsTab({required this.liveData});

  final _LiveInsightsData liveData;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionLabel(title: 'Daily Breakdown'),
            _DayBreakdown(days: liveData.dailyBreakdown),
            const SizedBox(height: 20),
            const _SectionLabel(title: 'Weekly Breakdown'),
            _WeekBreakdown(weeks: liveData.weeklyBreakdown),
            const SizedBox(height: 20),
            const _SectionLabel(title: 'Monthly Breakdown'),
            _MonthBreakdown(months: liveData.monthlyBreakdown),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CardBox extends StatelessWidget {
  const _CardBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF233342),
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}

class _MutedText extends StatelessWidget {
  const _MutedText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12));
  }
}

class _BudgetStatusCard extends StatelessWidget {
  const _BudgetStatusCard({required this.data});

  final _LiveInsightsData data;

  @override
  Widget build(BuildContext context) {
    final remaining = data.budgetLimit - data.currentSpending;
    final safe = data.projectedSpending <= data.budgetLimit;
    final statusColor = safe ? Colors.greenAccent : Colors.orangeAccent;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Budget Status',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              const Text('Current Spending', style: TextStyle(color: Colors.white54, fontSize: 10)),
              Text(
                '\$${data.currentSpending.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                safe
                    ? '✅ You\'re on track to stay within budget (\$${remaining.toStringAsFixed(2)} remaining)'
                    : '⚠️ You are likely to exceed your current budget.',
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: safe ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                safe ? 'LOW' : 'HIGH',
                style: TextStyle(
                  color: safe ? Colors.greenAccent : Colors.orangeAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Projected Spending', style: TextStyle(color: Colors.white54, fontSize: 10)),
            Text(
              '\$${data.projectedSpending.toStringAsFixed(2)}',
              style: TextStyle(color: statusColor, fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 24),
            const Text('Budget Limit', style: TextStyle(color: Colors.white54, fontSize: 10)),
            Text(
              '\$${data.budgetLimit.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ],
    );
  }
}

class _ForecastCard extends StatelessWidget {
  const _ForecastCard({required this.data});

  final _LiveInsightsData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Monthly Forecast',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              const Text('Predicted Amount', style: TextStyle(color: Colors.white54, fontSize: 10)),
              Text(
                '\$${data.monthlyForecast.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Average', style: TextStyle(color: Colors.white54, fontSize: 10)),
              Text(
                '\$${data.average.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Trend', style: TextStyle(color: Colors.white54, fontSize: 10)),
              Text(
                data.trend,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ComparisonSnapshot extends StatelessWidget {
  const _ComparisonSnapshot({required this.data});

  final _LiveInsightsData data;

  @override
  Widget build(BuildContext context) {
    return _CardBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _SnapshotTile(
                  label: 'Current Total',
                  value: '\$${data.currentSpending.toStringAsFixed(2)}',
                  accent: Colors.lightBlueAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SnapshotTile(
                  label: 'Projected Next Month',
                  value: '\$${data.monthlyForecast.toStringAsFixed(2)}',
                  accent: Colors.orangeAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Projected increase: \$${data.projectedIncrease.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your current budget is still under control overall. The forecast suggests next month will be higher unless spending changes, and food is the biggest pressure point right now.',
            style: TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(height: 8),
          Align(alignment: Alignment.centerLeft, child: _Tag(text: 'Watch: ${data.watchCategory}')),
        ],
      ),
    );
  }
}

class _SnapshotTile extends StatelessWidget {
  const _SnapshotTile({required this.label, required this.value, required this.accent});

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF20303D),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: accent, fontSize: 16, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _GoalSnapshot extends StatelessWidget {
  const _GoalSnapshot({required this.goals});

  final List<GoalModel> goals;

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) {
      return const _CardBox(
        child: Text(
          'No active goals yet. Set a goal in the Wallet tab and it will appear here.',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
      );
    }

    final totalTarget = goals.fold<double>(0, (sum, goal) => sum + goal.targetAmount);
    final totalCurrent = goals.fold<double>(0, (sum, goal) => sum + goal.currentAmount);
    final totalRemaining = goals.fold<double>(0, (sum, goal) => sum + goal.amountLeft);

    return _CardBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _SnapshotTile(label: 'Saved', value: '\$${totalCurrent.toStringAsFixed(2)}', accent: Colors.greenAccent)),
              const SizedBox(width: 8),
              Expanded(child: _SnapshotTile(label: 'Target', value: '\$${totalTarget.toStringAsFixed(2)}', accent: Colors.white)),
              const SizedBox(width: 8),
              Expanded(child: _SnapshotTile(label: 'Remaining', value: '\$${totalRemaining.toStringAsFixed(2)}', accent: Colors.orangeAccent)),
            ],
          ),
          const SizedBox(height: 12),
          ...goals.map(
            (goal) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(goal.iconData, color: Colors.white70, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      goal.title,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                  Text(
                    '${(goal.progress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBars extends StatelessWidget {
  const _CategoryBars({required this.categories});

  final List<_CategoryInsightsItem> categories;

  @override
  Widget build(BuildContext context) {
    final total = categories.fold<double>(0, (sum, item) => sum + item.amount);

    return _CardBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total spend: \$${total.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          ...categories.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ProgressRow(category: item, total: total),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.category, required this.total});

  final _CategoryInsightsItem category;
  final double total;

  @override
  Widget build(BuildContext context) {
    final fraction = total <= 0 ? 0.0 : (category.amount / total).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(category.name, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            Text('\$${category.amount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 6,
            value: fraction,
            backgroundColor: Colors.white10,
            color: category.color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${category.percent.toStringAsFixed(1)}% of current spending',
          style: const TextStyle(color: Colors.white54, fontSize: 10),
        ),
      ],
    );
  }
}

class _OutlookList extends StatelessWidget {
  const _OutlookList({required this.items});

  final List<_OutlookItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _CardBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        const _Tag(text: 'WATCH'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(item.description, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _SnapshotTile(label: 'Now', value: '\$${item.now.toStringAsFixed(2)}', accent: Colors.white)),
                        const SizedBox(width: 8),
                        Expanded(child: _SnapshotTile(label: 'Next month', value: '\$${item.nextMonth.toStringAsFixed(2)}', accent: Colors.white)),
                        const SizedBox(width: 8),
                        Expanded(child: _SnapshotTile(label: 'Change', value: '\$${item.change.toStringAsFixed(2)}', accent: Colors.white)),
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

class _ActionList extends StatelessWidget {
  const _ActionList({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF172733),
                  border: Border.all(color: Colors.white12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(item, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _DayBreakdown extends StatelessWidget {
  const _DayBreakdown({required this.days});

  final List<_DaySpend> days;

  @override
  Widget build(BuildContext context) {
    final total = days.fold<double>(0, (sum, item) => sum + item.amount);
    return _CardBox(
      child: Column(
        children: days
            .map(
              (day) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _DayRow(day: day, total: total),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({required this.day, required this.total});

  final _DaySpend day;
  final double total;

  @override
  Widget build(BuildContext context) {
    final fraction = total <= 0 ? 0.0 : (day.amount / total).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(day.day, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            Text('\$${day.amount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white70)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 4,
            value: fraction,
            backgroundColor: Colors.white10,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(height: 2),
        Align(
          alignment: Alignment.centerRight,
          child: Text('${day.transactions} transactions', style: const TextStyle(color: Colors.white54, fontSize: 10)),
        ),
      ],
    );
  }
}

class _WeekBreakdown extends StatelessWidget {
  const _WeekBreakdown({required this.weeks});

  final List<_TimeBucket> weeks;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: weeks
          .map(
            (week) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CardBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(week.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        Text('\$${week.total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.lightBlueAccent)),
                      ],
                    ),
                    Text('${week.count} transactions', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                    const SizedBox(height: 8),
                    ...week.categories.entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry.key, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                            Text('\$${entry.value.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                          ],
                        ),
                      ),
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

class _MonthBreakdown extends StatelessWidget {
  const _MonthBreakdown({required this.months});

  final List<_TimeBucket> months;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: months
          .map(
            (month) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CardBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(month.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        Text('\$${month.total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.lightBlueAccent)),
                      ],
                    ),
                    Text('${month.count} transactions', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                    const SizedBox(height: 8),
                    ...month.categories.entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry.key, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                            Text('\$${entry.value.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                          ],
                        ),
                      ),
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

class _ReportPreview extends StatelessWidget {
  const _ReportPreview({required this.report});

  final Map<String, dynamic> report;

  @override
  Widget build(BuildContext context) {
    final overrun = Map<String, dynamic>.from(report['overrunPrediction'] as Map? ?? {});
    final forecast = Map<String, dynamic>.from(report['monthlyForecast'] as Map? ?? {});
    final insights = List<dynamic>.from(report['insights'] as List? ?? const []);

    return _CardBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Risk: ${overrun['riskLevel'] ?? 'unknown'}', style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 4),
          Text('Projected spending: \$${(overrun['projectedSpending'] as num?)?.toDouble().toStringAsFixed(2) ?? '0.00'}', style: const TextStyle(color: Colors.white70)),
          Text('Forecast: \$${(forecast['predictedAmount'] as num?)?.toDouble().toStringAsFixed(2) ?? '0.00'}', style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          if (insights.isNotEmpty)
            Text('Top insight: ${(insights.first as Map)['title'] ?? ''}', style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

class _LiveInsightsData {
  const _LiveInsightsData({
    required this.currentSpending,
    required this.budgetLimit,
    required this.projectedSpending,
    required this.monthlyForecast,
    required this.average,
    required this.trend,
    required this.summary,
    required this.projectedIncrease,
    required this.watchCategory,
    required this.categoryBreakdown,
    required this.outlookItems,
    required this.alerts,
    required this.recommendations,
    required this.dailyBreakdown,
    required this.weeklyBreakdown,
    required this.monthlyBreakdown,
    required this.goals,
    required this.transactions,
  });

  final double currentSpending;
  final double budgetLimit;
  final double projectedSpending;
  final double monthlyForecast;
  final double average;
  final String trend;
  final String summary;
  final double projectedIncrease;
  final String watchCategory;
  final List<_CategoryInsightsItem> categoryBreakdown;
  final List<_OutlookItem> outlookItems;
  final List<String> alerts;
  final List<String> recommendations;
  final List<_DaySpend> dailyBreakdown;
  final List<_TimeBucket> weeklyBreakdown;
  final List<_TimeBucket> monthlyBreakdown;
  final List<GoalModel> goals;
  final List<TransactionModel> transactions;

  factory _LiveInsightsData.fromState({
    required MainFinanceData? finance,
    required List<TransactionModel> transactions,
    required List<GoalModel> goals,
    required List<BudgetModel> categories,
  }) {
    final expenseTransactions = transactions.where((tx) => tx.type.toLowerCase() != 'income').toList();
    final currentSpendingByCategory = _sumByCategory(expenseTransactions);
    final budgetsByCategory = {
      for (final category in categories) category.title.toLowerCase(): category.limitAmount,
    };

    final totalBudgetFromCategories = budgetsByCategory.values.fold<double>(0, (sum, value) => sum + value);
    final totalSpentFromTransactions = expenseTransactions.fold<double>(0, (sum, tx) => sum + tx.amount);
    final overallBudget = (finance?.budget ?? 0) > 0 ? finance!.budget : totalBudgetFromCategories;
    final currentSpending = finance?.totalExpenses ?? totalSpentFromTransactions;

    final monthlyHistory = _buildMonthlyHistory(expenseTransactions);
    final forecast = _linearForecast(monthlyHistory.isEmpty ? [currentSpending] : monthlyHistory);
    final monthlyForecast = forecast.predicted;
    final average = monthlyHistory.isEmpty
        ? currentSpending
        : monthlyHistory.fold<double>(0, (sum, value) => sum + value) / monthlyHistory.length;

    final categoryItems = currentSpendingByCategory.entries.map((entry) {
      final budget = budgetsByCategory[entry.key] ?? 0.0;
      final percent = currentSpending <= 0 ? 0.0 : (entry.value / currentSpending) * 100;
      return _CategoryInsightsItem(
        name: entry.key,
        amount: entry.value,
        percent: percent,
        budgetLimit: budget,
        color: _colorForCategory(entry.key),
      );
    }).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    final topCategory = categoryItems.isNotEmpty ? categoryItems.first.name : 'none';
    final growthRate = forecast.growthRate;
    final outlook = categoryItems.map((item) {
      final nextMonth = item.amount * (1 + growthRate.clamp(-0.15, 0.20));
      return _OutlookItem(
        name: item.name,
        description: item.budgetLimit > 0 && item.amount > item.budgetLimit
            ? 'This category is already above budget.'
            : item.amount > 0
                ? 'This category is likely to keep trending with your current pace.'
                : 'No recent activity in this category.',
        now: item.amount,
        nextMonth: nextMonth,
        change: nextMonth - item.amount,
      );
    }).toList();

    final alerts = <String>[
      if (overallBudget > 0 && currentSpending >= overallBudget * 0.75)
        '⚠️ You have used ${(currentSpending / overallBudget * 100).toStringAsFixed(1)}% of your monthly budget.',
      if (growthRate > 0.05) '📈 Increasing spending trend detected.',
      if (goals.any((goal) => goal.progress < 1.0)) '🎯 You have active savings goals in Wallet.',
      if (topCategory != 'none') 'Watch: $topCategory is your biggest pressure point.',
    ];

    final recommendations = <String>[
      if (topCategory != 'none') 'Focus on $topCategory first to reduce pressure quickly.',
      if (goals.isNotEmpty) 'Tie one savings goal to your biggest expense category to accelerate progress.',
      'Review budget vs spending after every new expense entry.',
    ];

    final dailyBreakdown = _buildDailyBreakdown(expenseTransactions);
    final weeklyBreakdown = _buildWeeklyBreakdown(expenseTransactions);
    final monthlyBreakdown = _buildMonthlyBreakdown(expenseTransactions);

    return _LiveInsightsData(
      currentSpending: currentSpending,
      budgetLimit: overallBudget,
      projectedSpending: monthlyForecast,
      monthlyForecast: monthlyForecast,
      average: average,
      trend: forecast.trendDescription,
      summary: currentSpending <= overallBudget
          ? '✅ Your budget is on track, but your spending is increasing.'
          : '⚠️ Your current spending is above the active budget.',
      projectedIncrease: monthlyForecast - currentSpending,
      watchCategory: topCategory,
      categoryBreakdown: categoryItems,
      outlookItems: outlook,
      alerts: alerts.isEmpty ? ['No major alerts right now.'] : alerts,
      recommendations: recommendations,
      dailyBreakdown: dailyBreakdown,
      weeklyBreakdown: weeklyBreakdown,
      monthlyBreakdown: monthlyBreakdown,
      goals: goals,
      transactions: transactions,
    );
  }

  Map<String, dynamic> toBackendPayload() {
    final budgets = <String, dynamic>{};
    for (final item in categoryBreakdown) {
      if (item.budgetLimit > 0) {
        budgets[item.name] = item.budgetLimit;
      }
    }

    final currentSpendingMap = <String, dynamic>{
      for (final item in categoryBreakdown) item.name: item.amount,
    };

    final expenses = transactions
        .where((tx) => tx.type.toLowerCase() != 'income')
        .map(
          (tx) => {
            'date': tx.dateTime.toIso8601String(),
            'amount': tx.amount,
            'category': tx.category,
            'description': tx.description,
          },
        )
        .toList();

    return {
      'userId': Supabase.instance.client.auth.currentUser?.id ?? 'local-user',
      'expenses': expenses,
      'budgets': budgets,
      'currentSpending': currentSpendingMap,
      'historicalMonthly': _buildMonthlyHistory(transactions.where((tx) => tx.type.toLowerCase() != 'income').toList()),
      'daysInMonth': DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day,
      'currentDay': DateTime.now().day,
      'goals': goals
          .map(
            (goal) => {
              'title': goal.title,
              'currentAmount': goal.currentAmount,
              'targetAmount': goal.targetAmount,
              'progress': goal.progress,
            },
          )
          .toList(),
    };
  }

  Map<String, dynamic> toLocalReport() {
    final now = DateTime.now();
    return {
      'userId': Supabase.instance.client.auth.currentUser?.id ?? 'local-user',
      'periodStart': DateTime(now.year, now.month, 1).toIso8601String(),
      'periodEnd': now.toIso8601String(),
      'totalSpending': currentSpending,
      'totalBudget': budgetLimit,
      'overallProgress': budgetLimit > 0 ? currentSpending / budgetLimit : 0.0,
      'overrunPrediction': {
        'willOverrun': projectedSpending > budgetLimit,
        'confidence': 0.7,
        'projectedSpending': projectedSpending,
        'budgetLimit': budgetLimit,
        'daysRemaining': DateTime(now.year, now.month + 1, 0).day - now.day,
        'riskLevel': projectedSpending > budgetLimit ? 'high' : 'low',
        'message': projectedSpending > budgetLimit
            ? 'Projected spending is above your budget.'
            : 'You are on track to stay within budget.',
      },
      'monthlyForecast': {
        'predictedAmount': monthlyForecast,
        'confidence': 0.7,
        'historicalData': _buildMonthlyHistory(transactions.where((tx) => tx.type.toLowerCase() != 'income').toList()),
        'trend': monthlyForecast - currentSpending,
        'trendDescription': trend,
      },
      'smartTips': recommendations
          .map(
            (text) => {
              'title': text,
              'description': text,
              'recommendation': text,
              'priority': 'medium',
              'iconType': 'info',
            },
          )
          .toList(),
      'insights': [
        {
          'title': 'Live goal snapshot',
          'description': summary,
          'insights': [summary, 'Goals tracked: ${goals.length}'],
          'recommendations': recommendations,
          'confidence': 0.9,
          'category': 'live_state',
          'generatedAt': now.toIso8601String(),
        }
      ],
      'categoryBreakdown': {
        for (final item in categoryBreakdown) item.name: item.amount,
      },
    };
  }
}

class _CategoryInsightsItem {
  const _CategoryInsightsItem({
    required this.name,
    required this.amount,
    required this.percent,
    required this.budgetLimit,
    required this.color,
  });

  final String name;
  final double amount;
  final double percent;
  final double budgetLimit;
  final Color color;
}

class _OutlookItem {
  const _OutlookItem({
    required this.name,
    required this.description,
    required this.now,
    required this.nextMonth,
    required this.change,
  });

  final String name;
  final String description;
  final double now;
  final double nextMonth;
  final double change;
}

class _DaySpend {
  const _DaySpend(this.day, this.amount, this.transactions);

  final String day;
  final double amount;
  final int transactions;
}

class _TimeBucket {
  const _TimeBucket({
    required this.label,
    required this.total,
    required this.count,
    required this.categories,
  });

  final String label;
  final double total;
  final int count;
  final Map<String, double> categories;
}

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

_LinearForecast _linearForecast(List<double> values) {
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
  double sumX = 0;
  double sumY = 0;
  double sumXY = 0;
  double sumX2 = 0;

  for (var i = 0; i < n; i++) {
    final x = i.toDouble();
    final y = values[i];
    sumX += x;
    sumY += y;
    sumXY += x * y;
    sumX2 += x * x;
  }

  final denominator = (n * sumX2) - (sumX * sumX);
  final slope = denominator == 0 ? 0.0 : ((n * sumXY) - (sumX * sumY)) / denominator;
  final intercept = (sumY - (slope * sumX)) / n;
  final nextMonthIndex = n.toDouble();
  final predicted = math.max(0.0, slope * nextMonthIndex + intercept);
  final previous = values[n - 2] == 0 ? 1.0 : values[n - 2];
  final growthRate = (values[n - 1] - previous) / previous;

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

List<double> _buildMonthlyHistory(List<TransactionModel> transactions) {
  final monthlyTotals = <String, double>{};
  for (final tx in transactions) {
    final key = _monthKey(tx.dateTime);
    monthlyTotals[key] = (monthlyTotals[key] ?? 0) + tx.amount;
  }

  final keys = monthlyTotals.keys.toList()..sort();
  return keys.map((key) => monthlyTotals[key] ?? 0.0).toList();
}

List<_DaySpend> _buildDailyBreakdown(List<TransactionModel> transactions) {
  final totals = <String, double>{};
  final counts = <String, int>{};

  for (final tx in transactions) {
    final label = _weekdayName(tx.dateTime.weekday);
    totals[label] = (totals[label] ?? 0) + tx.amount;
    counts[label] = (counts[label] ?? 0) + 1;
  }

  final order = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return order
      .where((day) => totals.containsKey(day))
      .map((day) => _DaySpend(day, totals[day] ?? 0.0, counts[day] ?? 0))
      .toList();
}

List<_TimeBucket> _buildWeeklyBreakdown(List<TransactionModel> transactions) {
  final buckets = <String, Map<String, dynamic>>{};
  for (final tx in transactions) {
    final label = 'Week ${((tx.dateTime.day - 1) ~/ 7) + 1}';
    final bucket = buckets.putIfAbsent(label, () => {'total': 0.0, 'count': 0, 'categories': <String, double>{}});
    bucket['total'] = (bucket['total'] as double) + tx.amount;
    bucket['count'] = (bucket['count'] as int) + 1;
    final categories = bucket['categories'] as Map<String, double>;
    categories[tx.category] = (categories[tx.category] ?? 0) + tx.amount;
  }

  final keys = buckets.keys.toList()..sort();
  return keys
      .map(
        (key) => _TimeBucket(
          label: key,
          total: buckets[key]?['total'] as double? ?? 0.0,
          count: buckets[key]?['count'] as int? ?? 0,
          categories: Map<String, double>.from(buckets[key]?['categories'] as Map? ?? const {}),
        ),
      )
      .toList();
}

List<_TimeBucket> _buildMonthlyBreakdown(List<TransactionModel> transactions) {
  final buckets = <String, Map<String, dynamic>>{};
  for (final tx in transactions) {
    final label = _monthKey(tx.dateTime, fullLabel: true);
    final bucket = buckets.putIfAbsent(label, () => {'total': 0.0, 'count': 0, 'categories': <String, double>{}});
    bucket['total'] = (bucket['total'] as double) + tx.amount;
    bucket['count'] = (bucket['count'] as int) + 1;
    final categories = bucket['categories'] as Map<String, double>;
    categories[tx.category] = (categories[tx.category] ?? 0) + tx.amount;
  }

  final keys = buckets.keys.toList()..sort();
  return keys
      .map(
        (key) => _TimeBucket(
          label: key,
          total: buckets[key]?['total'] as double? ?? 0.0,
          count: buckets[key]?['count'] as int? ?? 0,
          categories: Map<String, double>.from(buckets[key]?['categories'] as Map? ?? const {}),
        ),
      )
      .toList();
}

Map<String, double> _sumByCategory(List<TransactionModel> transactions) {
  final totals = <String, double>{};
  for (final tx in transactions) {
    final key = tx.category.trim().toLowerCase().isEmpty ? 'other' : tx.category.trim().toLowerCase();
    totals[key] = (totals[key] ?? 0) + tx.amount;
  }
  return totals;
}

String _monthKey(DateTime dateTime, {bool fullLabel = false}) {
  if (fullLabel) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${monthNames[dateTime.month - 1]} ${dateTime.year}';
  }
  return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}';
}

String _weekdayName(int weekday) {
  const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return names[(weekday - 1).clamp(0, 6)];
}

Color _colorForCategory(String category) {
  switch (category.toLowerCase()) {
    case 'food':
      return const Color(0xFF4CAF50);
    case 'transport':
      return const Color(0xFF42A5F5);
    case 'shopping':
      return const Color(0xFF26A69A);
    case 'utilities':
    case 'bills':
      return const Color(0xFFFF9800);
    case 'health':
      return const Color(0xFFBDBDBD);
    case 'entertainment':
      return const Color(0xFF8D6E63);
    default:
      return Colors.indigoAccent;
  }
}