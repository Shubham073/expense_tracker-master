import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/providers/category_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditExpenseScreen extends StatefulWidget {
  final Expense expense;

  EditExpenseScreen({required this.expense});

  @override
  _EditExpenseScreenState createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  late TextEditingController titleCtrl;
  late TextEditingController amountCtrl;
  late TextEditingController notesCtrl;
  late String category;
  String? userCategory;
  DateTime spentDate = DateTime.now();
  final _formKey = GlobalKey<FormState>();
  String? _amountError;

  @override
  void initState() {
    titleCtrl = TextEditingController(text: widget.expense.title);
    amountCtrl = TextEditingController(text: widget.expense.amount.toString());
    notesCtrl = TextEditingController(text: widget.expense.notes ?? '');
    category = widget.expense.category;
    userCategory = widget.expense.userCategory;
    spentDate = widget.expense.spentDate;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Expense")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Hero(
                tag: 'expense-avatar-${widget.expense.id}',
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Icon(Icons.edit, color: Theme.of(context).colorScheme.onPrimary, size: 32),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: "Title"),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Amount", errorText: _amountError),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Amount is required';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Enter a valid amount';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: DropdownButton(
                      value: category,
                      items: (["Food", "Travel", "Shopping", "Bills"]
                              .followedBy(categoryProvider.categories.map((c) => c.name))
                              .toSet())
                          .map((e) {
                        return DropdownMenuItem(
                          value: e,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                            child: Text(e),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() {
                        category = value!;
                        // Set userCategory only if it's a custom category (not one of the default 4)
                        final defaults = ["Food", "Travel", "Shopping", "Bills"];
                        userCategory = defaults.contains(value) ? null : value;
                      }),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: 'Add Category',
                    onPressed: () async {
                      final controller = TextEditingController();
                      final result = await showDialog<String>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Add Category'),
                          content: TextField(
                            controller: controller,
                            decoration: const InputDecoration(labelText: 'Category Name'),
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                            TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Add')),
                          ],
                        ),
                      );
                      if (result != null && result.trim().isNotEmpty) {
                        await categoryProvider.addCategory(result.trim());
                        setState(() {
                          userCategory = result.trim();
                          category = userCategory!;
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: notesCtrl,
                decoration: const InputDecoration(labelText: "Notes (optional)"),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text('Spent Date: ${spentDate.toLocal().toString().substring(0, 16)}'),
                  ),
                  TextButton(
                    child: const Text('Pick Date'),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: spentDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() { spentDate = picked; });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text("Update"),
                onPressed: () async {
                  setState(() { _amountError = null; });
                  if (_formKey.currentState!.validate()) {
                    try {
                      widget.expense.title = titleCtrl.text;
                      widget.expense.amount = double.parse(amountCtrl.text);
                      widget.expense.category = category;
                      widget.expense.reminderDateTime = null;
                      widget.expense.spentDate = spentDate;
                      widget.expense.notes = notesCtrl.text.isNotEmpty ? notesCtrl.text : null;
                      // Update userCategory based on whether it's a custom category
                      final defaults = ["Food", "Travel", "Shopping", "Bills"];
                      widget.expense.userCategory = defaults.contains(category) ? null : category;
                      await provider.updateExpense(widget.expense);
                      Navigator.pop(context);
                    } catch (e) {
                      setState(() { _amountError = 'Invalid amount'; });
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
