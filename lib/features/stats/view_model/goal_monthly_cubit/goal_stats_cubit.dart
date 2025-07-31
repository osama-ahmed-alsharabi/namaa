import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:namaa/features/stats/view_model/goal_monthly_cubit/goal_stats_state.dart';

class GoalMonthlyCubit extends Cubit<GoalMonthlyState> {
  final String userIdOfApp;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  GoalMonthlyCubit({required this.userIdOfApp}) : super(GoalMonthlyInitial());

  Future<void> fetchGoalMonthly() async {
    emit(GoalMonthlyLoading());
    try {
      // 1. Get monthly savings goal from monthly_budget (الادخار category)
      final monthlyBudgetSnap = await _firestore
          .collection('users')
          .doc(userIdOfApp)
          .collection('monthly_budget')
          .where('category', isEqualTo: 'الادخار')
          .get();

      double monthlySavingsGoal = 0;
      if (monthlyBudgetSnap.docs.isNotEmpty) {
        // Sum all savings goals (though typically there should be just one)
        for (var doc in monthlyBudgetSnap.docs) {
          monthlySavingsGoal += (doc.data()['amount'] as num?)?.toDouble() ?? 0;
        }
      }

      // 2. Get actual savings from daily_results
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final dailyResultsSnap = await _firestore
          .collection('users')
          .doc(userIdOfApp)
          .collection('daily_results')
          .where('date', isGreaterThanOrEqualTo: startOfMonth)
          .where('date', isLessThanOrEqualTo: endOfMonth)
          .get();

      double totalSavedFromDaily = 0;
      for (var doc in dailyResultsSnap.docs) {
        final answers = doc.data()['answers'] as Map<String, dynamic>? ?? {};
        if (answers.containsKey('الادخار')) {
          totalSavedFromDaily += (answers['الادخار'] as num).toDouble();
        }
      }

      // 3. Calculate remaining and percentage
      final remaining = (monthlySavingsGoal - totalSavedFromDaily).clamp(0, monthlySavingsGoal);
      final percent = monthlySavingsGoal > 0 
          ? (totalSavedFromDaily / monthlySavingsGoal).clamp(0, 1) 
          : 0.0;

      emit(GoalMonthlyLoaded(
        monthlySavingsGoal: monthlySavingsGoal,
        totalSavedFromDaily: totalSavedFromDaily,
        remaining: remaining.toDouble(),
        percent: percent.toDouble(),
      ));
    } catch (e) {
      emit(GoalMonthlyError('خطأ في جلب بيانات الادخار: $e'));
    }
  }
}