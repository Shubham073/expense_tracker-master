import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';
import '../core/theme/app_colors.dart';

class WeeklyBarChart extends StatelessWidget {
  final List? expenses;
  const WeeklyBarChart({super.key, this.expenses});

  @override
  Widget build(BuildContext context) {
    final exp = expenses ?? Provider.of<ExpenseProvider>(context).expenses;

    // Weekly totals
    final List<double> weekly = List.filled(7, 0);
    final now = DateTime.now();

    for (var e in exp) {
      final diff = now.difference(e.date).inDays;
      if (diff < 7) {
        weekly[6 - diff] += e.amount;
      }
    }

    return BarChart(
      BarChartData(
        barGroups: List.generate(7, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: weekly[i],
                color: AppColors.primary,
                width: 16,
                borderRadius: BorderRadius.circular(6),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: weekly.reduce((a, b) => a > b ? a : b),
                  color: Colors.grey[200],
                ),
              )
            ],
            showingTooltipIndicators: [0],
          );
        }),
        titlesData: FlTitlesData(
          leftTitles:
              AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = ["M", "T", "W", "T", "F", "S", "S"];
                return Text(days[value.toInt()]);
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.black87,
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              const days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
              return BarTooltipItem(
                '${days[groupIndex]}\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                children: [
                  TextSpan(
                    text: '₹${rod.toY.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.yellowAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
