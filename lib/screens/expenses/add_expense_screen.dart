import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/providers/category_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddExpenseScreen extends StatefulWidget {
  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final titleCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  String category = "Food";
  String? userCategory;
  DateTime spentDate = DateTime.now();
  final _formKey = GlobalKey<FormState>();
  String? _amountError;

  @override
  Widget build(BuildContext context) {
  final provider = Provider.of<ExpenseProvider>(context);
  final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Add Expense")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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
                child: const Text("Save"),
                onPressed: () async {
                  setState(() { _amountError = null; });
                  if (_formKey.currentState!.validate()) {
                    try {
                      await provider.addExpense(
                        titleCtrl.text,
                        double.parse(amountCtrl.text),
                        category,
                        null,
                        spentDate,
                        notesCtrl.text.isNotEmpty ? notesCtrl.text : null,
                        userCategory,
                      );
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
