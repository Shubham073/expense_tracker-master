
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/expense_tile.dart';
import 'add_expense_screen.dart';
import 'edit_expense_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    // Filtered view (search by title or category)
    final filtered = provider.expenses.where((e) {
      final q = _searchQuery.toLowerCase();
      if (q.isEmpty) return true;
      return e.title.toLowerCase().contains(q) ||
          e.category.toLowerCase().contains(q) ||
          (e.userCategory ?? '').toLowerCase().contains(q);
    }).toList();

    final total = provider.expenses.fold<double>(0.0, (t, e) => t + e.amount);

    return Scaffold(
      // let Scaffold resize when keyboard appears so we can account for viewInsets
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Expenses'),
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(5)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddExpenseScreen()),
          );
          // simple refresh after returning from add
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        bottom: true,
        child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search title or category',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Summary card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Spent', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          const SizedBox(height: 6),
                          Text('₹${total.toStringAsFixed(2)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Transactions', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        const SizedBox(height: 6),
                        Text('${provider.expenses.length}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // List
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 16),
              child: filtered.isEmpty
                  ? Center(child: Text(_searchQuery.isEmpty ? 'No expenses yet' : 'No matches for "$_searchQuery"'))
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final e = filtered[index];
                        return Dismissible(
                          key: Key(e.id),
                          background: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onError),
                          ),
                          secondaryBackground: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onError),
                          ),
                          onDismissed: (_) async {
                            await provider.deleteExpense(e.id);
                            setState(() {});
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
                              setState(() {});
                            },
                            onDelete: () async {
                              await provider.deleteExpense(e.id);
                              setState(() {});
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Expense deleted')),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}
