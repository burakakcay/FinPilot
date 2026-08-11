enum TransactionType { income, expense }

class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note,
  });

  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final String category;
  final DateTime date;
  final String? note;

  TransactionModel copyWith({
    String? id,
    String? title,
    double? amount,
    TransactionType? type,
    String? category,
    DateTime? date,
    String? note,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
}

class TransactionCategories {
  static const List<String> income = [
    'Maaş',
    'Ek Gelir',
    'Yatırım Geliri',
    'Diğer',
  ];

  static const List<String> expense = [
    'Market',
    'Fatura',
    'Ulaşım',
    'Sağlık',
    'Eğitim',
    'Eğlence',
    'Yemek',
    'Kira',
    'Diğer',
  ];

  static List<String> forType(TransactionType type) {
    return type == TransactionType.income ? income : expense;
  }
}
