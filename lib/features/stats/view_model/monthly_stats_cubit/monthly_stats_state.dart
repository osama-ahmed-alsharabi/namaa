// monthly_stats_state.dart
part of 'monthly_stats_cubit.dart';

@immutable
abstract class MonthlyStatsState {}

class MonthlyStatsInitial extends MonthlyStatsState {}
class MonthlyStatsLoading extends MonthlyStatsState {}

class MonthlyStatsLoaded extends MonthlyStatsState {
  final Map<int, Map<String, double>> monthData;
  MonthlyStatsLoaded({required this.monthData});
}

class MonthlyStatsError extends MonthlyStatsState {
  final String message;
  MonthlyStatsError(this.message);
}
