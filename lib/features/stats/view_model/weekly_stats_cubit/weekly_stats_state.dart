abstract class WeeklyStatsState {}

final class WeeklyStatsInitial extends WeeklyStatsState {}

final class WeeklyStatsLoading extends WeeklyStatsState {}

final class WeeklyStatsLoaded extends WeeklyStatsState {
  Map<int, Map<String, double>> weekData;
  WeeklyStatsLoaded({required this.weekData});
}

final class WeeklyStatsError extends WeeklyStatsState {
  final String errorMessage;

  WeeklyStatsError(this.errorMessage);
}
