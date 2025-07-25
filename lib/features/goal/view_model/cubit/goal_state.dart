
// goal_state.dart
part of 'goal_cubit.dart';

abstract class GoalState {}

class GoalInitial extends GoalState {}

class GoalLoading extends GoalState {}

class GoalSubmitted extends GoalState {
  final GoalModel goal;

  GoalSubmitted(this.goal);
}

class GoalError extends GoalState {
  final String message;

  GoalError(this.message);
}