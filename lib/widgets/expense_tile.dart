import 'package:flutter/material.dart';
import '../models/expense.dart';

class ExpenseTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  ExpenseTile({
    required this.expense,
    this.onDelete,
    this.onEdit,
  });

  IconData getIcon(String category) {
    switch (category) {
      case "Food": return Icons.fastfood;
      case "Travel": return Icons.flight;
      case "Shopping": return Icons.shopping_bag;
      case "Bills": return Icons.receipt_long;
      default: return Icons.category;
    }
  }

  Color getColor(String category) {
    switch (category) {
      case "Food": return Colors.redAccent;
      case "Travel": return Colors.blueAccent;
      case "Shopping": return Colors.green;
      case "Bills": return Colors.orange;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: Hero(
          tag: 'expense-avatar-${expense.id}',
          child: CircleAvatar(
            backgroundColor: getColor(expense.category),
            child: Icon(getIcon(expense.category), color: Colors.white),
          ),
        ),
        title: Text(expense.title),
        subtitle: Text(
          "${expense.category} • ${expense.date.toString().substring(0, 10)}",
        ),
        trailing: Text(
          "₹${expense.amount}",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onTap: onEdit,
        onLongPress: onDelete,
      ),
    );
  }
}
