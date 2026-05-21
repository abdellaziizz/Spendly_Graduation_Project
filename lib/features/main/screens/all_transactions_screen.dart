import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendly/features/main/providers/transactions_list_provider.dart';
import 'package:spendly/features/main/widgets/transaction_item.dart';
import 'package:spendly/features/main/providers/main_finance_provider.dart';
import 'package:spendly/features/main/transaction_bottom.dart';
import 'package:spendly/theme/theme_extensions.dart';

class AllTransactionsScreen extends ConsumerWidget {
  const AllTransactionsScreen({super.key});

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food':      return Icons.restaurant_rounded;
      case 'Transport': return Icons.directions_car_rounded;
      case 'Shopping':  return Icons.shopping_bag_rounded;
      case 'Bills':     return Icons.receipt_long_rounded;
      case 'Salary':    return Icons.account_balance_wallet_rounded;
      default:          return Icons.category_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food':      return const Color(0xFFFF9800);
      case 'Transport': return const Color(0xFFF44336);
      case 'Shopping':  return const Color(0xFF9C27B0);
      case 'Bills':     return const Color(0xFF2196F3);
      case 'Salary':    return const Color(0xFF1A237E);
      default:          return const Color(0xFF607D8B);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(transactionsListProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('All Transactions'),
        centerTitle: true,
      ),
      body: txAsync.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.flag_outlined,
                    size: 64,
                    color: context.hintColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Transactions yet',
                    style: context.textTheme.headlineSmall,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final tx = transactions[index];
              final isIncome = tx.type == 'income';
              return TransactionItem(
                data: TransactionData(
                  id: tx.id,
                  title: tx.title,
                  subtitle: tx.description.isNotEmpty ? tx.description : tx.category,
                  amount: isIncome ? tx.amount : -tx.amount,
                  icon: _getCategoryIcon(tx.category),
                  iconBgColor: _getCategoryColor(tx.category).withValues(alpha: 0.1),
                  iconColor: _getCategoryColor(tx.category),
                ),
                onDelete: () async {
                  await ref.read(transactionsListProvider.notifier).deleteTransaction(tx.id);
                  await ref.read(mainFinanceProvider.notifier).refreshFinance();
                },
                onEdit: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => AddTransactionBottomSheet(transactionToEdit: tx),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
