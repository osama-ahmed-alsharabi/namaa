// goal_monthly_state.dart

abstract class GoalMonthlyState {}

class GoalMonthlyInitial extends GoalMonthlyState {}
class GoalMonthlyLoading extends GoalMonthlyState {}

class GoalMonthlyLoaded extends GoalMonthlyState {
  final double monthlyIncome;
  final double totalSaved;
  final num remaining;
  final num percent;
  final String goalDescription;

  GoalMonthlyLoaded({
    required this.monthlyIncome,
    required this.totalSaved,
    required this.remaining,
    required this.percent,
    required this.goalDescription,
  });
}

class GoalMonthlyError extends GoalMonthlyState {
  final String message;
  GoalMonthlyError(this.message);
}
