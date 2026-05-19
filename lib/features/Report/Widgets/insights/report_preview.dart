import 'package:flutter/material.dart';
import 'package:spendly/features/Report/Widgets/common/card_box.dart';

// Lastest Report Output
class ReportPreview extends StatelessWidget {
  const ReportPreview({required this.report});

  final Map<String, dynamic> report;

  @override
  Widget build(BuildContext context) {
    final overrun = Map<String, dynamic>.from(
      report['overrunPrediction'] as Map? ?? {},
    );
    final forecast = Map<String, dynamic>.from(
      report['monthlyForecast'] as Map? ?? {},
    );
    final insights = List<dynamic>.from(
      report['insights'] as List? ?? const [],
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Risk: ${overrun['riskLevel'] ?? 'unknown'}',
            style: const TextStyle(color: Colors.black),
          ),
          const SizedBox(height: 4),
          Text(
            'Projected spending: \$${(overrun['projectedSpending'] as num?)?.toDouble().toStringAsFixed(2) ?? '0.00'}',
            style: const TextStyle(color: Colors.black),
          ),
          Text(
            'Forecast: \$${(forecast['predictedAmount'] as num?)?.toDouble().toStringAsFixed(2) ?? '0.00'}',
            style: const TextStyle(color: Colors.black),
          ),
          const SizedBox(height: 8),
          if (insights.isNotEmpty)
            Text(
              'Top insight: ${(insights.first as Map)['title'] ?? ''}',
              style: const TextStyle(color: Colors.black),
            ),
        ],
      ),
    );
  }
}
// CardBox(
//       child: ,
//     )