// monthly_stats_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

part 'monthly_stats_state.dart';

class MonthlyStatsCubit extends Cubit<MonthlyStatsState> {
  final String userIdOfApp;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  MonthlyStatsCubit({required this.userIdOfApp}) : super(MonthlyStatsInitial());

  Future<void> fetchMonthlyStats() async {
    emit(MonthlyStatsLoading());
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final budgetSnap = await _firestore
          .collection('users')
          .doc(userIdOfApp)
          .collection('monthly_budget')
          .where('createdAt', isGreaterThanOrEqualTo: startOfMonth)
          .where('createdAt', isLessThanOrEqualTo: endOfMonth)
          .get();

      // الأسبوع 1 = الأيام 1-7، 2=8-14، 3=15-21، 4=22-نهاية الشهر
      Map<int, Map<String, double>> monthData = {1:{},2:{},3:{},4:{}};
      for (var doc in budgetSnap.docs) {
        final data = doc.data();
        final category = data['category'] ?? 'غير مصنّف';
        final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
        final createdAt = (data['createdAt'] as Timestamp).toDate();
        final day = createdAt.day;
        int weekNum = ((day - 1) ~/ 7) + 1; // 1 إلى 4
        weekNum = weekNum.clamp(1, 4);
        monthData[weekNum]![category] = (monthData[weekNum]![category] ?? 0) + amount;
      }

      emit(MonthlyStatsLoaded(monthData: monthData));
    } catch (e) {
      emit(MonthlyStatsError('خطأ في جلب بيانات الشهر: $e'));
    }
  }
}
