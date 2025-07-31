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

      final dailyResultsSnap = await _firestore
          .collection('users')
          .doc(userIdOfApp)
          .collection('daily_results')
          .where('date', isGreaterThanOrEqualTo: startOfYear)
          .where('date', isLessThanOrEqualTo: endOfYear)
          .get();

      // Array [12][category] for each month
      Map<int, Map<String, double>> yearData = {};
      for (int m = 1; m <= 12; m++) {
        yearData[m] = {};
      }

      for (var doc in dailyResultsSnap.docs) {
        final data = doc.data();
        final answers = data['answers'] as Map<String, dynamic>? ?? {};
        final date = (data['date'] as Timestamp).toDate();
        final month = date.month;
        
        answers.forEach((category, value) {
          double amount = (value as num).toDouble();
          yearData[month]![category] = (yearData[month]![category] ?? 0) + amount;
        });
      }

      emit(YearlyStatsLoaded(yearData: yearData));
    } catch (e) {
      emit(YearlyStatsError('خطأ في جلب بيانات السنة: $e'));
    }
  }
}