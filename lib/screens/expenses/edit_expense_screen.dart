import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
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
  late String category;
  DateTime? reminderDateTime;
  final _formKey = GlobalKey<FormState>();
  String? _amountError;

  @override
  void initState() {
    titleCtrl = TextEditingController(text: widget.expense.title);
    amountCtrl = TextEditingController(text: widget.expense.amount.toString());
    category = widget.expense.category;
  reminderDateTime = widget.expense.reminderDateTime;
  super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

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
                  backgroundColor: Colors.blueAccent,
                  child: const Icon(Icons.edit, color: Colors.white, size: 32),
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
              DropdownButton(
                value: category,
                items: ["Food", "Travel", "Shopping", "Bills"].map((e) {
                  return DropdownMenuItem(value: e, child: Text(e));
                }).toList(),
                onChanged: (value) => setState(() => category = value!),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(reminderDateTime == null
                        ? 'No reminder set'
                        : 'Reminder: 	${reminderDateTime!.toLocal()}'),
                  ),
                  TextButton(
                    child: const Text('Set Reminder'),
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: reminderDateTime ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(reminderDateTime ?? DateTime.now()),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            reminderDateTime = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                          });
                        }
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
                      widget.expense.reminderDateTime = reminderDateTime;
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
