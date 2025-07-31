import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:namaa/features/stats/view_model/yearly_stats_cubit/yearly_stats_cubit.dart';

// Modern color palette
const categoryColors = {
  "ادخار": Color(0xFF4CAF50),  // Green
  "الصحة": Color(0xFF2196F3),  // Blue
  "الترفيه": Color(0xFF9C27B0), // Purple
  "طعام": Color(0xFFFF9800),    // Orange
  "مواصلات": Color(0xFF607D8B), // Blue Grey
  "تسوق": Color(0xFFE91E63),    // Pink
  "فواتير": Color(0xFF795548),  // Brown
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
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFBDA876)),
              ),
            );
          } else if (state is YearlyStatsError) {
            return Center(
              child: Text(
                state.message,
                style: TextStyle(color: Color(0xFFD32F2F)),
              ),
            );
          } else if (state is YearlyStatsLoaded) {
            // Extract all categories used during the year
            final allCategories = <String>{};
            for (final map in state.yearData.values) {
              allCategories.addAll(map.keys);
            }
            final categories = allCategories.toList();

            return Container(
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
                  // Header with year
                  Container(
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
                          "إحصائيات سنة ${DateTime.now().year}",
                          style: TextStyle(
                            color: Color(0xFF25386A),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  
                  // Chart
                  AspectRatio(
                    aspectRatio: 1.4,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: LineChart(
                        LineChartData(
                          minY: 0,
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  int idx = value.toInt();
                                  return Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      idx >= 0 && idx < arabicMonths.length 
                                          ? arabicMonths[idx] 
                                          : '',
                                      style: TextStyle(
                                        color: Color(0xFF25386A),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                },
                                reservedSize: 32,
                                interval: 1,
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Padding(
                                    padding: EdgeInsets.only(right: 8),
                                    child: Text(
                                      value.toInt().toString(),
                                      style: TextStyle(
                                        color: Color(0xFF616161),
                                        fontSize: 11,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: true,
                            drawHorizontalLine: true,
                            getDrawingVerticalLine: (value) => FlLine(
                              color: Colors.grey.withOpacity(0.1),
                              strokeWidth: 1,
                            ),
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: Colors.grey.withOpacity(0.1),
                              strokeWidth: 1,
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.withOpacity(0.2),
                                width: 1,
                              ),
                              left: BorderSide(
                                color: Colors.grey.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                          ),
                          lineBarsData: [
                            for (final cat in categories)
                              LineChartBarData(
                                isCurved: true,
                                curveSmoothness: 0.3,
                                color: categoryColors[cat] ?? _generateColor(cat),
                                barWidth: 3,
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: categoryColors[cat]?.withOpacity(0.1) ?? 
                                      _generateColor(cat).withOpacity(0.1),
                                ),
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter: (spot, percent, barData, index) {
                                    return FlDotCirclePainter(
                                      radius: 4,
                                      color: categoryColors[cat] ?? _generateColor(cat),
                                      strokeWidth: 2,
                                      strokeColor: Colors.white,
                                    );
                                  },
                                ),
                                spots: List.generate(12, (i) {
                                  final monthData = state.yearData[i + 1] ?? {};
                                  final y = monthData[cat] ?? 0.0;
                                  return FlSpot(i.toDouble(), y);
                                })),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Legend
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 8,
                    children: categories.map((cat) {
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
                                color: categoryColors[cat] ?? _generateColor(cat),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 6),
                            Text(
                              cat,
                              style: TextStyle(
                                color: Color(0xFF424242),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Color _generateColor(String category) {
    // Generate a consistent color based on category name
    final hash = category.hashCode;
    return Color(hash & 0xFFFFFF).withOpacity(1.0).withBlue(150);
  }
}