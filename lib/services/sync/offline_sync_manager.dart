import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spendly/features/main/models/pending_transaction.dart';
import 'package:spendly/features/main/Repository/category_repository.dart';
import 'package:spendly/features/main/providers/transactions_list_provider.dart';
import 'package:spendly/features/main/providers/main_finance_provider.dart';
import 'package:spendly/services/cache/local_cache_service.dart';
import 'package:spendly/services/connectivity/connectivity_provider.dart';

/// Manages the offline pending transaction queue.
/// Auto-syncs when the device comes back online.
class OfflineSyncManager extends Notifier<List<PendingTransaction>> {
  @override
  List<PendingTransaction> build() {
    // Load pending queue on startup
    _loadQueue();

    // Watch connectivity — sync automatically when back online
    ref.listen<bool>(isOnlineProvider, (prev, next) {
      final wasOffline = !(prev ?? true);
      final isNowOnline = next;
      if (wasOffline && isNowOnline) {
        syncPending();
      }
    });

    return [];
  }

  final _cache = LocalCacheService.instance;

  Future<void> _loadQueue() async {
    final queue = await _cache.getPendingQueue();
    state = queue;
  }

  /// Add a transaction to the offline queue.
  Future<void> addPending(PendingTransaction tx) async {
    await _cache.addToPendingQueue(tx);
    state = [...state, tx];
  }

  /// Sync all pending transactions to Supabase.
  /// Called automatically on reconnect and manually via "Try Again".
  Future<void> syncPending() async {
    if (state.isEmpty) return;

    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final synced = <String>[];

    for (final tx in state) {
      try {
        final isExpense = tx.type == 'expense';
        String? categoryId;

        if (isExpense) {
          categoryId = await resolveOrCreateCategory(
            supabase,
            userId,
            tx.category,
          );
        }

        final description = isExpense
            ? tx.description
            : (tx.description.isEmpty
                ? tx.category
                : '${tx.category} | ${tx.description}');

        await supabase.from('transactions').insert({
          'users_id': userId,
          'type': tx.type,
          'amount': tx.amount,
          'title': tx.title,
          'description': description,
          'category_id': categoryId,
          'input_method': tx.inputMethod,
        });

        synced.add(tx.localId);
        await _cache.removePendingById(tx.localId);
      } catch (e) {
        // Leave failed tx in queue for next sync attempt
      }
    }

    if (synced.isNotEmpty) {
      state = state.where((p) => !synced.contains(p.localId)).toList();
      // Refresh providers after successful sync
      ref.invalidate(transactionsListProvider);
      ref.invalidate(mainFinanceProvider);
    }
  }

  int get pendingCount => state.length;
  bool get hasPending => state.isNotEmpty;
}

final offlineSyncProvider =
    NotifierProvider<OfflineSyncManager, List<PendingTransaction>>(
      OfflineSyncManager.new,
    );
