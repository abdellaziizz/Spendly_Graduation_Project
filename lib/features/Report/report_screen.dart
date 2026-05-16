import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:spendly/services/backend_api.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final api = BackendApi.create();

    return Scaffold(
      appBar: AppBar(title: const Text('Insights & Reports')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Insights & Predictions'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                // Sample payload - the UI should supply real user data
                final payload = {
                  'userId': 'local-test',
                  'expenses': [
                    {'date': DateTime.now().toIso8601String(), 'amount': 12.5, 'category': 'food', 'description': 'lunch'}
                  ],
                  'budgets': {'food': 200.0},
                  'currentSpending': {'food': 120.0},
                  'historicalMonthly': [120.0, 130.0, 125.0],
                  'daysInMonth': 30,
                  'currentDay': 16
                };

                try {
                  final result = await api.generateReport(payload);
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Report'),
                      content: SingleChildScrollView(child: Text(const JsonEncoder.withIndent('  ').convert(result))),
                      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
                    ),
                  );
                } catch (e) {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Error'),
                      content: Text(e.toString()),
                      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
                    ),
                  );
                }
              },
              child: const Text('Generate Report (local)'),
            ),
          ],
        ),
      ),
    );
  }
}
