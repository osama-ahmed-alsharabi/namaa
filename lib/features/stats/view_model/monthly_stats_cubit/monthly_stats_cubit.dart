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

      final dailyResultsSnap = await _firestore
          .collection('users')
          .doc(userIdOfApp)
          .collection('daily_results')
          .where('date', isGreaterThanOrEqualTo: startOfMonth)
          .where('date', isLessThanOrEqualTo: endOfMonth)
          .get();

      // Week 1 = Days 1-7, Week 2=8-14, Week 3=15-21, Week 4=22-end of month
      Map<int, Map<String, double>> monthData = {1: {}, 2: {}, 3: {}, 4: {}};
      
      for (var doc in dailyResultsSnap.docs) {
        final data = doc.data();
        final answers = data['answers'] as Map<String, dynamic>? ?? {};
        final date = (data['date'] as Timestamp).toDate();
        final day = date.day;
        
        int weekNum = ((day - 1) ~/ 7) + 1; // 1 to 4
        weekNum = weekNum.clamp(1, 4);
        
        answers.forEach((category, value) {
          double amount = (value as num).toDouble();
          monthData[weekNum]![category] = (monthData[weekNum]![category] ?? 0) + amount;
        });
      }

      emit(MonthlyStatsLoaded(monthData: monthData));
    } catch (e) {
      emit(MonthlyStatsError('خطأ في جلب بيانات الشهر: $e'));
    }
  }
}