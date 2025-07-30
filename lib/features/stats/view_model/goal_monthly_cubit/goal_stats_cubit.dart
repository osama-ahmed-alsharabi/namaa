// goal_monthly_cubit.dart
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
      // جلب آخر هدف
      final goalsSnap = await _firestore
          .collection('users')
          .doc(userIdOfApp)
          .collection('goals')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (goalsSnap.docs.isEmpty) {
        emit(GoalMonthlyError('لا يوجد هدف.'));
        return;
      }

      final goal = goalsSnap.docs.first.data();
      final double monthlyIncome = (goal['monthlyIncome'] as num?)?.toDouble() ?? 0;
      final String goalDescription = goal['goalDescription'] ?? '';

      // حساب مجموع الادخار لهذا الشهر
      DateTime now = DateTime.now();
      DateTime monthStart = DateTime(now.year, now.month, 1);

      final savingsSnap = await _firestore
          .collection('users')
          .doc(userIdOfApp)
          .collection('monthly_budget')
          .where('category', isEqualTo: 'الادخار')
          .where('createdAt', isGreaterThanOrEqualTo: monthStart)
          .get();

      double totalSaved = 0;
      for (var doc in savingsSnap.docs) {
        final amount = (doc['amount'] as num?)?.toDouble() ?? 0;
        totalSaved += amount;
      }

      final remaining = (monthlyIncome - totalSaved).clamp(0, monthlyIncome);
      final percent = monthlyIncome > 0 ? (totalSaved / monthlyIncome).clamp(0, 1) : 0.0;

      emit(GoalMonthlyLoaded(
        monthlyIncome: monthlyIncome,
        totalSaved: totalSaved,
        remaining: remaining,
        percent: percent,
        goalDescription: goalDescription,
      ));
    } catch (e) {
      emit(GoalMonthlyError('خطأ في التحليل: $e'));
    }
  }
}
