// yearly_stats_state.dart
part of 'yearly_stats_cubit.dart';

@immutable
abstract class YearlyStatsState {}

class YearlyStatsInitial extends YearlyStatsState {}
class YearlyStatsLoading extends YearlyStatsState {}

class YearlyStatsLoaded extends YearlyStatsState {
  final Map<int, Map<String, double>> yearData;
  YearlyStatsLoaded({required this.yearData});
}

class YearlyStatsError extends YearlyStatsState {
  final String message;
  YearlyStatsError(this.message);
}
