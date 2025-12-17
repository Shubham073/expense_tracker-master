
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/expense_tile.dart';
import 'add_expense_screen.dart';
import 'edit_expense_screen.dart';

class ExpensesScreen extends StatelessWidget {
  ExpensesScreen({super.key});

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Expenses"),
        backgroundColor: Colors.deepPurple,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddExpenseScreen()),
          );
          provider.loadExpenses();
        },
        child: const Icon(Icons.add),
      ),
      body: provider.expenses.isEmpty
          ? const Center(child: Text("No expenses yet"))
          : AnimatedList(
              key: _listKey,
              initialItemCount: provider.expenses.length,
              padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
              itemBuilder: (context, index, animation) {
                final e = provider.expenses[index];
                return SizeTransition(
                  sizeFactor: animation,
                  child: Dismissible(
                    key: Key(e.id),
                    background: Container(
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    secondaryBackground: Container(
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) async {
                      await provider.deleteExpense(e.id);
                      _listKey.currentState?.removeItem(
                        index,
                        (context, animation) => SizeTransition(
                          sizeFactor: animation,
                          child: ExpenseTile(expense: e),
                        ),
                        duration: const Duration(milliseconds: 300),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Expense deleted')),
                      );
                    },
                    child: ExpenseTile(
                      expense: e,
                      onEdit: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditExpenseScreen(expense: e),
                          ),
                        );
                        provider.loadExpenses();
                      },
                      onDelete: () async {
                        await provider.deleteExpense(e.id);
                        _listKey.currentState?.removeItem(
                          index,
                          (context, animation) => SizeTransition(
                            sizeFactor: animation,
                            child: ExpenseTile(expense: e),
                          ),
                          duration: const Duration(milliseconds: 300),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Expense deleted')),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
