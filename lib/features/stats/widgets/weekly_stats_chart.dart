import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:namaa/features/stats/view_model/weekly_stats_cubit/weekly_stats_cubit.dart';
import 'package:namaa/features/stats/view_model/weekly_stats_cubit/weekly_stats_state.dart';

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
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFBDA876)),
              ),
            );
          } else if (state is WeeklyStatsError) {
            return Center(
              child: Text(
                state.errorMessage,
                style: TextStyle(color: Color(0xFFD32F2F)),
              ),
            );
          } else if (state is WeeklyStatsLoaded) {
            // Extract all categories used during the week
            final allCategories = <String>{};
            for (final map in state.weekData.values) {
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
                  // Header with week range
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
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _getWeekRangeText(),
                              style: TextStyle(
                                color: Color(0xFF25386A),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  
                  // Chart
                  AspectRatio(
                    aspectRatio: 1.6,
                    child: BarChart(
                      BarChartData(
                        barGroups: List.generate(7, (i) {
                          final dayData = state.weekData[i] ?? {};
                          double start = 0;
                          return BarChartGroupData(
                            x: i,
                            barsSpace: 4,
                            barRods: categories.map((cat) {
                              final y = dayData[cat] ?? 0.0;
                              final color = categoryColors[cat] ?? _generateColor(cat);
                              final bar = BarChartRodData(
                                toY: start + y,
                                fromY: start,
                                color: color,
                                width: 22,
                                borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  color: Colors.grey[200],
                                ),
                              );
                              start += y;
                              return bar;
                            }).toList(),
                          );
                        }),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text(
                                    value.toInt().toString(),
                                    style: TextStyle(
                                      color: Color(0xFF616161),
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                int idx = value.toInt();
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    idx >= 0 && idx < weekDays.length ? weekDays[idx] : '',
                                    style: TextStyle(
                                      color: Color(0xFF25386A),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              },
                              reservedSize: 32,
                            ),
                          ),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 1,
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
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            // tooltipBgColor: Colors.white,
                            tooltipPadding: EdgeInsets.all(8),
                            tooltipMargin: 8,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final category = categories[rodIndex];
                              final amount = rod.toY - rod.fromY;
                              return BarTooltipItem(
                                '$category\n${amount.toStringAsFixed(2)} ريال',
                                TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  
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

  String _getWeekRangeText() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    final startMonth = _getArabicMonth(startOfWeek.month);
    final endMonth = _getArabicMonth(endOfWeek.month);
    
    if (startOfWeek.month == endOfWeek.month) {
      return "إحصائيات الأسبوع: ${startOfWeek.day} - ${endOfWeek.day} $startMonth";
    } else {
      return "إحصائيات الأسبوع: ${startOfWeek.day} $startMonth - ${endOfWeek.day} $endMonth";
    }
  }

  String _getArabicMonth(int month) {
    const months = [
      "", "يناير", "فبراير", "مارس", "إبريل", "مايو", "يونيو",
      "يوليو", "أغسطس", "سبتمبر", "أكتوبر", "نوفمبر", "ديسمبر"
    ];
    return months[month];
  }

  Color _generateColor(String category) {
    // Generate a consistent color based on category name
    final hash = category.hashCode;
    return Color(hash & 0xFFFFFF).withOpacity(1.0).withBlue(150);
  }
}