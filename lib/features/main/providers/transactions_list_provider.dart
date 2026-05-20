import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spendly/features/main/transaction_model.dart';

class TransactionsListNotifier extends AsyncNotifier<List<TransactionModel>> {
  @override
  Future<List<TransactionModel>> build() async {
    return _fetch();
  }

  Future<List<TransactionModel>> _fetch() async {
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
  }

  Future<void> deleteTransaction(String id) async {
    if (state.value != null) {
      state = AsyncData(state.value!.where((t) => t.id != id).toList());
    }

    final supabase = Supabase.instance.client;
    await supabase.from('transactions').delete().eq('id', id);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch());
  }
}

final transactionsListProvider = AsyncNotifierProvider<TransactionsListNotifier, List<TransactionModel>>(() {
  return TransactionsListNotifier();
});
