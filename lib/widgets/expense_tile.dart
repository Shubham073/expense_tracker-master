import 'package:flutter/material.dart';
import '../models/expense.dart';

class ExpenseTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const ExpenseTile({Key? key, required this.expense, this.onDelete, this.onEdit}) : super(key: key);

  IconData _iconFor(String category) {
    switch (category) {
      case 'Food':
        return Icons.fastfood;
      case 'Travel':
        return Icons.flight;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Bills':
        return Icons.receipt_long;
      default:
        return Icons.category;
    }
  }

  Color _colorFor(String category) {
    switch (category) {
      case 'Food':
        return Colors.redAccent;
      case 'Travel':
        return Colors.blueAccent;
      case 'Shopping':
        return Colors.green;
      case 'Bills':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final amount = '₹${expense.amount.toStringAsFixed(2)}';
    final dateStr = expense.spentDate.toString().substring(0, 10);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: _colorFor(expense.category),
          child: Icon(_iconFor(expense.category), color: Theme.of(context).colorScheme.onPrimary, size: 20),
        ),
        title: Text(
          expense.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${expense.userCategory ?? expense.category} • $dateStr',
              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            if (expense.notes != null && expense.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  expense.notes!,
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
        trailing: Text(
          amount,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
        ),
        onTap: onEdit,
      ),
    );
  }
}
