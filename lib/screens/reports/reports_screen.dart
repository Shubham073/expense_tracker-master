import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../models/expense.dart';
import '../../widgets/category_pie_chart.dart';
import '../../widgets/expense_timeline_view.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'week';

  @override
  Widget build(BuildContext context) {
    final expenses = Provider.of<ExpenseProvider>(context).expenses;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(5)),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment<String>(
                    value: 'week',
                    label: Text('Weekly'),
                    icon: Icon(Icons.calendar_view_week),
                  ),
                  ButtonSegment<String>(
                    value: 'month',
                    label: Text('Monthly'),
                    icon: Icon(Icons.calendar_month),
                  ),
                ],
                selected: {_selectedPeriod},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _selectedPeriod = newSelection.first;
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: _buildCategoryBreakdown(context, expenses, period: _selectedPeriod),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(BuildContext context, List<Expense> expenses, {required String period}) {
    final now = DateTime.now();
    List<Expense> filtered;
    if (period == 'week') {
      filtered = expenses.where((e) => now.difference(e.date).inDays < 7).toList();
    } else {
      filtered = expenses.where((e) => now.month == e.date.month && now.year == e.date.year).toList();
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '${period[0].toUpperCase()}${period.substring(1)}ly Overview',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: CategoryPieChart(expenses: filtered),
        ),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Daily Breakdown',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ExpenseTimelineView(
            expenses: filtered,
            period: period,
          ),
        ),
      ],
    );
  }
}
