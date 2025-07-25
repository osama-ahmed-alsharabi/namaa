// features/your_monthly_budget/models/goal_model.dart
class GoalModel {
  final String goalDescription;
  final double monthlyIncome;
  final double dailyExpense;
  final String userId;
  final DateTime createdAt;

  GoalModel({
    required this.goalDescription,
    required this.monthlyIncome,
    required this.dailyExpense,
    required this.userId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'goalDescription': goalDescription,
      'monthlyIncome': monthlyIncome,
      'dailyExpense': dailyExpense,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory GoalModel.fromMap(Map<String, dynamic> map) {
    return GoalModel(
      goalDescription: map['goalDescription'] ?? '',
      monthlyIncome: (map['monthlyIncome'] as num).toDouble(),
      dailyExpense: (map['dailyExpense'] as num).toDouble(),
      userId: map['userId'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}