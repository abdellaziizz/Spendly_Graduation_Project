import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MLChatbotService {
  static final _apiKey = dotenv.env['API_KEY']!;
  
  // ML Backend URL
  static const String ML_BASE_URL = 'http://localhost:5000';
  static const Duration _cacheTtl = Duration(minutes: 5);
  
  // Cached user financial data
  Map<String, dynamic>? _cachedFinancialData;
  DateTime? _lastFetchTime;

  MLChatbotService();

  /// Fetches user financial data from ML backend
  Future<Map<String, dynamic>> fetchFinancialData({
    required double currentSpending,
    required double budgetLimit,
    required List<Map<String, dynamic>> expenses,
    required int daysInMonth,
    required int currentDay,
    required List<double> historicalMonthly,
  }) async {
    try {
      // Check cache (5 minutes)
      if (_cachedFinancialData != null &&
          _lastFetchTime != null &&
          DateTime.now().difference(_lastFetchTime!) < _cacheTtl) {
        return _cachedFinancialData!;
      }

      final response = await http.post(
        Uri.parse('$ML_BASE_URL/api/predictions/all-predictions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'currentSpending': currentSpending,
          'budgetLimit': budgetLimit,
          'expenses': expenses,
          'daysInMonth': daysInMonth,
          'currentDay': currentDay,
          'historicalMonthly': historicalMonthly,
          'currentMonth': currentSpending,
        }),
      );

      if (response.statusCode == 200) {
        _cachedFinancialData = jsonDecode(response.body);
        _lastFetchTime = DateTime.now();
        return _cachedFinancialData!;
      } else {
        throw Exception('Failed to fetch financial data');
      }
    } catch (e) {
      return {};
    }
  }

  String _formatMoney(dynamic value) {
    final number = (value is num) ? value.toDouble() : double.tryParse('$value') ?? 0.0;
    return '\$${number.toStringAsFixed(2)}';
  }

  /// Build a model-ready context string that can be appended to Gemini prompts.
  String formatContextForModel(Map<String, dynamic> data) {
    if (data.isEmpty) return '';

    final overrun = (data['overrunPrediction'] as Map?)?.cast<String, dynamic>() ?? {};
    final forecast = (data['forecast'] as Map?)?.cast<String, dynamic>() ?? {};
    final insights = (data['insights'] as Map?)?.cast<String, dynamic>() ?? {};

    final buf = StringBuffer();
    buf.writeln('\n\n[Spendly ML Context]');

    if (overrun.isNotEmpty) {
      buf.writeln('Budget status: current ${_formatMoney(overrun['current_spending'])}');
      buf.writeln('Budget limit: ${_formatMoney(overrun['budget_limit'])}');
      buf.writeln('Projected: ${_formatMoney(overrun['projected_spending'])}');
      buf.writeln('Risk level: ${overrun['risk_level'] ?? 'unknown'}');
    }

    if (forecast.isNotEmpty) {
      buf.writeln('Forecast: predicted ${_formatMoney(forecast['predicted_amount'])}');
      buf.writeln('Trend: ${forecast['trend'] ?? 'stable'}');
    }

    final patterns = insights['spending_patterns'] as Map?;
    if (patterns != null) {
      final totals = patterns['category_totals'] as Map?;
      if (totals != null) {
        buf.writeln('Category totals:');
        totals.forEach((k, v) {
          buf.writeln('- $k: ${_formatMoney(v)}');
        });
      }
    }

    final outlooks = insights['category_outlooks'] as List?;
    if (outlooks != null && outlooks.isNotEmpty) {
      buf.writeln('Category outlooks:');
      for (var o in outlooks.take(5)) {
        try {
          final cat = o['category'];
          final proj = _formatMoney(o['projected_next_month']);
          final reason = o['reason'] ?? '';
          buf.writeln('- $cat -> $proj (${reason})');
        } catch (_) {}
      }
    }

    return buf.toString();
  }

  List<Map<String, dynamic>> _extractCategoryRows(Map<String, dynamic> data) {
    final patterns = data['insights']?['spending_patterns'];
    final breakdown = patterns is Map<String, dynamic> ? patterns['category_breakdown'] : null;
    if (breakdown is List) {
      return breakdown.whereType<Map>().map((item) => item.cast<String, dynamic>()).toList();
    }

    final outlooks = data['insights']?['category_outlooks'];
    if (outlooks is List) {
      return outlooks.whereType<Map>().map((item) => item.cast<String, dynamic>()).toList();
    }

    return [];
  }

  String _buildImmediateFinancialReply(String message, Map<String, dynamic> data) {
    final lowerMessage = message.toLowerCase();
    final overrun = (data['overrunPrediction'] as Map?)?.cast<String, dynamic>() ?? {};
    final forecast = (data['forecast'] as Map?)?.cast<String, dynamic>() ?? {};
    final insights = (data['insights'] as Map?)?.cast<String, dynamic>() ?? {};
    final comparison = (insights['comparison_summary'] as Map?)?.cast<String, dynamic>() ?? {};
    final categoryRows = _extractCategoryRows(data);

    if (lowerMessage.contains('week') || lowerMessage.contains('weekly') || lowerMessage.contains('recap')) {
      final total = _formatMoney((comparison['current_total'] ?? insights['spending_patterns']?['total_spending']) ?? 0);
      final projected = _formatMoney(comparison['projected_total'] ?? forecast['predicted_amount'] ?? 0);
      final risk = overrun['risk_level'] ?? 'low';
      final trend = forecast['trend'] ?? 'stable';

      final categorySummary = categoryRows.take(4).map((row) {
        final name = row['category']?.toString() ?? 'other';
        final amount = _formatMoney(row['amount'] ?? row['current_amount'] ?? 0);
        return '$name $amount';
      }).join(', ');

      return [
        'Here is your weekly recap.',
        'You spent $total so far and the next-month projection is $projected.',
        'Trend: $trend. Budget risk: $risk.',
        if (categorySummary.isNotEmpty) 'Top categories: $categorySummary.',
        if (comparison['highest_risk_category'] != null)
          'Main watch area: ${comparison['highest_risk_category']}.',
        if (comparison['best_saving_category'] != null)
          'Best saving opportunity: ${comparison['best_saving_category']}.',
      ].join(' ');
    }

    if (lowerMessage.contains('save') || lowerMessage.contains('saving')) {
      final saver = comparison['best_saving_category'];
      final riskLevel = overrun['risk_level'] ?? 'low';
      return [
        'To save more right now, focus on your highest-pressure categories first.',
        if (saver != null) 'Your clearest saving opportunity is $saver.',
        'Your current budget risk is $riskLevel, so small cuts in food, transport, or shopping will have the fastest impact.',
      ].join(' ');
    }

    if (lowerMessage.contains('food')) {
      final foodRow = categoryRows.firstWhere(
        (row) => row['category']?.toString().toLowerCase().contains('food') == true,
        orElse: () => {},
      );
      final amount = foodRow.isNotEmpty ? _formatMoney(foodRow['amount'] ?? foodRow['current_amount'] ?? 0) : 'no data';
      final outlook = foodRow['outlook']?.toString();
      final reason = foodRow['reason']?.toString();
      return 'Food is at ${amount}${outlook != null ? ', outlook: $outlook' : ''}${reason != null && reason.isNotEmpty ? '. $reason' : '.'}';
    }

    if (lowerMessage.contains('transport')) {
      final row = categoryRows.firstWhere(
        (item) => item['category']?.toString().toLowerCase().contains('transport') == true,
        orElse: () => {},
      );
      final amount = row.isNotEmpty ? _formatMoney(row['amount'] ?? row['current_amount'] ?? 0) : 'no data';
      final reason = row['reason']?.toString();
      return 'Transport is currently at $amount${reason != null && reason.isNotEmpty ? '. $reason' : '.'}';
    }

    if (lowerMessage.contains('clothes') || lowerMessage.contains('shopping')) {
      final row = categoryRows.firstWhere(
        (item) => item['category']?.toString().toLowerCase().contains('shop') == true ||
            item['category']?.toString().toLowerCase().contains('cloth') == true,
        orElse: () => {},
      );
      final amount = row.isNotEmpty ? _formatMoney(row['amount'] ?? row['current_amount'] ?? 0) : 'no data';
      final reason = row['reason']?.toString();
      return 'Shopping/clothes are currently at $amount${reason != null && reason.isNotEmpty ? '. $reason' : '.'}';
    }

    if (overrun.isNotEmpty && forecast.isNotEmpty) {
      final current = _formatMoney(overrun['current_spending'] ?? 0);
      final limit = _formatMoney(overrun['budget_limit'] ?? 0);
      final projected = _formatMoney(overrun['projected_spending'] ?? 0);
      final risk = overrun['risk_level'] ?? 'low';
      final trend = forecast['trend'] ?? 'stable';

      return [
        'You are currently at $current against a budget of $limit.',
        'Projected spending is $projected and the trend is $trend.',
        'Budget risk is $risk.',
        if (insights['summary'] != null) insights['summary'].toString(),
      ].join(' ');
    }

    return 'I can give you a fast financial recap if you ask about budget, food, transport, shopping, savings, or weekly report.';
  }

  /// Sends a message with immediate local financial context.
  Future<String> sendMessage(
    String message, {
    Map<String, dynamic>? financialData,
  }) async {
    try {
      final data = financialData ?? _cachedFinancialData ?? {};
      final localResponse = _buildImmediateFinancialReply(message, data);
      return localResponse;
    } catch (e) {
      return 'Error: $e';
    }
  }

  /// Clears cached financial data
  void clearCache() {
    _cachedFinancialData = null;
    _lastFetchTime = null;
  }

  /// Analyzes user message to determine if financial context is needed
  bool shouldIncludeFinancialContext(String message) {
    final financialKeywords = [
      'budget',
      'spending',
      'expense',
      'money',
      'savings',
      'forecast',
      'predict',
      'overrun',
      'category',
      'how much',
      'should i',
      'can i afford',
      'how can i save',
      'where did i spend',
      'analysis',
      'trend',
      'warning',
      'alert',
    ];

    final lowerMessage = message.toLowerCase();
    return financialKeywords.any((keyword) => lowerMessage.contains(keyword));
  }
}
