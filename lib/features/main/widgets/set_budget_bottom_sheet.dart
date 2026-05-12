import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tspendly/features/main/providers/budget_provider.dart';

class SetBudgetSheet extends ConsumerStatefulWidget {
  const SetBudgetSheet({super.key});

  @override
  ConsumerState<SetBudgetSheet> createState() => _SetBudgetSheetState();
}

class _SetBudgetSheetState extends ConsumerState<SetBudgetSheet> {
  late TextEditingController _amountController;
  final List<int> _suggestions = [1000, 2000, 3000, 4000, 5000];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: "2,000.00");
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  void _onSuggestionTap(int amount) {
    setState(() {
      _amountController.text = formatAmount(amount);
    });
  }

  @override
  Widget build(BuildContext context) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    final currentMonth = months[DateTime.now().month - 1];

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Set Monthly Budget",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            Text(
              "Define your spending limit for $currentMonth",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),

            // Amount Input
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "\$",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Current Spend Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F7FA), // Light cyan
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Color(0xFF00796B),
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Current Spend: \$1,550.00",
                    style: TextStyle(
                      color: Color(0xFF00796B),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Suggestions
            Text(
              "QUICK SUGGESTIONS",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _suggestions.map((amount) {
                  final formattedAmount = formatAmount(amount);
                  final isSelected =
                      _amountController.text
                          .replaceAll(',', '')
                          .split('.')[0] ==
                      amount.toString();
                  return GestureDetector(
                    onTap: () => _onSuggestionTap(amount),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFEEF2FF)
                            : const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFC7D2FE)
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Text(
                        "\$$formattedAmount",
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xFF4F46E5)
                              : Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 40),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  final amount =
                      double.tryParse(
                        _amountController.text.replaceAll(',', ''),
                      ) ??
                      0.0;
                  ref.read(budgetProvider.notifier).state = amount;
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3730A3), // Deep purple
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Save Budget",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
