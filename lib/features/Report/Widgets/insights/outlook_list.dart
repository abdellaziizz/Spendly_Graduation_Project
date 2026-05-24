import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/features/authentication/providers/currency_provider.dart';
import 'package:spendly/features/Report/domain/models/outlook_item.dart';

class OutlookList extends ConsumerWidget {
  const OutlookList({Key? key, required this.items}) : super(key: key);

  final List<OutlookItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curSymbol = ref.watch(currencySymbolProvider);
    
    // Sort items if needed, and slice the list to only show the top 3 items
    final topItems = items.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'Category Outlook',
            style: TextStyle(
              color: Color(0xFF1E1E24),
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ...topItems.map((item) {
          // Calculate the percentage change string dynamically
          // If item.change is already a percentage integer (e.g. 15), use it directly.
          final percentageText = "${item.change >= 0 ? '+' : ''}${item.change.toStringAsFixed(0)}%";
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF9F6FE), // Card background matching image tint
                borderRadius: BorderRadius.circular(24),
              ),
              clipBehavior: Clip.antiAlias, // Ensures the left red indicator conforms to the border radius
              child: Stack(
                children: [
                  // Red Warning indicator strip on the far left side
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 5,
                      color: const Color(0xFFC92A2A), // Vibrant Crimson Red
                    ),
                  ),
                  
                  // Main card content body
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Title and Red "WATCH" Badge
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              item.name, // e.g., "Dining & Groceries"
                              style: const TextStyle(
                                color: Color(0xFF1E1E24),
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFCE8E6), // Light red tint badge
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'WATCH',
                                style: TextStyle(
                                  color: Color(0xFFC92A2A),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        
                        // Description text
                        Text(
                          item.description, // e.g., "Frequent small transactions are inflating this budget."
                          style: const TextStyle(
                            color: Color(0xFF5A5A65),
                            fontSize: 16,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Bottom row featuring stylized data pill boxes
                        Row(
                          children: [
                            // "NOW" Metric Block
                            Expanded(
                              child: _buildMetricTile(
                                label: 'NOW',
                                value: '$curSymbol${item.now.toStringAsFixed(0)}',
                                backgroundColor: const Color(0xFFF1F0FA),
                                textColor: const Color(0xFF1E1E24),
                              ),
                            ),
                            const SizedBox(width: 12),
                            
                            // "NEXT" Metric Block
                            Expanded(
                              child: _buildMetricTile(
                                label: 'NEXT',
                                value: '$curSymbol${item.nextMonth.toStringAsFixed(0)}',
                                backgroundColor: const Color(0xFFF1F0FA),
                                textColor: const Color(0xFF1E1E24),
                              ),
                            ),
                            const SizedBox(width: 12),
                            
                            // "CHANGE" Highlighting Block
                            Expanded(
                              child: _buildMetricTile(
                                label: 'CHANGE',
                                value: percentageText,
                                backgroundColor: const Color(0xFFFCE2DC), // Pastel Red block background
                                textColor: const Color(0xFFC92A2A), // Contrasting dark red textual indicators
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  // Extracted helper method to cleanly build identical metric boxes
  Widget _buildMetricTile({
    required String label,
    required String value,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: textColor.withOpacity(0.55),
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}