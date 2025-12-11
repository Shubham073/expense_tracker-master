import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';
import '../core/theme/app_colors.dart';

class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    final exp = Provider.of<ExpenseProvider>(context).expenses;

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
              )
            ],
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
      ),
    );
  }
}
