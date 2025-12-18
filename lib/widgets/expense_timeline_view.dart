import 'package:flutter/material.dart';
import '../models/expense.dart';
import 'package:intl/intl.dart';

class ExpenseTimelineView extends StatelessWidget {
  final List<Expense> expenses;
  final String period;

  const ExpenseTimelineView({
    super.key,
    required this.expenses,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    // Group expenses by day
    Map<String, List<Expense>> groupedExpenses = {};
    Map<String, double> dailyTotals = {};
    double maxDaily = 0;
    double totalAmount = 0;

    for (var expense in expenses) {
      final dateKey = DateFormat('yyyy-MM-dd').format(expense.date);
      groupedExpenses[dateKey] ??= [];
      groupedExpenses[dateKey]!.add(expense);
      dailyTotals[dateKey] = (dailyTotals[dateKey] ?? 0) + expense.amount;
      totalAmount += expense.amount;
      if (dailyTotals[dateKey]! > maxDaily) {
        maxDaily = dailyTotals[dateKey]!;
      }
    }

    // Sort by date descending
    final sortedDates = groupedExpenses.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    if (sortedDates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No expenses for this period',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Summary Cards
        _buildSummaryCards(context, totalAmount, expenses.length, dailyTotals),
        const SizedBox(height: 16),
        
        // Timeline List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              final dateKey = sortedDates[index];
              final date = DateTime.parse(dateKey);
              final dayExpenses = groupedExpenses[dateKey]!;
              final total = dailyTotals[dateKey]!;
              final percentage = (total / maxDaily);

              return _buildDayCard(
                context,
                date,
                dayExpenses,
                total,
                percentage,
                index == 0,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(BuildContext context, double total, int count, Map<String, double> dailyTotals) {
    final avgDaily = dailyTotals.isNotEmpty ? total / dailyTotals.length : 0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              context,
              'Total',
              '₹${total.toStringAsFixed(0)}',
              Icons.account_balance_wallet,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              context,
              'Count',
              count.toString(),
              Icons.receipt,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              context,
              'Avg/Day',
              '₹${avgDaily.toStringAsFixed(0)}',
              Icons.trending_up,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color.fromRGBO(color.red, color.green, color.blue, 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color.fromRGBO(color.red, color.green, color.blue, 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(
    BuildContext context,
    DateTime date,
    List<Expense> dayExpenses,
    double total,
    double percentage,
    bool isToday,
  ) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final isCurrentDay = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;

    // Group by category for this day
    Map<String, double> categoryTotals = {};
    for (var expense in dayExpenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isCurrentDay
              ? BorderSide(color: theme.colorScheme.primary, width: 2)
              : BorderSide.none,
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color.fromRGBO(
                  theme.colorScheme.primaryContainer.red,
                  theme.colorScheme.primaryContainer.green,
                  theme.colorScheme.primaryContainer.blue,
                  0.3,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isCurrentDay
                          ? theme.colorScheme.primary
                          : theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          DateFormat('d').format(date),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isCurrentDay ? Colors.white : null,
                          ),
                        ),
                        Text(
                          DateFormat('MMM').format(date),
                          style: TextStyle(
                            fontSize: 11,
                            color: isCurrentDay
                                ? Colors.white
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              DateFormat('EEEE').format(date),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isCurrentDay) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Today',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${dayExpenses.length} transaction${dayExpenses.length > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${total.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percentage,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getColorForPercentage(percentage),
                  ),
                ),
              ),
            ),
            
            // Category breakdown
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: [
                  for (var entry in categoryTotals.entries)
                    Builder(
                      builder: (context) {
                        final categoryPercentage = (entry.value / total);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(entry.key),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  entry.key,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              Text(
                                '${(categoryPercentage * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '₹${entry.value.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForPercentage(double percentage) {
    if (percentage > 0.8) return Colors.red;
    if (percentage > 0.5) return Colors.orange;
    return Colors.green;
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'Food': Colors.orange,
      'Travel': Colors.blue,
      'Shopping': Colors.purple,
      'Bills': Colors.red,
    };
    return colors[category] ?? Colors.teal;
  }
}
