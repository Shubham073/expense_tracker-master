import 'package:flutter/material.dart';
import '../../widgets/category_pie_chart.dart';
import '../../widgets/weekly_bar_chart.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Insights"),
        elevation: 2,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Category Breakdown",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 200, child: CategoryPieChart()),
          const SizedBox(height: 25),

          const Text(
            "Weekly Expenses",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 220, child: WeeklyBarChart()),
        ],
      ),
    );
  }
}
