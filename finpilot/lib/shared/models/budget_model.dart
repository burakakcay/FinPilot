import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetModel {
  final String id;
  final String category;
  final double limit;
  final DateTime month;

  const BudgetModel({
    required this.id,
    required this.category,
    required this.limit,
    required this.month,
  });

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'limit': limit,
      'month': Timestamp.fromDate(month),
    };
  }

  factory BudgetModel.fromMap({
    required String id,
    required Map<String, dynamic> map,
  }) {
    return BudgetModel(
      id: id,
      category: map['category'] as String,
      limit: (map['limit'] as num).toDouble(),
      month: (map['month'] as Timestamp).toDate(),
    );
  }
}
