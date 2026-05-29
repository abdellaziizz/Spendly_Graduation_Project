class TransactionModel {
  final String id;
  final String title;
  final String description;
  final double amount;
  final String category;
  final String type; // 'expense' or 'income'
  final DateTime dateTime;
  final bool isPending; // true = offline, not yet synced

  TransactionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.category,
    required this.type,
    required this.dateTime,
    this.isPending = false,
  });

  bool get isIncome => type == 'income';

  TransactionModel copyWith({bool? isPending}) => TransactionModel(
        id: id,
        title: title,
        description: description,
        amount: amount,
        category: category,
        type: type,
        dateTime: dateTime,
        isPending: isPending ?? this.isPending,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'amount': amount,
        'category': category,
        'type': type,
        'dateTime': dateTime.toIso8601String(),
        'isPending': isPending,
      };

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        amount: (json['amount'] as num).toDouble(),
        category: json['category'] as String? ?? '',
        type: json['type'] as String,
        dateTime: DateTime.parse(json['dateTime'] as String),
        isPending: json['isPending'] as bool? ?? false,
      );
}
