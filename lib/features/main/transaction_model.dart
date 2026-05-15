// 1. transaction_model.dart
class TransactionModel {
  final String id;
  final String title;
  final String description;
  final double amount;
  final String category;
  final String type; // 'expense' or 'income'
  final DateTime dateTime;

  TransactionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.category,
    required this.type,
    required this.dateTime,
  });
}
