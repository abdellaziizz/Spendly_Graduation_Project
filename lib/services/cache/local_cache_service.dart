import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spendly/features/main/models/transaction_model.dart';
import 'package:spendly/features/main/providers/main_finance_provider.dart';
import 'package:spendly/features/main/models/pending_transaction.dart';

/// Keys used in SharedPreferences.
abstract class _Keys {
  static const transactions = 'cache_transactions';
  static const financeData = 'cache_finance_data';
  static const userInfo = 'cache_user_info';
  static const pendingQueue = 'offline_pending_queue';
}

/// Lightweight JSON cache backed by SharedPreferences.
///
/// Use this for:
///  - Home screen data (transactions, finance summary, user info)
///  - Offline pending transaction queue
///
/// Do NOT use flutter_secure_storage for this — it is meant for secrets
/// (tokens, keys) and is too slow/encrypted for bulk UI data.
class LocalCacheService {
  LocalCacheService._();
  static final LocalCacheService instance = LocalCacheService._();

  // ── Transactions ──────────────────────────────────────────────────────────

  Future<void> cacheTransactions(List<TransactionModel> list) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(list.map((t) => t.toJson()).toList());
    await prefs.setString(_Keys.transactions, encoded);
  }

  Future<List<TransactionModel>> getCachedTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_Keys.transactions);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── Finance summary ───────────────────────────────────────────────────────

  Future<void> cacheFinanceData(MainFinanceData data) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode({
      'budget': data.budget,
      'totalIncome': data.totalIncome,
      'totalExpenses': data.totalExpenses,
      'netBalance': data.netBalance,
    });
    await prefs.setString(_Keys.financeData, encoded);
  }

  Future<MainFinanceData?> getCachedFinanceData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_Keys.financeData);
    if (raw == null) return null;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return MainFinanceData(
        budget: (m['budget'] as num).toDouble(),
        totalIncome: (m['totalIncome'] as num).toDouble(),
        totalExpenses: (m['totalExpenses'] as num).toDouble(),
        netBalance: (m['netBalance'] as num).toDouble(),
      );
    } catch (_) {
      return null;
    }
  }

  // ── User info ─────────────────────────────────────────────────────────────

  Future<void> cacheUserInfo({
    required String firstName,
    required String gender,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _Keys.userInfo,
      jsonEncode({'firstName': firstName, 'gender': gender, 'email': email}),
    );
  }

  Future<Map<String, String>?> getCachedUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_Keys.userInfo);
    if (raw == null) return null;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return {
        'firstName': m['firstName'] as String,
        'gender': m['gender'] as String,
        'email': m['email'] as String,
      };
    } catch (_) {
      return null;
    }
  }

  // ── Offline pending queue ─────────────────────────────────────────────────

  Future<List<PendingTransaction>> getPendingQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_Keys.pendingQueue);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => PendingTransaction.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> savePendingQueue(List<PendingTransaction> queue) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(queue.map((p) => p.toJson()).toList());
    await prefs.setString(_Keys.pendingQueue, encoded);
  }

  Future<void> addToPendingQueue(PendingTransaction tx) async {
    final queue = await getPendingQueue();
    // Deduplicate by localId
    if (queue.any((p) => p.localId == tx.localId)) return;
    queue.add(tx);
    await savePendingQueue(queue);
  }

  Future<void> removePendingById(String localId) async {
    final queue = await getPendingQueue();
    queue.removeWhere((p) => p.localId == localId);
    await savePendingQueue(queue);
  }

  Future<bool> hasPendingTransactions() async {
    final queue = await getPendingQueue();
    return queue.isNotEmpty;
  }
}
