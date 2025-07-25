// features/your_monthly_budget/cubit/budget_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:namaa/features/your_monthly_budget/model/budget_item_model.dart';
import 'package:namaa/features/your_monthly_budget/view_model/cubit/monthly_budget_state.dart';

class BudgetCubit extends Cubit<BudgetState> {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  BudgetCubit({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        super(BudgetInitial());

  Stream<List<BudgetItemModel>> getBudgetItems() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('monthly_budget')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BudgetItemModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> addBudgetItem(String category, double amount) async {
  emit(BudgetLoading());
  try {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      emit(BudgetError('User not authenticated'));
      return;
    }

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('monthly_budget')
        .add({
          'category': category,
          'amount': amount,
          'createdAt': FieldValue.serverTimestamp(), // Use server timestamp
        });

    emit(BudgetSuccess('Budget item added successfully'));
  } catch (e) {
    emit(BudgetError(e.toString()));
  }
}

  Future<void> updateBudgetItem(String id, double newAmount) async {
    emit(BudgetLoading());
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        emit(BudgetError('User not authenticated'));
        return;
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('monthly_budget')
          .doc(id)
          .update({'amount': newAmount});

      emit(BudgetSuccess('Budget item updated successfully'));
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> deleteBudgetItem(String id) async {
    emit(BudgetLoading());
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        emit(BudgetError('User not authenticated'));
        return;
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('monthly_budget')
          .doc(id)
          .delete();

      emit(BudgetSuccess('Budget item deleted successfully'));
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }
}
