import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spendly/features/main/models/transaction_model.dart';
import 'package:spendly/services/cache/local_cache_service.dart';
import 'package:spendly/services/connectivity/connectivity_provider.dart';

class TransactionsListNotifier extends AsyncNotifier<List<TransactionModel>> {
  @override
  Future<List<TransactionModel>> build() async {
    return _fetch();
  }

  Future<List<TransactionModel>> _fetch() async {
    final isOnline = ref.read(connectivityServiceProvider).isOnline;
    final cache = LocalCacheService.instance;
    final pendingQueue = await cache.getPendingQueue();

    List<TransactionModel> serverTx = [];

    if (!isOnline) {
      serverTx = await cache.getCachedTransactions();
    } else {
      try {
        final supabase = Supabase.instance.client;
        final data = await supabase
            .from('transactions')
            .select(
              'id, type, amount, title, description, '
              'transaction_date, input_method, '
              'categories(name)', // join to get category name
            )
            .order('transaction_date', ascending: false)
            .order('created_at', ascending: false);

        serverTx = (data as List).map((row) {
          final categoryName =
              (row['categories'] as Map<String, dynamic>?)?['name']
                  as String? ??
              '';
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

        await cache.cacheTransactions(serverTx);
      } catch (e) {
        // Fallback to cache on error
        serverTx = await cache.getCachedTransactions();
      }
    }

    // Inject pending transactions into the list
    final pendingTx = pendingQueue
        .map(
          (p) => TransactionModel(
            id: p.localId,
            title: p.title,
            description: p.description,
            amount: p.amount,
            category: p.category,
            type: p.type,
            dateTime: p.createdAt,
            isPending: true,
          ),
        )
        .toList();

    return [...pendingTx, ...serverTx];
  }

  Future<void> deleteTransaction(String id) async {
    if (state.value != null) {
      state = AsyncData(state.value!.where((t) => t.id != id).toList());
    }

    final supabase = Supabase.instance.client;
    try {
      await supabase.from('transactions').delete().eq('id', id);
      if (state.value != null) {
        await LocalCacheService.instance.cacheTransactions(
          state.value!.where((t) => !t.isPending).toList(),
        );
      }
    } catch (_) {}
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch());
  }
}

final transactionsListProvider =
    AsyncNotifierProvider<TransactionsListNotifier, List<TransactionModel>>(() {
      return TransactionsListNotifier();
    });
