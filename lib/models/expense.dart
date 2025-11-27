enum TransactionType {
  income('income', 'Receita'),
  expense('expense', 'Despesa');

  final String id;
  final String label;

  const TransactionType(this.id, this.label);
}

class Transaction {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final String category;
  final DateTime date;
  final String? description;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type.id,
      'category': category,
      'date': date.toIso8601String(),
      'description': description,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      type: map['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      category: map['category'],
      date: DateTime.parse(map['date']),
      description: map['description'],
    );
  }

  Transaction copyWith({
    String? id,
    String? title,
    double? amount,
    TransactionType? type,
    String? category,
    DateTime? date,
    String? description,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      description: description ?? this.description,
    );
  }
}
