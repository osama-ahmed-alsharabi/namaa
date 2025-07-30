// weekly_stats_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

part 'weekly_stats_state.dart';

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

      final budgetSnap = await _firestore
          .collection('users')
          .doc(userIdOfApp)
          .collection('monthly_budget')
          .where('createdAt', isGreaterThanOrEqualTo: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day))
          .where('createdAt', isLessThanOrEqualTo: DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59))
          .get();

      // جمع البيانات حسب الأيام والفئات
      Map<int, Map<String, double>> weekData = {}; // 0=السبت ... 6=الجمعة
      for (var doc in budgetSnap.docs) {
        final data = doc.data();
        final category = data['category'] ?? 'غير مصنّف';
        final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
        final createdAt = (data['createdAt'] as Timestamp).toDate();

        final weekday = (createdAt.weekday % 7); // 0=السبت، 1=الأحد ...
        weekData.putIfAbsent(weekday, () => {});
        weekData[weekday]![category] = (weekData[weekday]![category] ?? 0) + amount;
      }

      emit(WeeklyStatsLoaded(weekData: weekData));
    } catch (e) {
      emit(WeeklyStatsError('خطأ في جلب بيانات الأسبوع: $e'));
    }
  }
}
