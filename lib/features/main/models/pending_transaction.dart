/// A transaction created while the device was offline.
/// Stored locally until the device comes back online, then synced to Supabase.
class PendingTransaction {
  final String localId; // UUID, used to deduplicate
  final String type; // 'expense' | 'income'
  final double amount;
  final String title;
  final String description;
  final String category; // category name (not ID — ID resolved on sync)
  final String inputMethod; // 'manual' | 'voice'
  final DateTime createdAt;

  const PendingTransaction({
    required this.localId,
    required this.type,
    required this.amount,
    required this.title,
    required this.description,
    required this.category,
    required this.inputMethod,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'localId': localId,
    'type': type,
    'amount': amount,
    'title': title,
    'description': description,
    'category': category,
    'inputMethod': inputMethod,
    'createdAt': createdAt.toIso8601String(),
  };

  factory PendingTransaction.fromJson(Map<String, dynamic> json) =>
      PendingTransaction(
        localId: json['localId'] as String,
        type: json['type'] as String,
        amount: (json['amount'] as num).toDouble(),
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        category: json['category'] as String? ?? 'Other',
        inputMethod: json['inputMethod'] as String? ?? 'manual',
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  /// Converts this pending transaction into a [TransactionModel] for
  /// Uses [localId] as the temporary id.
}
