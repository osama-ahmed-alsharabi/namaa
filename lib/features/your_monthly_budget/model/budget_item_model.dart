import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetItemModel {
  final String id;
  final String category;
  final double amount;
  final DateTime createdAt;

  BudgetItemModel({
    required this.id,
    required this.category,
    required this.amount,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'amount': amount,
      'createdAt': createdAt, // Firestore will auto-convert DateTime to Timestamp
    };
  }

  factory BudgetItemModel.fromMap(String id, Map<String, dynamic> map) {
    return BudgetItemModel(
      id: id,
      category: map['category'] ?? '',
      amount: (map['amount'] as num).toDouble(),
      createdAt: _parseDateTime(map['createdAt']),
    );
  }

  static DateTime _parseDateTime(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is String) {
      return DateTime.parse(timestamp);
    } else {
      return DateTime.now();
    }
  }
}