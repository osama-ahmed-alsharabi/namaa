import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:namaa/features/stats/widgets/goal_progress_widget.dart';
import 'package:namaa/features/stats/widgets/monthly_stats_chart.dart';
import 'package:namaa/features/stats/widgets/weekly_stats_chart.dart';
import 'package:namaa/features/stats/widgets/yearly_stats_chart.dart';

class StatsScreen extends StatefulWidget {
  final String userIdOfApp;
  const StatsScreen({super.key, required this.userIdOfApp});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  Map<String, double> monthlyBudget = {};
  Map<String, double> todayBudget = {};
  Map<String, dynamic>? goal;
  double totalSaved = 0;
  double totalGoal = 1;
  double progress = 0;

  // متغير الحالة للفترة المختارة
  String selectedPeriod = 'يوم';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    // جلب بيانات الميزانية الشهرية
    final monthlySnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userIdOfApp)
        .collection('monthly_budget')
        .get();

    final Map<String, double> mBudget = {};
    final Map<String, double> tBudget = {};
    DateTime today = DateTime.now();
    for (var doc in monthlySnap.docs) {
      final data = doc.data();
      final category = data['category'] ?? 'غير مصنّف';
      final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
      mBudget[category] = (mBudget[category] ?? 0) + amount;

      // إحصائيات اليوم فقط
      if (data['createdAt'] != null) {
        DateTime createdAt = (data['createdAt'] as Timestamp).toDate();
        if (createdAt.year == today.year &&
            createdAt.month == today.month &&
            createdAt.day == today.day) {
          tBudget[category] = (tBudget[category] ?? 0) + amount;
        }
      }
    }

    // جلب بيانات الأهداف
    final goalsSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userIdOfApp)
        .collection('goals')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    Map<String, dynamic>? goalData;
    double _totalSaved = 0, _totalGoal = 1, _progress = 0;
    if (goalsSnap.docs.isNotEmpty) {
      goalData = goalsSnap.docs.first.data();
      _totalGoal = (goalData['targetAmount'] as num?)?.toDouble() ?? 1;
      _totalSaved = (goalData['savedAmount'] as num?)?.toDouble() ?? 0;
      _progress = (_totalSaved / _totalGoal).clamp(0, 1);
    }

    setState(() {
      monthlyBudget = mBudget;
      todayBudget = tBudget;
      goal = goalData;
      totalSaved = _totalSaved;
      totalGoal = _totalGoal;
      progress = _progress;
    });
  }

  // ألوان ثابتة لكل فئة
  final List<Color> chartColors = [
    Color(0xFFD9E67C), // ادخار
    Color(0xFFF080B5), // صحة
    Color(0xFF6F8A56), // ترفيه
    Color(0xFFB39C6A), // طعام
    Colors.orange,
    Colors.cyan,
    Colors.blue,
    Colors.red,
    Colors.teal,
    Colors.pink,
  ];

  Widget buildLegend(Map<String, double> data) {
    final entries = data.entries.toList();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(entries.length, (i) {
        return Row(
          children: [
            Container(
              width: 12,
              height: 12,
              color: chartColors[i % chartColors.length],
            ),
            const SizedBox(width: 4),
            Text(entries[i].key, style: const TextStyle(fontSize: 13)),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFFEF9),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // العنوان والتبويبات
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'الإحصائيات',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF25386A),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_forward_ios),
                  color: Colors.black,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ['يوم', 'أسبوع', 'شهر', 'سنة'].map((t) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        selectedPeriod = t;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: const BorderSide(color: Color(0xFF25386A)),
                      backgroundColor: selectedPeriod == t ? Color(0xFF25386A).withOpacity(0.1) : Colors.white,
                    ),
                    child: Text(
                      t,
                      style: TextStyle(
                        color: Color(0xFF25386A),
                        fontWeight: selectedPeriod == t ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // "خطتك المالية" + PieChart
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFBDA876),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  "خطتك المالية",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
            AspectRatio(
              aspectRatio: 1.2,
              child: PieChart(
                PieChartData(
                  sections: List.generate(monthlyBudget.length, (i) {
                    final entry = monthlyBudget.entries.toList()[i];
                    return PieChartSectionData(
                      value: entry.value,
                      color: chartColors[i % chartColors.length],
                      title: "",
                      radius: 60,
                    );
                  }),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            buildLegend(monthlyBudget),
            // هدفك الادخاري (حسب التصميم)
            const SizedBox(height: 20),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFBDA876),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text("هدفك الادخاري", style: TextStyle(color: Colors.white)),
              ),
            ),
            GoalMonthlyWidget(userIdOfApp: widget.userIdOfApp),
            const SizedBox(height: 16),

            // التبديل بين الاحصائيات حسب الفترة المختارة
            if (selectedPeriod == 'يوم' && todayBudget.isNotEmpty)
              ...[
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 18,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "${DateTime.now().day} يوليو ${DateTime.now().year} (اليومي)",
                      style: const TextStyle(color: Color(0xFF25386A)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                AspectRatio(
                  aspectRatio: 1.3,
                  child: PieChart(
                    PieChartData(
                      sections: List.generate(todayBudget.length, (i) {
                        final entry = todayBudget.entries.toList()[i];
                        return PieChartSectionData(
                          value: entry.value,
                          color: chartColors[i % chartColors.length],
                          title: "",
                          radius: 60,
                        );
                      }),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
                buildLegend(todayBudget),
              ]
            else if (selectedPeriod == 'أسبوع')
              WeeklyStatsChart(userIdOfApp: widget.userIdOfApp)
            else if (selectedPeriod == 'شهر')
              MonthlyStatsChart(userIdOfApp: widget.userIdOfApp)
            else if (selectedPeriod == 'سنة')
              YearlyStatsChart(userIdOfApp: widget.userIdOfApp),

            
          ],
        ),
      ),
    );
  }
}
