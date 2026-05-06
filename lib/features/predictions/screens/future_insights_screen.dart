/// Future Insights Screen - AI-powered predictions and recommendations
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tspendly/features/predictions/providers/predictions_provider.dart';
import 'package:tspendly/features/predictions/models/prediction_models.dart';


class FutureInsightsScreen extends ConsumerStatefulWidget {
  const FutureInsightsScreen({super.key});

  @override
  ConsumerState<FutureInsightsScreen> createState() =>
      _FutureInsightsScreenState();
}


class _FutureInsightsScreenState extends ConsumerState<FutureInsightsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock detailed expense data
  final List<DailySpendData> dailyData = [
    DailySpendData(day: 'Mon', amount: 125.50, transactionCount: 3),
    DailySpendData(day: 'Tue', amount: 89.75, transactionCount: 2),
    DailySpendData(day: 'Wed', amount: 245.30, transactionCount: 5),
    DailySpendData(day: 'Thu', amount: 67.20, transactionCount: 2),
    DailySpendData(day: 'Fri', amount: 512.45, transactionCount: 8),
    DailySpendData(day: 'Sat', amount: 380.00, transactionCount: 6),
    DailySpendData(day: 'Sun', amount: 156.80, transactionCount: 3),
  ];

  final List<WeeklySpendData> weeklyData = [
    WeeklySpendData(
      week: 'Week 1',
      totalAmount: 1426.00,
      byCategory: {
        'Food & Dining': 350.50,
        'Transportation': 280.00,
        'Entertainment': 420.00,
        'Utilities': 375.50,
      },
      transactionCount: 28,
    ),
    WeeklySpendData(
      week: 'Week 2',
      totalAmount: 1385.50,
      byCategory: {
        'Food & Dining': 385.00,
        'Transportation': 250.00,
        'Entertainment': 385.50,
        'Utilities': 365.00,
      },
      transactionCount: 26,
    ),
  ];

  final List<MonthlySpendData> monthlyData = [
    MonthlySpendData(
      month: 'January',
      totalAmount: 3200.00,
      byCategory: {
        'Food & Dining': 850.00,
        'Transportation': 680.00,
        'Entertainment': 920.00,
        'Utilities': 750.00,
      },
      transactionCount: 84,
    ),
    MonthlySpendData(
      month: 'February',
      totalAmount: 2950.00,
      byCategory: {
        'Food & Dining': 720.00,
        'Transportation': 650.00,
        'Entertainment': 850.00,
        'Utilities': 730.00,
      },
      transactionCount: 78,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPredictions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadPredictions() {
    // Comprehensive sample data
    ref.read(predictionsProvider.notifier).getPredictions(
      currentSpending: 2500,
      budgetLimit: 3000,
      expenses: [
        // Daily expenses
        {'description': 'Morning Coffee', 'amount': 5.50, 'date': '2024-01-15'},
        {'description': 'Breakfast', 'amount': 12.75, 'date': '2024-01-15'},
        {'description': 'Grocery Store', 'amount': 107.25, 'date': '2024-01-15'},
        {'description': 'Gas', 'amount': 55.00, 'date': '2024-01-14'},
        {'description': 'Restaurant Lunch', 'amount': 34.50, 'date': '2024-01-14'},
        {'description': 'Movie Tickets', 'amount': 22.00, 'date': '2024-01-14'},
        {'description': 'Uber', 'amount': 18.75, 'date': '2024-01-13'},
        {'description': 'Gym Membership', 'amount': 50.00, 'date': '2024-01-13'},
        {'description': 'Dinner', 'amount': 55.00, 'date': '2024-01-13'},
        {'description': 'Online Shopping', 'amount': 89.99, 'date': '2024-01-12'},
        {'description': 'Electricity Bill', 'amount': 125.00, 'date': '2024-01-12'},
        {'description': 'Internet', 'amount': 70.00, 'date': '2024-01-12'},
      ],
      daysInMonth: 30,
      currentDay: 15,
      historicalMonthly: [2400, 2500, 2600, 2700, 2800],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(predictionsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Predictions & Reports'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor:
              Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          tabs: const [
            Tab(text: 'Insights'),
            Tab(text: 'Reports'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Insights Tab
          _buildInsightsTab(context, state),
          // Reports Tab
          _buildReportsTab(context),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadPredictions,
        tooltip: 'Refresh predictions',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildInsightsTab(BuildContext context, PredictionState state) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          sliver: state.isLoading
              ? SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Analyzing your financial data...',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : state.error != null
                  ? SliverToBoxAdapter(
                      child: _buildErrorCard(context, state.error!),
                    )
                  : state.data == null
                      ? SliverToBoxAdapter(
                          child: _buildNoDataCard(context),
                        )
                      : SliverList(
                          delegate: SliverChildListDelegate([
                            // AI Badge
                            _buildAIBadge(context),
                            const SizedBox(height: 16),
                            // Budget Status Card
                            if (state.data!.overrunPrediction != null)
                              _buildBudgetStatusCard(
                                context,
                                state.data!.overrunPrediction!,
                              ),
                            const SizedBox(height: 16),
                            // Monthly Forecast Card
                            if (state.data!.forecast != null)
                              _buildForecastCard(
                                context,
                                state.data!.forecast!,
                              ),
                            const SizedBox(height: 16),
                            // Insights Cards
                            if (state.data!.insights != null)
                              _buildInsightsCards(
                                context,
                                state.data!.insights!,
                              ),
                            const SizedBox(height: 32),
                          ]),
                        ),
        ),
      ],
    );
  }

  Widget _buildReportsTab(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Daily Report Section
              _buildSectionTitle(context, 'Daily Breakdown'),
              const SizedBox(height: 12),
              _buildDailyReport(context),
              const SizedBox(height: 32),

              // Weekly Report Section
              _buildSectionTitle(context, 'Weekly Breakdown'),
              const SizedBox(height: 12),
              _buildWeeklyReport(context),
              const SizedBox(height: 32),

              // Monthly Report Section
              _buildSectionTitle(context, 'Monthly Breakdown'),
              const SizedBox(height: 12),
              _buildMonthlyReport(context),
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildAIBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'AI-Powered Analysis',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetStatusCard(
      BuildContext context, OverrunPrediction pred) {
    final riskColor = _getRiskColor(pred.riskLevel);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Budget Status',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: riskColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  pred.riskLevel.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: riskColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Spending',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                  ),
                  Text(
                    '\$${pred.currentSpending.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Projected Spending',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                  ),
                  Text(
                    '\$${pred.projectedSpending.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: riskColor,
                        ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Budget Limit',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                  ),
                  Text(
                    '\$${pred.budgetLimit.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            pred.message,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildForecastCard(BuildContext context, MonthlForecast forecast) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Forecast',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Predicted Amount',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                  ),
                  Text(
                    '\$${forecast.predictedAmount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Average',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                  ),
                  Text(
                    '\$${forecast.average.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trend',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                  ),
                  Text(
                    forecast.trend,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsCards(BuildContext context, InsightData insights) {
    final spendingPatterns = insights.spendingPatterns ?? {};
    final comparison = insights.comparisonSummary ?? {};
    final categoryOutlooks = insights.categoryOutlooks ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (insights.summary != null) ...[
          Text(
            'Summary',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              insights.summary!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (comparison.isNotEmpty) ...[
          Text(
            'Comparison Snapshot',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          _buildComparisonCard(context, comparison),
          const SizedBox(height: 16),
        ],
        if (spendingPatterns.isNotEmpty) ...[
          Text(
            'Current Spending by Category',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          _buildCategoryBreakdownCard(context, spendingPatterns),
          const SizedBox(height: 16),
        ],
        if (categoryOutlooks.isNotEmpty) ...[
          Text(
            'Next Month Category Outlook',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          _buildCategoryOutlooksCard(context, categoryOutlooks),
          const SizedBox(height: 16),
        ],
        if ((insights.recommendations ?? []).isNotEmpty) ...[
          Text(
            'Actionable Recommendations',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ...insights.recommendations!.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildInsightTile(
                context,
                title: item.title,
                description: item.description,
                accentColor: item.priorityColor,
                trailing: item.action,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if ((insights.alerts ?? []).isNotEmpty) ...[
          Text(
            'Alerts',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ...insights.alerts!.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildInsightTile(
                context,
                title: item.title,
                description: item.description,
                accentColor: item.priorityColor,
                trailing: item.action,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildComparisonCard(BuildContext context, Map<String, dynamic> comparison) {
    final currentTotal = (comparison['current_total'] ?? 0).toDouble();
    final projectedTotal = (comparison['projected_total'] ?? 0).toDouble();
    final difference = (comparison['difference'] ?? 0).toDouble();
    final highestRisk = comparison['highest_risk_category']?.toString();
    final bestSaver = comparison['best_saving_category']?.toString();
    final message = comparison['message']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricBox(
                  context,
                  'Current Total',
                  '\$${currentTotal.toStringAsFixed(2)}',
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricBox(
                  context,
                  'Projected Next Month',
                  '\$${projectedTotal.toStringAsFixed(2)}',
                  difference >= 0 ? Colors.orange : Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            difference >= 0
                ? 'Projected increase: \$${difference.toStringAsFixed(2)}'
                : 'Projected savings: \$${difference.abs().toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: difference >= 0 ? Colors.orange : Colors.green,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (highestRisk != null || bestSaver != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (highestRisk != null)
                  _buildPill(context, 'Watch: $highestRisk', Colors.red),
                if (bestSaver != null)
                  _buildPill(context, 'Saving opportunity: $bestSaver', Colors.green),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdownCard(BuildContext context, Map<String, dynamic> spendingPatterns) {
    final breakdown = (spendingPatterns['category_breakdown'] as List? ?? []);
    final total = (spendingPatterns['total_spending'] ?? 0).toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Total spend: \$${total.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(height: 12),
          ...breakdown.map((item) {
            final category = item['category']?.toString() ?? 'other';
            final amount = (item['amount'] ?? 0).toDouble();
            final percentage = (item['percentage'] ?? 0).toDouble();
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          category,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      Text(
                        '\$${amount.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      value: (percentage / 100).clamp(0.0, 1.0),
                      backgroundColor: Theme.of(context).colorScheme.outlineVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _categoryColor(category),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$percentage% of current spending',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryOutlooksCard(BuildContext context, List<CategoryOutlook> categoryOutlooks) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        children: categoryOutlooks.map((outlook) {
          final signalColor = outlook.budgetSignal == 'save'
              ? Colors.green
              : outlook.budgetSignal == 'watch'
                  ? Colors.orange
                  : Colors.blue;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: signalColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: signalColor.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        outlook.category,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      _buildPill(
                        context,
                        outlook.budgetSignal.toUpperCase(),
                        signalColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    outlook.reason,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMiniMetric(
                          context,
                          'Now',
                          '\$${outlook.currentAmount.toStringAsFixed(2)}',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMiniMetric(
                          context,
                          'Next month',
                          '\$${outlook.projectedNextMonth.toStringAsFixed(2)}',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMiniMetric(
                          context,
                          'Change',
                          '${outlook.delta >= 0 ? '+' : ''}\$${outlook.delta.toStringAsFixed(2)}',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInsightTile(
    BuildContext context, {
    required String title,
    required String description,
    required Color accentColor,
    String? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (trailing != null) ...[
            const SizedBox(height: 8),
            Text(
              trailing,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricBox(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.65),
                ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetric(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPill(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }

  Color _categoryColor(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('food')) return Colors.green;
    if (lower.contains('transport')) return Colors.blue;
    if (lower.contains('entertain')) return Colors.purple;
    if (lower.contains('utilit')) return Colors.orange;
    if (lower.contains('shop') || lower.contains('cloth')) return Colors.teal;
    return Colors.grey;
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildDailyReport(BuildContext context) {
    double maxAmount = dailyData.fold(0, (max, d) => d.amount > max ? d.amount : max);

    return Column(
      children: dailyData.map((day) {
        final percentage = day.amount / maxAmount;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    day.day,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${day.amount.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        '${day.transactionCount} transactions',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  minHeight: 6,
                  value: percentage,
                  backgroundColor:
                      Theme.of(context).colorScheme.outlineVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWeeklyReport(BuildContext context) {
    return Column(
      children: weeklyData.map((week) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      week.week,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${week.totalAmount.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        Text(
                          '${week.transactionCount} transactions',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.6),
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ...week.byCategory.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '\$${entry.value.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMonthlyReport(BuildContext context) {
    return Column(
      children: monthlyData.map((month) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      month.month,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${month.totalAmount.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        Text(
                          '${month.transactionCount} transactions',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.6),
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ...month.byCategory.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '\$${entry.value.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildErrorCard(BuildContext context, String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.error),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'Error Loading Predictions',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(error),
        ],
      ),
    );
  }

  Widget _buildNoDataCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            size: 48,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No predictions available',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.6),
                ),
          ),
        ],
      ),
    );
  }
}
