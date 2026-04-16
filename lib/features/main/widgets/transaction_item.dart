import 'package:flutter/material.dart';

class TransactionData {
  final String title;
  final String subtitle;
  final double amount;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;

  const TransactionData({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
  });

  bool get isIncome => amount >= 0;
}

class TransactionItem extends StatelessWidget {
  final TransactionData data;

  const TransactionItem({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final isIncome = data.isIncome;

    // Just for adding (+, green) or (-, red)
    final amountText = isIncome
        ? '+\$ ${_formatNumber(data.amount.abs())}'
        : '-\$ ${_formatNumber(data.amount.abs())}';
    final amountColor = isIncome
        ? const Color(0xFF2E7D32)
        : const Color(0xFFD32F2F);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: data.iconBgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(data.icon, color: data.iconColor, size: 24),
          ),
          const SizedBox(width: 14),

          // Title & subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  data.subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),

          // Amount whether income or expense
          Text(
            amountText,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double value) {
    // Check if the number has double value or not
    if (value == value.truncateToDouble()) {
      // Format integers with comma separators
      return value.toInt().toString().replaceAllMapped(
        // Putting a comma every 3 digits from the right"
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
    }
    // Format decimals. If it has decimals ,converts number to 3 decimal places
    final parts = value.toStringAsFixed(3).split('.');
    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '$integerPart.${parts[1]}';
  }
}

//  Sample Transaction List

final List<TransactionData> sampleTransactions = [
  TransactionData(
    title: 'Salary',
    subtitle: 'Monthly salary',
    amount: 100000,
    icon: Icons.account_balance_wallet_rounded,
    iconBgColor: const Color(0xFF1A237E).withValues(alpha: 0.1),
    iconColor: const Color(0xFF1A237E),
  ),
  TransactionData(
    title: 'Uber',
    subtitle: 'Transaction fee',
    amount: -945.214,
    icon: Icons.directions_car_rounded,
    iconBgColor: const Color(0xFFF44336).withValues(alpha: 0.1),
    iconColor: const Color(0xFFF44336),
  ),
  TransactionData(
    title: 'Gym Membership',
    subtitle: 'Subscription fee',
    amount: -155.143,
    icon: Icons.fitness_center_rounded,
    iconBgColor: const Color(0xFF9C27B0).withValues(alpha: 0.1),
    iconColor: const Color(0xFF9C27B0),
  ),
];
