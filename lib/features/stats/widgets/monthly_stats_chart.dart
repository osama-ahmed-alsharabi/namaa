import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:namaa/features/stats/view_model/monthly_stats_cubit/monthly_stats_cubit.dart';

const categoryColors = {
  "ادخار": Color(0xFFD9E67C),
  "الصحة": Color(0xFFF080B5),
  "الترفيه": Color(0xFF6F8A56),
  "طعام": Color(0xFFB39C6A),
};

const weeks = ['1', '2', '3', '4'];

class MonthlyStatsChart extends StatelessWidget {
  final String userIdOfApp;
  const MonthlyStatsChart({super.key, required this.userIdOfApp});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MonthlyStatsCubit(userIdOfApp: userIdOfApp)..fetchMonthlyStats(),
      child: BlocBuilder<MonthlyStatsCubit, MonthlyStatsState>(
        builder: (context, state) {
          if (state is MonthlyStatsLoading || state is MonthlyStatsInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MonthlyStatsError) {
            return Center(child: Text(state.message));
          } else if (state is MonthlyStatsLoaded) {
            // كل الفئات المستخدمة فعليًا في الشهر
            final allCategories = <String>{};
            for (final map in state.monthData.values) {
              allCategories.addAll(map.keys);
            }
            final categories = allCategories.toList();

            return Column(
              children: [
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Color(0xFFBDA876),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "${_arabicMonth(DateTime.now().month)} ${DateTime.now().year}",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                AspectRatio(
                  aspectRatio: 1.6,
                  child: BarChart(
                    BarChartData(
                      barGroups: List.generate(4, (weekIdx) {
                        final weekData = state.monthData[weekIdx + 1] ?? {};
                        return BarChartGroupData(
                          x: weekIdx,
                          barRods: categories.map((cat) {
                            final y = weekData[cat] ?? 0.0;
                            final color = categoryColors[cat] ?? Colors.grey;
                            return BarChartRodData(
                              toY: y,
                              color: color,
                              width: 18,
                              borderRadius: BorderRadius.circular(2),
                            );
                          }).toList(),
                        );
                      }),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true, reservedSize: 36),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              int idx = value.toInt();
                              return Text(
                                idx >= 0 && idx < weeks.length ? weeks[idx] : '',
                                style: const TextStyle(fontSize: 13),
                              );
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(show: true),
                      borderData: FlBorderData(show: false),
                      barTouchData: BarTouchData(enabled: true),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                // Legend
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: categories.map((cat) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            color: categoryColors[cat] ?? Colors.grey,
                          ),
                          const SizedBox(width: 5),
                          Text(cat, style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  String _arabicMonth(int month) {
    const months = [
      "", "يناير", "فبراير", "مارس", "إبريل", "مايو", "يونيو",
      "يوليو", "أغسطس", "سبتمبر", "أكتوبر", "نوفمبر", "ديسمبر"
    ];
    return months[month];
  }
}
