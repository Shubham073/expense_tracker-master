import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';
import '../core/theme/app_colors.dart';

class CategoryPieChart extends StatefulWidget {
  final List? expenses;
  const CategoryPieChart({super.key, this.expenses});

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final exp = widget.expenses ?? Provider.of<ExpenseProvider>(context).expenses;

    // total by category
    final Map<String, double> map = {};
    double total = 0;

    for (var e in exp) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
      total += e.amount;
    }

    final sections = <PieChartSectionData>[];

    int colorIndex = 0;
    map.forEach((category, amount) {
      final isTouched = sections.length == touchedIndex;
      final double fontSize = isTouched ? 16 : 12;
      final double radius = isTouched ? 70 : 60;
      final percentage = (amount / total * 100).toStringAsFixed(1);

      sections.add(
        PieChartSectionData(
          radius: radius,
          color: AppColors.chartColors[colorIndex % AppColors.chartColors.length],
          value: amount,
          title: isTouched ? '$category\n₹${amount.toStringAsFixed(0)}\n($percentage%)' : category,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: const [Shadow(color: Colors.black26, blurRadius: 2)],
          ),
        ),
      );
      colorIndex++;
    });

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: sections,
        pieTouchData: PieTouchData(
          enabled: true,
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  pieTouchResponse == null ||
                  pieTouchResponse.touchedSection == null) {
                touchedIndex = -1;
                return;
              }
              touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
            });
          },
        ),
      ),
    );
  }
}
