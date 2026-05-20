import 'package:flutter/material.dart';
import 'package:spendly/features/Report/domain/models/live_insights_data.dart';

// Monthly Prediction
class ForecastCard extends StatelessWidget {
  const ForecastCard({required this.data});

  final LiveInsightsData data;

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
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Predicted Amount',
                style: TextStyle(color: Colors.white54, fontSize: 10),
              ),
              Text(
                '\$${data.monthlyForecast.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.lightBlueAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Average',
                style: TextStyle(color: Colors.white54, fontSize: 10),
              ),
              Text(
                '\$${data.average.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Trend',
                style: TextStyle(color: Colors.white54, fontSize: 10),
              ),
              Text(
                data.trend,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
