import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:namaa/features/stats/view_model/goal_monthly_cubit/goal_stats_cubit.dart';
import 'package:namaa/features/stats/view_model/goal_monthly_cubit/goal_stats_state.dart';

class GoalMonthlyWidget extends StatelessWidget {
  final String userIdOfApp;
  const GoalMonthlyWidget({super.key, required this.userIdOfApp});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GoalMonthlyCubit(userIdOfApp: userIdOfApp)..fetchGoalMonthly(),
      child: BlocBuilder<GoalMonthlyCubit, GoalMonthlyState>(
        builder: (context, state) {
          if (state is GoalMonthlyLoading || state is GoalMonthlyInitial) {
            return const SizedBox();
          } else if (state is GoalMonthlyError) {
            return Center(child: Text(state.message));
          } else if (state is GoalMonthlyLoaded) {
            return Card(
              elevation: 0,
              color: Colors.white,
              margin: const EdgeInsets.symmetric(vertical: 16),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // عنوان الهدف والمبلغ الكلي
                    Row(
                      children: [
                        const Icon(Icons.track_changes, color: Color(0xFF25386A), size: 28),
                        const SizedBox(width: 8),
                        Text(
                          "الهدف ${state.monthlyIncome.toStringAsFixed(0)} ريال",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 22, color: Color(0xFF25386A)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    // المبلغ المحقق (ادخار)
                    _buildProgressRow(
                      percent: (state.totalSaved / state.monthlyIncome * 100).clamp(0, 100),
                      color: const Color(0xFFD5F790),
                      label: "المبلغ المدخر: ",
                      value: state.totalSaved,
                    ),
                    const SizedBox(height: 12),
                    // المبلغ المتبقي
                    _buildProgressRow(
                      percent: (state.remaining / state.monthlyIncome * 100).clamp(0, 100),
                      color: const Color(0xFFF6A04B),
                      label: "المبلغ المتبقي: ",
                      value: state.remaining.toDouble(),
                    ),
                    const SizedBox(height: 12),
                    // نسبة الإنجاز
                    _buildProgressRow(
                      percent: state.percent * 100,
                      color: Colors.green,
                      label: "نسبة إنجاز",
                      value: state.percent * 100,
                      isPercent: true,
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildProgressRow({
    required double percent,
    required Color color,
    required String label,
    required double value,
    bool isPercent = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (percent / 100).clamp(0.0, 1.0),
              minHeight: 14,
              backgroundColor: Colors.grey[300],
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "%${percent.toStringAsFixed(0)}",
              style: TextStyle(fontSize: 15, color: color, fontWeight: FontWeight.bold),
            ),
            Text(
              isPercent ? label : "$label${value.toStringAsFixed(0)}",
              style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}
