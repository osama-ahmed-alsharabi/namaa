import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:namaa/features/stats/view_model/yearly_stats_cubit/yearly_stats_cubit.dart';

// نفس الألوان السابقة
const categoryColors = {
  "ادخار": Color(0xFFD9E67C),
  "الصحة": Color(0xFFF080B5),
  "الترفيه": Color(0xFF6F8A56),
  "طعام": Color(0xFFB39C6A),
};

const arabicMonths = [
  "يناير", "فبراير", "مارس", "إبريل", "مايو", "يونيو",
  "يوليو", "أغسطس", "سبتمبر", "أكتوبر", "نوفمبر", "ديسمبر"
];

class YearlyStatsChart extends StatelessWidget {
  final String userIdOfApp;
  const YearlyStatsChart({super.key, required this.userIdOfApp});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => YearlyStatsCubit(userIdOfApp: userIdOfApp)..fetchYearlyStats(),
      child: BlocBuilder<YearlyStatsCubit, YearlyStatsState>(
        builder: (context, state) {
          if (state is YearlyStatsLoading || state is YearlyStatsInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is YearlyStatsError) {
            return Center(child: Text(state.message));
          } else if (state is YearlyStatsLoaded) {
            // استخراج كل الفئات المستخدمة
            final allCategories = <String>{};
            for (final map in state.yearData.values) {
              allCategories.addAll(map.keys);
            }
            final categories = allCategories.toList();

            return Column(
              children: [
                const SizedBox(height: 8),
                // العنوان الذهبي
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 26),
                    decoration: BoxDecoration(
                      color: Color(0xFFBDA876),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "${DateTime.now().year}",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                AspectRatio(
                  aspectRatio: 1.4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                    child: LineChart(
                      LineChartData(
                        minY: 0,
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                int idx = value.toInt();
                                return Text(
                                  idx >= 0 && idx < 12 ? arabicMonths[idx] : '',
                                  style: const TextStyle(fontSize: 11),
                                );
                              },
                              reservedSize: 32,
                              interval: 1,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true, reservedSize: 38),
                          ),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(show: true),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          for (final cat in categories)
                            LineChartBarData(
                              isCurved: false,
                              color: categoryColors[cat] ?? Colors.grey,
                              barWidth: 3,
                              spots: List.generate(12, (i) {
                                final monthData = state.yearData[i + 1] ?? {};
                                final y = monthData[cat] ?? 0.0;
                                return FlSpot(i.toDouble(), y);
                              }),
                              dotData: FlDotData(show: true),
                            )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Legend
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: categories.map((cat) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 3,
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
