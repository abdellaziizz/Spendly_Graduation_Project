/// Represents the detected intent of a voice transaction.
enum TransactionIntent { expense, income, unknown }

/// A single parsed transaction extracted from a voice input segment.
class ParsedTransaction {
  final String title;
  final String description;
  final String category;
  final double amount;
  final TransactionIntent intent;

  const ParsedTransaction({
    required this.title,
    required this.description,
    required this.category,
    required this.amount,
    required this.intent,
  });

  bool get isIncome => intent == TransactionIntent.income;
  String get intentString => isIncome ? 'income' : 'expense';

  @override
  String toString() =>
      'ParsedTransaction(title: $title, category: $category, '
      'amount: $amount, intent: $intent)';
}

/// The full result of parsing a voice input, possibly containing
/// multiple ParsedTransactions.
class VoiceParseResult {
  final List<ParsedTransaction> transactions;
  final String rawText;

  const VoiceParseResult({required this.transactions, required this.rawText});

  bool get isMultiple => transactions.length > 1;
  bool get isEmpty => transactions.isEmpty;

  /// Sum of all detected transaction amounts.
  double get totalAmount => transactions.fold(0.0, (sum, t) => sum + t.amount);

  /// Dominant intent: unanimous type wins; mixed → unknown.
  TransactionIntent get dominantIntent {
    if (transactions.isEmpty) return TransactionIntent.unknown;
    final first = transactions.first.intent;
    return transactions.every((t) => t.intent == first)
        ? first
        : TransactionIntent.unknown;
  }
}
