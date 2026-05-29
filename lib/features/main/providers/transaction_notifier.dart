import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction_model.dart';

class TransactionNotifier extends StateNotifier<List<TransactionModel>> {
  TransactionNotifier() : super([]);

  void addTransaction(TransactionModel transaction) {
    state = [transaction, ...state];
  }
}

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, List<TransactionModel>>((ref) {
      return TransactionNotifier();
    });
