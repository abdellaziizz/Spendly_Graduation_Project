import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spendly/features/main/transaction_model.dart';

final transactionsListProvider = FutureProvider<List<TransactionModel>>((
  ref,
) async {
  final supabase = Supabase.instance.client;

  // RLS auto-filters to auth.uid() = users_id
  final data = await supabase
      .from('transactions')
      .select(
        'id, type, amount, title, description, '
        'transaction_date, input_method, '
        'categories(name)', // join to get category name
      )
      .order('transaction_date', ascending: false)
      .order('created_at', ascending: false);

  return (data as List).map((row) {
    final categoryName =
        (row['categories'] as Map<String, dynamic>?)?['name'] as String? ?? '';
    return TransactionModel(
      id: row['id'] as String,
      title: row['title'] as String,
      description: row['description'] as String? ?? '',
      amount: double.parse(row['amount'].toString()),
      category: categoryName,
      type: row['type'] as String,
      dateTime: DateTime.parse(row['transaction_date'] as String),
    );
  }).toList();
});
