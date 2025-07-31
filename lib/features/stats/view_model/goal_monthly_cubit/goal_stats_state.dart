
abstract class GoalMonthlyState {}

class GoalMonthlyInitial extends GoalMonthlyState {}

class GoalMonthlyLoading extends GoalMonthlyState {}

class GoalMonthlyLoaded extends GoalMonthlyState {
  final double monthlySavingsGoal;
  final double totalSavedFromDaily;
  final double remaining;
  final double percent;

  GoalMonthlyLoaded({
    required this.monthlySavingsGoal,
    required this.totalSavedFromDaily,
    required this.remaining,
    required this.percent,
  });
}

class GoalMonthlyError extends GoalMonthlyState {
  final String message;
  GoalMonthlyError(this.message);
}