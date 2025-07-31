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
  Map<String, double> selectedDayBudget = {};
  double monthlyIncomeGoal = 0;
  double totalSavedFromDaily = 0;
  DateTime selectedDate = DateTime.now();
  String selectedPeriod = 'يوم';

  @override
  void initState() {
    super.initState();
    fetchFinancialData();
    fetchDayData(selectedDate); // Fetch data for selected day
  }

  Future<void> fetchDayData(DateTime date) async {
    DateTime startOfDay = DateTime(date.year, date.month, date.day);
    DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final dailySnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userIdOfApp)
        .collection('daily_results')
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .get();

    Map<String, double> dayBudget = {};
    for (var doc in dailySnap.docs) {
      final data = doc.data();
      final answers = data['answers'] as Map<String, dynamic>? ?? {};
      answers.forEach((category, value) {
        double amount = (value as num).toDouble();
        dayBudget[category] = (dayBudget[category] ?? 0) + amount;
      });
    }

    setState(() {
      selectedDayBudget = dayBudget;
    });
  }

  // ... keep the existing fetchData method ...
  // ألوان ثابتة لكل فئة
  final List<Color> chartColors = [
    Color(0xFF4CAF50),  // Green - ادخار
    Color(0xFF2196F3),  // Blue - صحة
    Color(0xFF9C27B0),  // Purple - ترفيه
    Color(0xFFFF9800),  // Orange - طعام
    Color(0xFF607D8B),  // Blue Grey - مواصلات
    Color(0xFFE91E63),  // Pink - تسوق
    Color(0xFF795548),  // Brown - فواتير
  ];

  Widget _buildFinancialRow({
    required String label,
    required double value,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF424242),
          ),
        ),
        Text(
          '${value.toStringAsFixed(2)} ريال',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget buildLegend(Map<String, double> data) {
    final entries = data.entries.toList();
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: List.generate(entries.length, (i) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: chartColors[i % chartColors.length],
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 6),
              Text(
                entries[i].key,
                style: TextStyle(
                  color: Color(0xFF424242),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }


  Future<void> fetchFinancialData() async {
    // Fetch monthly budget allocations
    final monthlySnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userIdOfApp)
        .collection('monthly_budget')
        .get();

    final Map<String, double> budgetMap = {};
    for (var doc in monthlySnap.docs) {
      final data = doc.data();
      final category = data['category'] ?? 'غير مصنّف';
      final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
      budgetMap[category] = (budgetMap[category] ?? 0) + amount;
    }

    // Fetch monthly income goal
    final goalsSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userIdOfApp)
        .collection('goals')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    double incomeGoal = 0;
    if (goalsSnap.docs.isNotEmpty) {
      incomeGoal = (goalsSnap.docs.first.data()['monthlyIncome'] as num?)?.toDouble() ?? 0;
    }

    setState(() {
      monthlyBudget = budgetMap;
      monthlyIncomeGoal = incomeGoal;
    });
  }


  @override
  Widget build(BuildContext context) {
        final totalAllocated = monthlyBudget.values.fold(0.0, (sum, amount) => sum + amount);
    final remainingBudget = (monthlyIncomeGoal - totalAllocated).clamp(0, monthlyIncomeGoal);
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
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back_ios_new_outlined),
                  color: Colors.black,
                ),
                Expanded(
                  child: Center(
                    child: const Text(
                      'الإحصائيات',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF25386A),
                      ),
                    ),
                  ),
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
           
            // "خطتك المالية" section
            Column(
              children: [
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
                const SizedBox(height: 16),
                
                // Income and budget summary
                
                // Budget allocation pie chart
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'توزيع الميزانية',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF25386A),
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      AspectRatio(
                        aspectRatio: 1.2,
                        child: PieChart(
                          PieChartData(
                            sections: List.generate(monthlyBudget.length, (i) {
                              final entry = monthlyBudget.entries.toList()[i];
                              return PieChartSectionData(
                                value: entry.value,
                                color: chartColors[i % chartColors.length],
                                title: '',
                                radius: 60,
                                badgeWidget: Container(
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    '${totalAllocated > 0 ? (entry.value / totalAllocated * 100).toStringAsFixed(1) : 0}%',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                badgePositionPercentageOffset: 0.98,
                              );
                            }),
                            sectionsSpace: 0,
                            centerSpaceRadius: 40,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      buildLegend(monthlyBudget),
                    ],
                  ),
                ),
              ],
            ),
             
            // هدفك الادخاري
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
            GoalMonthlyWidget(
              userIdOfApp: widget.userIdOfApp,
            ),
            const SizedBox(height: 16),

// Replace the day section in your build method with this:
if (selectedPeriod == 'يوم') ...[
  Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 2,
          blurRadius: 8,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      children: [
        // Date selector
        InkWell(
          onTap: () => _selectDate(context),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today, size: 18, color: Color(0xFF25386A)),
                SizedBox(width: 8),
                Text(
                  "${selectedDate.day} ${_getArabicMonth(selectedDate.month)} ${selectedDate.year}",
                  style: TextStyle(
                    color: Color(0xFF25386A),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (isSameDay(selectedDate, DateTime.now()))
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text(
                      '(اليوم)',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        SizedBox(height: 24),
        
        if (selectedDayBudget.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                Icon(Icons.insert_chart, size: 48, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  'لا توجد بيانات لهذا اليوم',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          )
        else ...[
          // Pie Chart
          AspectRatio(
            aspectRatio: 1.3,
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 40,
                sections: List.generate(selectedDayBudget.length, (i) {
                  final entry = selectedDayBudget.entries.toList()[i];
                  final total = selectedDayBudget.values.reduce((a, b) => a + b);
                  return PieChartSectionData(
                    value: entry.value,
                    color: chartColors[i % chartColors.length],
                    title: '',
                    radius: 60,
                    badgeWidget: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),)
                        ],
                      ),
                      child: Text(
                        '${total > 0 ? (entry.value / total * 100).toStringAsFixed(1) : 0}%',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    badgePositionPercentageOffset: 0.98,
                  );
                }),
              ),
            ),
          ),
          SizedBox(height: 16),
          
          // Total amount
          Text(
            'الإجمالي: ${selectedDayBudget.values.reduce((a, b) => a + b).toStringAsFixed(2)} ريال',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF25386A),
            ),
          ),
          SizedBox(height: 16),
          
          // Detailed breakdown
          ...selectedDayBudget.entries.map((entry) {
            final total = selectedDayBudget.values.reduce((a, b) => a + b);
            final percentage = total > 0 ? (entry.value / total * 100) : 0;
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    color: chartColors[selectedDayBudget.keys.toList().indexOf(entry.key) % chartColors.length],
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        color: Color(0xFF424242),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    '${entry.value.toStringAsFixed(2)} ريال',
                    style: TextStyle(
                      color: Color(0xFF25386A),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ],
    ),
  ),
]
else if (selectedPeriod == 'أسبوع')
  WeeklyStatsChart(userIdOfApp: widget.userIdOfApp)
else if (selectedPeriod == 'شهر')
  MonthlyStatsChart(userIdOfApp: widget.userIdOfApp)
else if (selectedPeriod == 'سنة')
  YearlyStatsChart(userIdOfApp: widget.userIdOfApp),          ],
        ),
      ),
    );
  }

Future<void> _selectDate(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: selectedDate,
    firstDate: DateTime(2020),
    lastDate: DateTime.now(),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Color(0xFFBDA876),
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              // primary: Color(0xFFBDA876),
            ),
          ),
        ),
        child: child!,
      );
    },
  );

  if (picked != null && picked != selectedDate) {
    setState(() {
      selectedDate = picked;
    });
    fetchDayData(picked);
  }
}

  String _getArabicMonth(int month) {
    const months = [
      "", "يناير", "فبراير", "مارس", "إبريل", "مايو", "يونيو",
      "يوليو", "أغسطس", "سبتمبر", "أكتوبر", "نوفمبر", "ديسمبر"
    ];
    return months[month];
  }


  bool isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
         date1.month == date2.month &&
         date1.day == date2.day;
}
}