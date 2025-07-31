import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:namaa/features/stats/view_model/weekly_stats_cubit/weekly_stats_state.dart';

class WeeklyStatsCubit extends Cubit<WeeklyStatsState> {
  final String userIdOfApp;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  WeeklyStatsCubit({required this.userIdOfApp}) : super(WeeklyStatsInitial());

  Future<void> fetchWeeklyStats() async {
    emit(WeeklyStatsLoading());
    try {
      final now = DateTime.now();
      // بداية الأسبوع (من السبت)
      final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));

      final dailyResultsSnap = await _firestore
          .collection('users')
          .doc(userIdOfApp)
          .collection('daily_results')
          .where('date', isGreaterThanOrEqualTo: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day))
          .where('date', isLessThanOrEqualTo: DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59))
          .get();

      // جمع البيانات حسب الأيام والفئات
      Map<int, Map<String, double>> weekData = {}; // 0=السبت ... 6=الجمعة
      
      for (var doc in dailyResultsSnap.docs) {
        final data = doc.data();
        final answers = data['answers'] as Map<String, dynamic>? ?? {};
        final date = (data['date'] as Timestamp).toDate();
        
        final weekday = (date.weekday % 7); // 0=السبت، 1=الأحد ...
        
        weekData.putIfAbsent(weekday, () => {});
        
        answers.forEach((category, value) {
          double amount = (value as num).toDouble();
          weekData[weekday]![category] = (weekData[weekday]![category] ?? 0) + amount;
        });
      }

      emit(WeeklyStatsLoaded(weekData: weekData));
    } catch (e) {
      emit(WeeklyStatsError('خطأ في جلب بيانات الأسبوع: $e'));
    }
  }
}