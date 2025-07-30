// weekly_stats_state.dart
part of 'weekly_stats_cubit.dart';

@immutable
abstract class WeeklyStatsState {}

class WeeklyStatsInitial extends WeeklyStatsState {}
class WeeklyStatsLoading extends WeeklyStatsState {}

class WeeklyStatsLoaded extends WeeklyStatsState {
  final Map<int, Map<String, double>> weekData;
  WeeklyStatsLoaded({required this.weekData});
}

class WeeklyStatsError extends WeeklyStatsState {
  final String message;
  WeeklyStatsError(this.message);
}
