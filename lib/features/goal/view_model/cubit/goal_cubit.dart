// features/your_monthly_budget/cubit/goal_cubit.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:namaa/features/goal/model/goal_model.dart';
import 'package:namaa/main.dart';

part 'goal_state.dart';

class GoalCubit extends Cubit<GoalState> {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  GoalCubit({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        super(GoalInitial());

  Future<void> submitGoal({
    required String goalDescription,
    required double monthlyIncome,
    required double dailyExpense,
  }) async {
    emit(GoalLoading());
    try {
      final userId = userIdOfApp;
      if (userId == null) {
        emit(GoalError('User not authenticated'));
        return;
      }

      final goal = GoalModel(
        goalDescription: goalDescription,
        monthlyIncome: monthlyIncome,
        dailyExpense: dailyExpense,
        userId: userId,
        createdAt: DateTime.now(),
      );

      // Add goal to user's goals subcollection
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('goals')
          .add(goal.toMap());

      emit(GoalSubmitted(goal));
    } catch (e) {
      emit(GoalError(e.toString()));
    }
  }
}
