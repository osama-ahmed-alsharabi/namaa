import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:namaa/features/stats/view_model/weekly_stats_cubit/weekly_stats_cubit.dart';

// ثوابت الألوان لكل فئة (ثابتة!)
const categoryColors = {
  "ادخار": Color(0xFFD9E67C),
  "الصحة": Color(0xFFF080B5),
  "الترفيه": Color(0xFF6F8A56),
  "طعام": Color(0xFFB39C6A),
};

const weekDays = ['السبت', 'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'];

class WeeklyStatsChart extends StatelessWidget {
  final String userIdOfApp;
  const WeeklyStatsChart({super.key, required this.userIdOfApp});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WeeklyStatsCubit(userIdOfApp: userIdOfApp)..fetchWeeklyStats(),
      child: BlocBuilder<WeeklyStatsCubit, WeeklyStatsState>(
        builder: (context, state) {
          if (state is WeeklyStatsLoading || state is WeeklyStatsInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is WeeklyStatsError) {
            return Center(child: Text(state.message));
          } else if (state is WeeklyStatsLoaded) {
            // استخراج جميع الفئات المستعملة فعليا خلال الأسبوع
            final allCategories = <String>{};
            for (final map in state.weekData.values) {
              allCategories.addAll(map.keys);
            }
            final categories = allCategories.toList();

            return Column(
              children: [
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Color(0xFFBDA876),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "${DateTime.now().subtract(Duration(days: DateTime.now().weekday % 7)).day} - ${DateTime.now().day} يوليو , ${DateTime.now().year}",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                AspectRatio(
                  aspectRatio: 1.6,
                  child: BarChart(
                    BarChartData(
                      barGroups: List.generate(7, (i) {
                        // كل يوم
                        final dayData = state.weekData[i] ?? {};
                        double start = 0;
                        return BarChartGroupData(
                          x: i,
                          barsSpace: 2,
                          barRods: categories.map((cat) {
                            final y = dayData[cat] ?? 0.0;
                            final color = categoryColors[cat] ?? Colors.grey;
                            final bar = BarChartRodData(
                              toY: start + y,
                              fromY: start,
                              color: color,
                              width: 18,
                              borderRadius: BorderRadius.zero,
                              // rodStackItem: [],
                            );
                            start += y;
                            return bar;
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
                                idx >= 0 && idx < weekDays.length ? weekDays[idx] : '',
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
}
