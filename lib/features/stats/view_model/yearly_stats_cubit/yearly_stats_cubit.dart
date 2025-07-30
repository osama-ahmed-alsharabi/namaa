// yearly_stats_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

part 'yearly_stats_state.dart';

class YearlyStatsCubit extends Cubit<YearlyStatsState> {
  final String userIdOfApp;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  YearlyStatsCubit({required this.userIdOfApp}) : super(YearlyStatsInitial());

  Future<void> fetchYearlyStats() async {
    emit(YearlyStatsLoading());
    try {
      final now = DateTime.now();
      final startOfYear = DateTime(now.year, 1, 1);
      final endOfYear = DateTime(now.year, 12, 31, 23, 59, 59);

      final budgetSnap = await _firestore
          .collection('users')
          .doc(userIdOfApp)
          .collection('monthly_budget')
          .where('createdAt', isGreaterThanOrEqualTo: startOfYear)
          .where('createdAt', isLessThanOrEqualTo: endOfYear)
          .get();

      // مصفوفة [12][فئة] لكل شهر
      Map<int, Map<String, double>> yearData = {};
      for (int m = 1; m <= 12; m++) {
        yearData[m] = {};
      }

      for (var doc in budgetSnap.docs) {
        final data = doc.data();
        final category = data['category'] ?? 'غير مصنّف';
        final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
        final createdAt = (data['createdAt'] as Timestamp).toDate();
        final month = createdAt.month;
        yearData[month]![category] = (yearData[month]![category] ?? 0) + amount;
      }

      emit(YearlyStatsLoaded(yearData: yearData));
    } catch (e) {
      emit(YearlyStatsError('خطأ في جلب بيانات السنة: $e'));
    }
  }
}
