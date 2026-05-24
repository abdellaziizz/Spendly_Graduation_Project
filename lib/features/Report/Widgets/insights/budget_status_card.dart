import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/features/authentication/providers/currency_provider.dart';
import 'package:spendly/features/Report/domain/models/live_insights_data.dart';

class BudgetStatusCard extends ConsumerWidget {
  const BudgetStatusCard({Key? key, required this.data}) : super(key: key);

  final LiveInsightsData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curSymbol = ref.watch(currencySymbolProvider);
    
    // Fallback logic / data mapping based on your model variables
    final remaining = data.budgetLimit - data.projectedSpending;
    final safe = data.projectedSpending <= data.budgetLimit;
    
    // Format values safely for UI presentation
    final formattedForecast = "$curSymbol${data.projectedSpending.toStringAsFixed(0)}";
    final formattedLimit = "$curSymbol${data.budgetLimit.toStringAsFixed(0)}";
    final formattedRemaining = "$curSymbol${remaining.abs().toStringAsFixed(0)}";

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // Light lavender/whitish card background
        borderRadius: BorderRadius.circular(28.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row: AI Analysis Title & Budget Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(
                    Icons.auto_awesome, // Sparkle icon
                    color: Color(0xFF4A3AFF), // Deep AI theme purple
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'AI Analysis',
                    style: TextStyle(
                      color: Color(0xFF1E1E24),
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E5FF), // Subtle purple badge background
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  safe ? 'Budget OK' : 'Over Budget',
                  style: const TextStyle(
                    color: Color(0xFF4A3AFF),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Main Body Text with highlighted spending pattern
          RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Color(0xFF4A4A52),
                fontSize: 16,
                height: 1.4,
                fontWeight: FontWeight.w400,
              ),
              children: [
                const TextSpan(text: "Based on your spending patterns , you're projected to end the month "),
                TextSpan(
                  text: safe 
                      ? "$formattedRemaining under budget" 
                      : "$formattedRemaining over budget",
                  style: TextStyle(
                    color: safe ? const Color(0xFF117553) : const Color(0xFFD32F2F), // Green or Red highlight
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Bottom Info Row: Status & Forecast Divider Section
          IntrinsicHeight(
            child: Row(
              children: [
                // Status Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status',
                        style: TextStyle(
                          color: Color(0xFF7A7A85),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        safe ? 'On Track' : 'At Risk',
                        style: const TextStyle(
                          color: Color(0xFF1E1E24),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Vertical Divider Line
                const VerticalDivider(
                  color: Color(0xFFD1CBD9),
                  thickness: 1,
                  width: 32,
                ),

                // Forecast Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Forecast',
                        style: TextStyle(
                          color: Color(0xFF7A7A85),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$formattedForecast / $formattedLimit',
                        style: const TextStyle(
                          color: Color(0xFF1E1E24),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}