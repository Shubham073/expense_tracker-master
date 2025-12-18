import 'package:flutter/material.dart';
import '../../widgets/category_pie_chart.dart';
import '../../widgets/weekly_bar_chart.dart';
import '../../widgets/custom_expense_curve_chart.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenses = Provider.of<ExpenseProvider>(context).expenses;
    // Use last 10 expenses for the curve chart
    final curveData = expenses.length >= 2
        ? expenses.reversed.take(10).map((e) => e.amount).toList().reversed.toList()
        : [0.0, 0.0];
    return Scaffold(
      appBar: AppBar(
        title: const Text("Insights"),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(5)),
        ),
        elevation: 2,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            "Category Breakdown",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 200, child: CategoryPieChart()),
          const SizedBox(height: 25),

          Text(
            "Weekly Expenses",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 220, child: WeeklyBarChart()),
          const SizedBox(height: 25),

          Text(
            "Recent Expenses Curve",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
          ),
          SizedBox(
            height: 180,
            child: CustomExpenseCurveChart(data: curveData),
          ),
        ],
      ),
    );
  }
}
