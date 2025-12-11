import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';
import '../core/theme/app_colors.dart';

class CategoryPieChart extends StatelessWidget {
  const CategoryPieChart({super.key});

  @override
  Widget build(BuildContext context) {
    final exp = Provider.of<ExpenseProvider>(context).expenses;

    // total by category
    final Map<String, double> map = {};

    for (var e in exp) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }

    final sections = <PieChartSectionData>[];

    int colorIndex = 0;
    map.forEach((category, amount) {
      sections.add(
        PieChartSectionData(
          radius: 60,
          color: AppColors.chartColors[colorIndex % AppColors.chartColors.length],
          value: amount,
          title: category,
          titleStyle: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );
      colorIndex++;
    });

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: sections,
      ),
    );
  }
}
